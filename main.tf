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

resource "aws_instance" "docker" {
    connection {
        user = "ubuntu"
        key_file = "${lookup(var.key_path, var.aws_region)}"
    }

    count = "${var.docker_instance_count}"
    ami = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "${var.instance_type}"
    key_name = "${lookup(var.key_name, var.aws_region)}"
    security_groups = ["${aws_security_group.docker-host.name}"]
    availability_zone = "${lookup(var.availability_zones, count.index)}"

    tags {
        realm = "experimental"
        purpose = "docker-container"
        created-by = "Terraform"
    }

    # run Ansible to provision the box
    provisioner "local-exec" {
        command = "./provision-instance.sh ${self.public_ip} ${lookup(var.key_path, var.aws_region)}"
    }
}


