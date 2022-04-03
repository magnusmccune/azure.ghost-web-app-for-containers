
param customDomainName string
param originHostName string
param afdProfileName string


module azureFrontDoor 'modules/AFD.bicep' = {
  name: 'azureFrontDoor'
  params: {
    customDomainName: customDomainName
    originHostName: originHostName
    profileName: afdProfileName
  }
}
