variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "server_port_web" {}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "eu-central-1"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = "${var.server_port_web}"
    to_port = "${var.server_port_web}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
    ami = "ami-030aae8cba933aede"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.instance.id}"]
    
    key_name = "terra demo"

    tags {
        Name = "tf web example"
    }

    user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup python -m SimpleHTTPServer "${var.server_port_web}" &
              EOF
}

output "aws_public_dns" {
    value = "${aws_instance.web.public_dns}"
}

output "aws_public_ip" {
  value = "${aws_instance.web.public_ip}"
}
