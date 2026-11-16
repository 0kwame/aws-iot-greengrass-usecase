# 3. EC2 Instance with user_data bootstrap
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID for Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_security_group" "gg_core_sg" {
  name        = "gg-core-sg-${random_string.suffix.result}"
  description = "Security group for Greengrass Core"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow MQTT"
    from_port   = 8883
    to_port     = 8883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # or restrict to IoT Core IP ranges
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gg-core-sg"
  }
}

# Optional: Create a new key pair using your public key
resource "aws_key_pair" "default" {
  key_name   = "ec2-key-${random_string.suffix.result}"
  public_key = file("${path.module}/keys/key.pub")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "gg_core" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.gg_instance_profile.name
  key_name                    = aws_key_pair.default.key_name
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.gg_core_sg.id]

  # user_data = templatefile("${path.module}/scripts/setup-greengrass.sh", {
  #   certificate_pem = aws_iot_certificate.gg_core_cert.certificate_pem
  #   private_key     = aws_iot_certificate.gg_core_cert.private_key
  #   public_key      = aws_iot_certificate.gg_core_cert.public_key
  #   region          = "eu-central-1"
  #   thing_name      = awscc_iot_thing.gg_core.thing_name
  # })


  # Use connection for remote-exec
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./keys/key") # or wherever your key is
    host        = self.public_ip
  }

  # provisioner "file" {
  #   content = templatefile("${path.module}/scripts/setup-greengrass.sh", {
  #     # certificate_pem = aws_iot_certificate.gg_core_cert.certificate_pem
  #     # private_key     = aws_iot_certificate.gg_core_cert.private_key
  #     # public_key      = aws_iot_certificate.gg_core_cert.public_key
  #     region = "eu-central-1"
  #     # thing_name        = awscc_iot_thing.gg_core.thing_name
  #     # thing_policy_name = aws_iot_policy.gg_core_policy.name
  #     # tes_role_name     = aws_iam_role.gg_token_exchange_role.name
  #     # tes_role_alias    = aws_iot_role_alias.gg_token_exchange_alias.alias
  #   })
  #   destination = "/tmp/setup-greengrass.sh"
  # }

  # provisioner "file" {
  #   source      = "${path.module}/scripts/setup-greengrass.sh"
  #   destination = "/tmp/setup-greengrass.sh"
  # }

  provisioner "file" {
    content = templatefile("${path.module}/scripts/setup-greengrass.sh", {
      tes_role_name  = aws_iam_role.gg_token_exchange_role.name
      tes_role_alias = aws_iot_role_alias.gg_token_exchange_alias.alias
    })
    destination = "/tmp/setup-greengrass.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-greengrass.sh",
      "sudo /tmp/setup-greengrass.sh 2>&1 | tee /tmp/greengrass-install.log",
      "echo 'Setup completed with exit code:' $?"
    ]
  }


  tags = {
    Name = "GreengrassCore"
  }
}
