terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "ap-south-1"
}
resource "aws_key_pair" "example" {
  key_name = "key02"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_security_group" "allow_all" {
  name_prefix = "allow_all"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # This allows all protocols (TCP, UDP, ICMP)
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # This allows all protocols (TCP, UDP, ICMP)
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server" {
  ami           = "ami-0522ab6e1ddcc7055"
  instance_type = var.instance_type
  key_name = "key02"
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  tags = {
    Name = "${terraform.workspace}_server"
  }
  provisioner "remote-exec" {
    inline = [
      "cat /etc/os-release",
      "mkdir -p /home/ubuntu/.ssh",
      "echo '${var.ssh_public_key}' >> /home/ubuntu/.ssh/authorized_keys",
      "chmod 600 /home/ubuntu/.ssh/authorized_keys",
      "chown -R ubuntu:ubuntu /home/ubuntu/.ssh"
    ]
  }
  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_private_key)
   }
  provisioner "local-exec" {
    command = "echo '${self.public_ip} ansible_user=ubuntu ansible_private_key_file=~/.ssh/id_ed25519' > inventory.ini"
  }
  provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i inventory.ini -e 'ansible_python_interpreter=/usr/bin/python3' ansible-playbook.yml"
  }
}
