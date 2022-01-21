targetScope = 'subscription'

// Parameters
param baseName string
param AKSvnetcidr array = [
  '10.0.0.0/16'
]
param subnet object = {
  properties: {
    addressPrefix: '10.0.0.0/24'
  }
  name: 'default'
}
// Variables
var rgName = '${baseName}-RG'

module rg 'modules/resource-group/rg.bicep' = {
  name: rgName
  params: {
    rgName: rgName
    location: deployment().location
  }
}

module vnetaks 'modules/vnet/vnet.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'vnet'
  params: {
    vnetAddressSpace: {
        addressPrefixes: AKSvnetcidr
    }
    vnetNamePrefix: 'aks'
    subnets: [
      subnet
    ]
  }
  dependsOn: [
    rg
  ]
}

module aksIdentity 'modules/Identity/userassigned.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'aksIdentity'
  params: {
    basename: baseName
  }
}

resource subnetaks 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  scope: resourceGroup(rg.name)
  name: '${vnetaks.name}-subnet'
}

module aksCluster 'modules/aks/aks.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'aksCluster'
  params: {
    basename: baseName
    subnetId: subnetaks.id
    identity: {
      '${aksIdentity.outputs.identityid}' : {}
    }
    principalId: aksIdentity.outputs.principalId
  }
}
