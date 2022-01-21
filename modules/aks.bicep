param basename string
param subnetId string
param identity object

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: '${basename}aks'
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: identity
  }
  properties: {
    kubernetesVersion: '1.22.4'
    nodeResourceGroup: '${basename}-aksInfraRG'
    dnsPrefix: '${basename}aks'
    agentPoolProfiles: [
      {
        name: 'default'
        count: 2
        vmSize: 'Standard_D4s_v3'
        mode: 'System'
        maxCount: 5
        minCount: 2
        maxPods: 30
        enableAutoScaling: true
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: subnetId
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      outboundType: 'loadBalancer'
      dockerBridgeCidr: '172.17.0.1/16'
      dnsServiceIP: '10.0.0.10'
      serviceCidr: '10.0.0.0/16'
      networkPolicy: 'azure'
    }
  }
}

