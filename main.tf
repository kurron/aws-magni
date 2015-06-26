provider "aws" {
    region = "${var.aws_region}"
    max_retries = 10
}

resource "aws_security_group" "docker-host" {
    name = "docker-host"
    description = "Firewall rules to allow provisioning and application deployment"

    tags {
        realm = "experimental"
        created-by = "Terraform"
        direction = "bi-dierectional"
        purpose = "application"
    }
}

resource "aws_security_group_rule" "inbound-ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.docker-host.id}"
}

resource "aws_security_group_rule" "inbound-http" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.docker-host.id}"
}

resource "aws_security_group_rule" "allow-all-outbound" {
    type = "egress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.docker-host.id}"
}


