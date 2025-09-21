// Creates Applications

// Resource group must be deployed under 'subscription' scope
targetScope = 'resourceGroup'
param dateTime string = utcNow()

param resourceGroups object = {}
param storageAccount object = {}
param logResources array = []
param keyVault object = {}
param networks array = []
param appService array = []
param appServiceNames object = {}
param baseAppSettings object
param funcPriorityAppSettings object
param funcPriorityPagesAppSettings object
param funcApiAppSettings object
param appAdminAppSettings object
@secure()
param webRolesApplicationToken string
param adfsClientId string
@secure()
param adfsClientSecret string
@secure()
param applicationPassword string
param ThirdParty__SubscriptionKey string
param defaultConnectionString string

// Deploying the Storage Account
module stgModule './storageaccount.bicep' = {
  name: 'storageDeploy-${dateTime}'
  scope: resourceGroup(resourceGroups.appRg)
  params: {
    uniqueStorageName: storageAccount.name
    storageSKU: storageAccount.SKU
    containerName: storageAccount.containers
    queueName: storageAccount.queues
  }
}

//Deploying the Application Insights
module logs './logs.bicep' = [for logResource in logResources : {
  name: '${logResource.appInsightsName}'
  scope: resourceGroup(resourceGroups.appRg)
  params: {
    appInsightsName: logResource.appInsightsName
    logAnalyticsName: logResource.logAnalyticsName
  }
}]

//Deploying the Key vault
module KeyVault './keyvault.bicep' = {
  name: 'KeyVault-${dateTime}'
  scope: resourceGroup(resourceGroups.appRg)
  params: {
    keyVaultName: keyVault.name
    objectId: keyVault.objectId
    secretsPermissions: keyVault.secretsPermissions
    webRolesApplicationToken: webRolesApplicationToken
    adfsClientId: adfsClientId
    adfsClientSecret: adfsClientSecret
    applicationPassword: applicationPassword
  ThirdParty__SubscriptionKey: ThirdParty__SubscriptionKey
  }
}

// Deploying the Private Endpoints
module privateEndpointModule './privateEndpoint.bicep' = [for network in networks : {
  name: '${network.privateEndpointName}'
  scope: resourceGroup(resourceGroups.appRg)
  params: {
    uniqueStorageName: storageAccount.name
    keyVaultName: keyVault.name
    privateEndpointName: network.privateEndpointName
    privateEndpointSubnetId: network.privateEndpointSubnetId
    privateEndpointGroupId: network.privateEndpointGroupId
    privateEndpointmemberName: network.privateEndpointmemberName
    privateEndpointIp: network.privateEndpointIp
    privateEndpointFQDN: network.privateEndpointFQDN
  }
  dependsOn: [
    stgModule
    KeyVault
  ]
}]


// Deploying the Function App
module appservice './appservice.bicep' = [for app in appService: {
  name: 'functionapp-${app.name}'
  scope: resourceGroup(resourceGroups.appRg)
  params: {
    name: app.name
    kind: app.kind
    devopsRg: resourceGroups.devopsRg
    hostingPlanId: resourceGroups.appServiceHostPlan
    registryName: app.registryName
    managedIdentityName: resourceGroups.managedIdentity
    keyVaultName: keyVault.name
  }
  dependsOn: [
    logs
    stgModule
  ]
}]

module functionappsettings1 './appsettings/funcPriorityApp.bicep' = {
  name: '${appServiceNames.priorityAppName}appsettings'
  scope: resourceGroup(resourceGroups.appRg)
  params: {
    functionAppName: appServiceNames.priorityAppName
    appInsightsKey: logs[0].outputs.oInstrumentationKey
    stConnection: stgModule.outputs.stconnectionstring
    baseAppSettings: baseAppSettings
    funcPriorityAppSettings: funcPriorityAppSettings
  }
  dependsOn: [
    appservice
  ]
}

module functionappsettings2 './appsettings/funcPriorityPages.bicep' = {
  name: '${appServiceNames.priorityPagesAppName}appsettings'
  scope: resourceGroup(resourceGroups.appRg)
  params: {
    functionAppName: appServiceNames.priorityPagesAppName
    appInsightsKey: logs[0].outputs.oInstrumentationKey
    stConnection: stgModule.outputs.stconnectionstring
    baseAppSettings: baseAppSettings
    funcPriorityAppSettings: funcPriorityPagesAppSettings
  }
  dependsOn: [
    appservice
  ]
}

module functionappsettings3 './appsettings/funcApiApp.bicep' = {
  name: '${appServiceNames.apiAppName}appsettings'
  scope: resourceGroup(resourceGroups.appRg)
  params: {
    appName: appServiceNames.apiAppName
    keyVaultName: keyVault.name
    appInsightsKey: logs[0].outputs.oInstrumentationKey
    stConnection: stgModule.outputs.stconnectionstring
    baseAppSettings: baseAppSettings
    funcApiAppSettings: funcApiAppSettings
    defaultConnectionString: defaultConnectionString
  }
  dependsOn: [
    appservice
  ]
}

module appsettings1 './appsettings/appAdmin.bicep' = {
  name: '${appServiceNames.adminAppName}appsettings'
  scope: resourceGroup(resourceGroups.appRg)
  params: {
    appName: appServiceNames.adminAppName
    keyVaultName: keyVault.name
    appInsightsKey: logs[0].outputs.oInstrumentationKey
    baseAppSettings: baseAppSettings
    appAdminAppSettings: appAdminAppSettings
    defaultConnectionString: defaultConnectionString
  }
  dependsOn: [
    appservice
  ]
}
