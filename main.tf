terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }
}

#AWS Provider

provider "aws" {
  # Configuration options
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_security_group" "web_sg" {
# Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "websrv" {
  ami           = "ami-07caf09b362be10b8"
  instance_type = "t2.micro"
  count = 3
  key_name = "websrv"
  user_data = <<EOF
#!/bin/bash
yum install httpd -y
systemctl start httpd
systemctl enable httpd
echo "server${count.index}" > /var/www/html/index.html
touch /tmp/server01
EOF

tags = {

  Name = "Server${count.index}"
}
 
}



resource "aws_network_interface_sg_attachment" "sg_attachment" {
  count = 3
  security_group_id    =  "${aws_security_group.web_sg.id}"
  network_interface_id = "${aws_instance.websrv[count.index].primary_network_interface_id}"
}


output "ec2_global_ips" {
  value = ["${aws_instance.websrv.*.public_ip}"]
}