// General configuration
var uniqueName = uniqueString(resourceGroup().name)

param projectName string
param environment string
param setupEmailNotifications bool
param functionappName string = ''
param emailCustomEvent string = ''
param emailRegisteredModel string = ''
param emailFailedRun string = ''
param emailFrom string = ''

@secure()
param sendgridAPIKey string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Provide a tier of your Azure Container Registry.')
param acrSku string
param location string = resourceGroup().location

// Resources
resource KeyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: '${projectName}-${environment}-kv'
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
    tenantId: subscription().tenantId
  }
}

module AMLWorkspace 'modules/aml-workspace.bicep' = {
  name: 'AMLWorkspaceDeploy-${uniqueName}'
  params: {
    projectName: projectName
    environment: environment
    location: location
    keyVaultId: KeyVault.id
    acrSku: acrSku
  }
}

module azurefunc 'modules/azfunc.bicep' = if (setupEmailNotifications) {
  name: 'azurefunc-deploy'
  params: {
    location: location
    functionAppName: functionappName
    keyVaultname: KeyVault.name
    AMLWorkspaceName: AMLWorkspace.outputs.mlWorkSpaceName
    emailRegisteredModel: emailRegisteredModel
    emailFailedRun: emailFailedRun
    emailCustomEvent: emailCustomEvent
    emailFrom: emailFrom
    sendgridAPIKey: sendgridAPIKey
  }
}

module events 'modules/event-grids.bicep' = if (setupEmailNotifications) {
  name: 'events-deploy'
  params: {
    location: location
    environment: environment
    AMLWorkspaceId: AMLWorkspace.outputs.mlWorkSpaceId
    projectName: projectName
    azfuncSystemId: setupEmailNotifications ? azurefunc.outputs.systemEmailId : ''
    azfuncEventId: setupEmailNotifications ? azurefunc.outputs.eventEmailId : ''
  }
}

output AMLWorkspaceName string = AMLWorkspace.name
