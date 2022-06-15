param projectName string
param environment string

@description('Specifies the location for all resources.')
param location string

@description('The ID for the key vault to created and associated with the workspace.')
param keyVaultId string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Provide a tier of your Azure Container Registry.')
param acrSku string

param acrAdminUserEnabled bool = true

// Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: replace('${projectName}${environment}sa', '-', '')
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: replace('${projectName}-${environment}-creg', '-', '')
  location: location
  sku: {
  name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${projectName}-${environment}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource mlWorkSpace 'Microsoft.MachineLearningServices/workspaces@2021-07-01' = {
  name: '${projectName}-${environment}-mlsw'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: '${projectName}-${environment}-mlsw'
    storageAccount: storageAccount.id
    keyVault: keyVaultId
    containerRegistry: containerRegistry.id
    applicationInsights: applicationInsights.id
  }
}

output mlWorkSpaceName string = mlWorkSpace.name
output mlWorkSpaceId string = mlWorkSpace.id
output storageAccountName string = storageAccount.name
output applicationInsightsName string = applicationInsights.name
output location string = location
output registryname string = containerRegistry.name
