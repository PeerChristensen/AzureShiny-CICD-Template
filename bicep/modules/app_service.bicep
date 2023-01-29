@description('Location of resource')
param location string

@description('Name given to the App Service')
param appServiceAppName string

@description('Name given to the App Service Plan')
param appServicePlanName string

@description('Name of the existing ACR')
param acrName string

@description('Username of existing ACR')
param acrUsername string

@description('Password of existing ACR')
param acrPassword string

@description('The service plan level to use')
param appServicePlanSkuName string

@description('Name and tag of docker image to use')
param dockerImageAndTag string

resource appServicePlan 'Microsoft.Web/serverFarms@2021-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
  }
  kind: 'linux'
  properties: {
    targetWorkerSizeId: 0
    targetWorkerCount: 1
    reserved: true
  }
}

resource appServiceApp 'Microsoft.Web/sites@2021-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    clientCertEnabled: false
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrName}.azurecr.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: acrUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: acrPassword
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'WEBSITES_PORT'
          value: '3838'
        }
      ]
      linuxFxVersion: 'DOCKER|${dockerImageAndTag}'
    }
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
