# IoT Data ATS endpoint
data "aws_iot_endpoint" "data_ats" {
  endpoint_type = "iot:Data-ATS"
}

# IoT Credential Provider endpoint
data "aws_iot_endpoint" "credentials_provider" {
  endpoint_type = "iot:CredentialProvider"
}

output "iot_data_endpoint" {
  value = data.aws_iot_endpoint.data_ats.endpoint_address
}

output "iot_credentials_provider_endpoint" {
  value = data.aws_iot_endpoint.credentials_provider.endpoint_address
}

resource "awscc_iot_thing" "gg_core" {
  thing_name = "gg-core-demo-${random_string.suffix.result}"
  attribute_payload = {
    attributes = {
      type = "greengrass-core"
    }
  }
}


resource "awscc_greengrassv2_deployment" "gg_core_deployment" {
  deployment_name = "gg-core-demo-deployment-${random_string.suffix.result}"
  target_arn      = awscc_iot_thing.gg_core.arn

  deployment_policies = {
    configuration_validation_policy = {
      timeout_in_seconds = 60
    }
    component_update_policy = {
      timeout_in_seconds = 120
      action             = "NOTIFY_COMPONENTS"
    }
    failure_handling_policy = "ROLLBACK"
  }

  components = {
    "aws.greengrass.Nucleus" = {
      component_version = "2.12.4"
      configuration_update = {
        reset = [""]
        merge = jsonencode({
          jvmOptions = ["-Xmx64m"]
          mqtt = {
            spooler = {
              storageType    = "Disk"
              maxSizeInBytes = "10485760"
              keepQos0       = true
            }
          }
        })
      }
    }
    "aws.greengrass.LogManager" = {
      component_version = "2.3.7"
      configuration_update = {
        reset = [""]
        merge = jsonencode({
          logsUploaderConfiguration = {
            systemLogsConfiguration = {
              uploadToCloudWatch            = "true"
              minimumLogLevel               = "INFO"
              diskSpaceLimit                = "10"
              diskSpaceLimitUnit            = "MB"
              deleteLogFileAfterCloudUpload = "false"
            }
          }
          periodicUploadIntervalSec = "300"
        })
      }
    }
  }

  tags = {
    "Modified By" = "AWSCC"
  }
}

resource "aws_iot_certificate" "gg_core_cert" {
  active = true
}

resource "aws_iot_policy" "gg_core_policy" {
  name = "gg-core-policy-${random_string.suffix.result}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iot:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iot_policy_attachment" "gg_core_attach" {
  policy = aws_iot_policy.gg_core_policy.name
  target = aws_iot_certificate.gg_core_cert.arn
}

resource "aws_iot_thing_principal_attachment" "gg_core_attach" {
  thing     = awscc_iot_thing.gg_core.thing_name
  principal = aws_iot_certificate.gg_core_cert.arn
}

resource "aws_iot_role_alias" "gg_token_exchange_alias" {
  alias    = "GreengrassCoreTokenExchangeAlias-${random_string.suffix.result}"
  role_arn = aws_iam_role.gg_token_exchange_role.arn
}
