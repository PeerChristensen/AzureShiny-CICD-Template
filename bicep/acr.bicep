
param acrName string

@description('Provide a tier of your Azure Container Registry.')
param acrSku string

@description('Whether to enable admin user on ACR')
param acrAdminUserEnabled bool = true

param location string = resourceGroup().location

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrName
  location: location
  sku: {
  name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}
