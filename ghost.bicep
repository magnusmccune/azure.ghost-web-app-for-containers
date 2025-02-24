@description('Prefix to use when creating the resources in this deployment.')
param orgPrefix string

@description('Prefix to use when creating the resources in this deployment.')
param projectPrefix string

param siteUrl string

@description('App Service Plan pricing tier')
param appServicePlanSku string = 'B1'

@description('Storage account pricing tier')
param storageAccountSku string = 'Standard_LRS'

@description('Location to deploy the resources')
param location string = resourceGroup().location

@description('MySQL server SKU')
param mySQLServerSku string = 'B_Gen5_1'

@description('MySQL server password')
@secure()
param databasePassword string

@description('Ghost container full image name and tag')
param ghostContainerName string

@description('Container registry where the image is hosted')
param containerRegistryUrl string

@description('ResourceID of existing Log Analytics Workspace')
param lawID string

@allowed([
  'Web app with Azure CDN'
  'Web app with Azure Front Door'
])
param deploymentConfiguration string = 'Web app with Azure Front Door'

var webAppName = toLower('${orgPrefix}${projectPrefix}web01')
var appServicePlanName = toLower('${orgPrefix}${projectPrefix}asp01')
var applicationInsightsName = toLower('${orgPrefix}${projectPrefix}ai01')
var keyVaultName = toLower('${orgPrefix}${projectPrefix}kvt01')
var storageAccountName = toLower('${orgPrefix}${projectPrefix}stg01')

var mySQLServerName = toLower('${orgPrefix}${projectPrefix}mysql01')
var databaseLogin = 'ghost'
var databaseName = 'ghost'

var ghostContentFileShareName = 'contentfiles'
var ghostContentFilesMountPath = '/var/lib/ghost/content_files'

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccountDeploy'
  params: {
    storageAccountName: storageAccountName
    storageAccountSku: storageAccountSku
    fileShareFolderName: ghostContentFileShareName
    logAnalyticsWorkspaceId: lawID
    location: location
  }
}

module keyVault './modules/keyVault.bicep' = {
  name: 'keyVaultDeploy'
  params: {
    keyVaultName: keyVaultName
    keyVaultSecretName: 'databasePassword'
    keyVaultSecretValue: databasePassword
    logAnalyticsWorkspaceId: lawID
    servicePrincipalId: webApp.outputs.principalId
    location: location
  }
}

module webApp './modules/webApp.bicep' = {
  name: 'webAppDeploy'
  params: {
    webAppName: webAppName
    appServicePlanId: appServicePlan.outputs.id
    ghostContainerImage: ghostContainerName
    storageAccountName: storageAccount.outputs.name
    storageAccountAccessKey: storageAccount.outputs.accessKey
    fileShareName: ghostContentFileShareName
    containerMountPath: ghostContentFilesMountPath
    location: location
    logAnalyticsWorkspaceId: lawID
    deploymentConfiguration: deploymentConfiguration
  }
}

module webAppSettings 'modules/webAppSettings.bicep' = {
  name: 'webAppSettingsDeploy'
  params: {
    webAppName: webApp.outputs.name
    applicationInsightsConnectionString: applicationInsights.outputs.ConnectionString
    applicationInsightsInstrumentationKey: applicationInsights.outputs.InstrumentationKey
    containerRegistryUrl: containerRegistryUrl
    containerMountPath: ghostContentFilesMountPath
    databaseHostFQDN: mySQLServer.outputs.fullyQualifiedDomainName
    databaseLogin: '${databaseLogin}@${mySQLServer.outputs.name}'
    databasePasswordSecretUri: keyVault.outputs.databasePasswordSecretUri
    databaseName: databaseName
    siteUrl: siteUrl
  }
}

module appServicePlan './modules/appServicePlan.bicep' = {
  name: 'appServicePlanDeploy'
  params: {
    appServicePlanName: appServicePlanName
    appServicePlanSku: appServicePlanSku
    location: location
    logAnalyticsWorkspaceId: lawID
  }
}

module applicationInsights './modules/applicationInsights.bicep' = {
  name: 'applicationInsightsDeploy'
  params: {
    applicationInsightsName: applicationInsightsName
    location: location
    logAnalyticsWorkspaceId: lawID
  }
}

module mySQLServer 'modules/mySQLServer.bicep' = {
  name: 'mySQLServerDeploy'
  params: {
    administratorLogin: databaseLogin
    administratorPassword: databasePassword
    location: location
    logAnalyticsWorkspaceId: lawID
    mySQLServerName: mySQLServerName
    mySQLServerSku: mySQLServerSku
  }
}

output webAppName string = webApp.outputs.name
output webAppPrincipalId string = webApp.outputs.principalId
output webAppHostName string = webApp.outputs.hostName
