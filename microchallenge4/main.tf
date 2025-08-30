########################
# Terraform Settings
########################
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

########################
# Variables
########################
variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  # Must match your AWS key pair name
  default = "microchallenge4"
}

########################
# AWS Provider
########################
provider "aws" {
  region = var.region
}

########################
# Get latest Ubuntu 22.04 LTS AMI
########################
data "aws_ami" "ubuntu_jammy" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

########################
# Get a Free Tier Eligible Instance Type
########################
data "aws_ec2_instance_type_offerings" "free_tier" {
  filter {
    name   = "instance-type"
    values = ["t2.micro", "t3.micro"] # check both
  }
  location_type = "region"
}

########################
# Security Group (SSH + HTTP)
########################
resource "aws_security_group" "web_sg" {
  name        = "xops-web-sg"
  description = "Allow SSH (22) and HTTP (80)"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################
# EC2 Instance
########################
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu_jammy.id
  instance_type          = element(data.aws_ec2_instance_type_offerings.free_tier.instance_types, 0)
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y python3 python3-apt
  EOF

  tags = {
    Name = "xops-nginx-web"
  }
}

########################
# Outputs
########################
output "public_ip" {
  value = aws_instance.web.public_ip
}

output "public_dns" {
  value = aws_instance.web.public_dns
}
