param projectName string
param environment string

@description('Provide a tier of your Azure Container Registry.')
param acrSku string

@description('Whether to enable admin user on ACR')
param acrAdminUserEnabled bool = true

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: replace('${projectName}-${environment}-creg', '-', '')
  location: resourceGroup().location
  sku: {
  name: acrSku
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

output acrName string = containerRegistry.name
