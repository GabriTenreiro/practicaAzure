@description('Azure region for all resources')
param location string = 'northeurope'

@description('Existing storage account name')
param storageAccountName string = 'stgabritenreiroprueba'

@description('Existing Synapse workspace name')
param synapseWorkspaceName string = 'syn-laptop-dl-dev-001'

@description('Spark pool name')
param sparkPoolName string = 'sparkpoollaptop'

@description('Node size for Spark pool')
param sparkNodeSize string = 'Small'

@description('Number of Spark nodes')
param sparkNodeCount int = 3

@description('Auto shutdown idle time in minutes')
param autoShutdownMinutes int = 15

@description('Spark version')
param sparkVersion string = '3.4'

var containerNames = [
  'raw'
  'processed'
  'quarantine'
  'curated'
  'rejected'
]

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' existing = {
  parent: storageAccount
  name: 'default'
}

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [for name in containerNames: {
  parent: blobService
  name: name
}]

resource sparkPool 'Microsoft.Synapse/workspaces/bigDataPools@2021-06-01-preview' = {
  name: '${synapseWorkspaceName}/${sparkPoolName}'
  location: location
  properties: {
    nodeSize: sparkNodeSize
    nodeSizeFamily: 'MemoryOptimized'
    nodeCount: sparkNodeCount
    autoPause: {
      enabled: true
      delayInMinutes: autoShutdownMinutes
    }
    autoScale: {
      enabled: true
      minNodeCount: sparkNodeCount
      maxNodeCount: sparkNodeCount
    }
    sparkVersion: sparkVersion
    libraryRequirements: {
      content: ''
    }
  }
}

output storageAccountUrl string = 'https://${storageAccountName}.dfs.core.windows.net'
output synapseWorkspaceUrl string = 'https://web.azuresynapse.net/en-us/launchstudio/${synapseWorkspaceName}'
