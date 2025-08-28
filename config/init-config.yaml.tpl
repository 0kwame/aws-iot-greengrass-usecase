---
system:
  rootpath: "/greengrass/v2"
  certificateFilePath: "/greengrass/certs/device.pem.crt"
  privateKeyPath: "/greengrass/certs/private.pem.key"
  rootCaPath: "/greengrass/certs/AmazonRootCA1.pem"
  thingName: "gg-core-demo-tauiah"

services:
  aws.greengrass.Nucleus:
    version: "2.15.0"
    configuration:
      awsRegion: "eu-central-1"
      iotDataEndpoint: "${iot_data_endpoint}"
      iotCredEndpoint: "${iot_cred_endpoint}"
      iotRoleAlias: "GreengrassCoreTokenExchangeRoleAlias"
      mqtt:
        port: 443
      greengrassDataPlanePort: 443
      networkProxy:
        noProxyAddresses: "http://192.168.0.1,www.example.com"
        proxy:
          url: "http://my-proxy-server:1100"
          username: "Mary_Major"
          password: "pass@word1357"

  com.example.CustomProvisioning:
    configuration:
      # plugin parameters go here if needed
      # pluginParameter: ""
