targetScope= 'subscription'

param orgPrefix string
param projectPrefix string
param location string = deployment().location
param tags object = {}

param customDomainName string

param containerRegistryUrl string
param databasePassword string
param ghostContainerName string
param lawID string
param afdProfileName string

var workloadRGName = toLower('${orgPrefix}-${projectPrefix}-rg-01')
var infraRGName = toLower('${orgPrefix}-infra-rg-01')

resource workloadRG 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: workloadRGName
  location: location
  tags: tags
}

resource infraRG 'Microsoft.Resources/resourceGroups@2020-10-01' existing = {
  name: infraRGName
}

module workload 'ghost.bicep' = {
  scope: workloadRG
  name: 'workloadDeploy'
  params: {
    containerRegistryUrl: containerRegistryUrl
    databasePassword: databasePassword
    ghostContainerName: ghostContainerName
    lawID: lawID
    orgPrefix: orgPrefix
    projectPrefix: projectPrefix
    location: location
    siteUrl: customDomainName
  }
}

module infra 'infra.bicep' = {
  scope: infraRG
  name: 'infraDeploy'
  params: {
    customDomainName: customDomainName
    originHostName: workload.outputs.webAppHostName
    afdProfileName: afdProfileName
  }
}
