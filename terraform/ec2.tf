provider "aws" {
    region = "us-west-1"
}

resource "aws_instance" "ec2-instance" {
    ami = "ami-0c2d06d50ce30b442"
    instance_type = "t2.micro"
    vpc_security_group_ids = "aws_security_group.mysg.id"
}

resource "aws_security_group" "mysg" {
    name = "allow-ssh"
    description = "Allow ssh traffic"
    vpc_id = "vpc-07142bf09e3b0cf4b"

    ingress {
        description = "Allow inbound ssh traffic"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = "[0.0.0.0/0]"
    }

    ingress {
        description = "Allow inbound https traffic"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = "[0.0.0.0/0]"
    }

     ingress {
        description = "Allow inbound LDAP traffic"
        from_port = 3436
        to_port = 3438
        protocol = "tcp"
        cidr_blocks = "[0.0.0.0/0]"
    }

    tags = {
        name = "allow_ssh"
    }
}

