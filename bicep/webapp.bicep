
param projectName string
param environment string

@description('Name of existing ACR to use')
param acrName string

@description('Username of existing ACR')
param acrUsername string

@description('Password of existing ACR')
param acrPassword string

@description('Sku or machine type to use for app')
param appServicePlanSkuName string

@description('Image name and tag of docker image')
param dockerImageAndTag string

@description('Provide a location for the registry.')
param location string = resourceGroup().location

// Create the appservice from module
module appService 'modules/app_service.bicep' = {
  name: '${projectName}-${environment}-appServiceModule'
  params: {
    location: location
    appServiceAppName: '${projectName}-${environment}-wa'
    appServicePlanName: '${projectName}-${environment}-asp'
    acrName: acrName
    acrUsername: acrUsername
    acrPassword: acrPassword
    appServicePlanSkuName: appServicePlanSkuName
    dockerImageAndTag: dockerImageAndTag
  }
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
