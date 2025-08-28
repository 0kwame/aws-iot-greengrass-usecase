output "ssh-gg-core-device" {
  value = "ssh -i keys/key ubuntu@${aws_instance.gg_core.public_ip}"
}


# Output public IP
output "ec2_public_ip" {
  value = aws_instance.gg_core.public_ip
}

# output "gg_core_thing_id" {
#   value = awscc_iot_thing.gg_core.thing_id
# }
