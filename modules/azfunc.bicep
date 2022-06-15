@description('Specifies region of all resources.')
param location string = resourceGroup().location

param functionAppName string

@description('Storage account SKU name.')
param storageSku string = 'Standard_LRS'

param keyVaultname string
param tenantID string = subscription().tenantId
param resourceGroupName string = resourceGroup().name
param AMLWorkspaceName string
param subscriptionID string = subscription().id
param emailCustomEvent string
param emailRegisteredModel string
param emailFailedRun string
param emailFrom string

@secure()
param sendgridAPIKey string

var appServicePlanName = 'FunctionPlan'
var appInsightsName = 'AppInsights'
var storageAccountName = 'fnstor${replace(functionAppName, '-', '')}'
var functionRuntime = 'python'
var functionAppKeySecretName = 'FunctionAppHostKey'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource plan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type:'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.8'
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionRuntime
        }
        {
          name: 'TENANT_ID'
          value: tenantID
        }
        {
          name: 'RESOURCE_GROUP'
          value: resourceGroupName
        }
        {
          name: 'WORKSPACE_NAME'
          value: AMLWorkspaceName
        }
        {
          name: 'SUBSCRIPTION_ID'
          value: subscriptionID
        }
        {
          name: 'EMAIL_REGISTERED_MODEL'
          value: emailRegisteredModel
        }
        {
          name: 'EMAIL_FAILED_RUN'
          value: emailFailedRun
        }
        {
          name: 'EMAIL_CUSTOM_EVENT'
          value: emailCustomEvent
        }
        {
          name: 'EMAIL_FROM'
          value: emailFrom
        }
        {
          name: 'SENDGRID_API_KEY'
          value: sendgridAPIKey
        }
      ]
    }
    httpsOnly: true
  }
}

resource systemEmail 'Microsoft.Web/sites/functions@2021-03-01' = {
  name: '${functionApp.name}/aml-email-notifications'
  properties: {
    config: {
      disabled: false
      bindings: [
        {
          name: 'event'
          type: 'eventGridTrigger'
          direction: 'in'
        }
    ]
    }
  }
}

resource EventEmail 'Microsoft.Web/sites/functions@2021-03-01' = {
  name: '${functionApp.name}/custom-email-notifications'
  properties: {
    config: {
      disabled: false
      bindings: [
        {
          name: 'event'
          type: 'eventGridTrigger'
          direction: 'in'
        }
    ]
    }
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${keyVaultname}/${functionAppKeySecretName}'
  properties: {
    value: listKeys('${functionApp.id}/host/default', functionApp.apiVersion).functionKeys.default
  }
}

output functionAppHostName string = functionApp.properties.defaultHostName
output systemEmailId string = systemEmail.id
output eventEmailId string = EventEmail.id
