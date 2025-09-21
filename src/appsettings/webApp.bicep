param appName string
param appInsightsKey string
param baseAppSettings object
param webAppSettings object
param defaultConnectionString string

param localAppSettings object = {
  APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsKey
}

resource siteConfig 'Microsoft.Web/sites/config@2022-09-01' = {
  name: '${appName}/appSettings'
  properties: union(localAppSettings, baseAppSettings, webAppSettings)
}

resource siteConfigConnString 'Microsoft.Web/sites/config@2022-09-01' = {
  name: '${appName}/connectionstrings'
  properties: {
    DefaultConnection: {
      value: defaultConnectionString
      type: 'SQLServer'
    }
  }
}
