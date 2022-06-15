param projectName string
param environment string
param location string
param AMLWorkspaceId string
@description('Provide the URL for the WebHook to receive events. Create your own endpoint for events.')
param azfuncSystemId string
param azfuncEventId string

// Create resources for event and system topic events
resource eventTopic 'Microsoft.EventGrid/topics@2021-12-01' = {
  name: '${projectName}-${environment}-et'
  location: location
  properties: {
    inputSchema: 'EventGridSchema'
  }
}

resource systemTopic 'Microsoft.EventGrid/systemTopics@2021-12-01' = {
  name: '${projectName}-${environment}-st'
  location: location
  properties: {
    source: AMLWorkspaceId
    topicType: 'Microsoft.MachineLearningServices.workspaces'
  }
}

resource eventSubscriptionSystem 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2021-12-01' = {
  parent: systemTopic
  name: '${projectName}-${environment}-aml-sub'
  properties: {
    destination: {
      properties: {
        resourceId: azfuncSystemId
      }
      endpointType: 'AzureFunction'
    }
  }
}

resource eventSubscriptionEvent 'Microsoft.EventGrid/topics/eventSubscriptions@2021-10-15-preview' = {
  parent: eventTopic
  name: '${projectName}-${environment}-event-sub'
  properties: {
    destination: {
      properties: {
        resourceId: azfuncEventId
      }
      endpointType: 'AzureFunction'
    }
  }
}
