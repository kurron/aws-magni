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
#    provisioner "local-exec" {
#        command = "./provision-instance.sh ${self.public_ip} ${lookup(var.key_path, var.aws_region)}"
#    }
}

resource "aws_security_group" "elb" {
    name = "elb"
    description = "Firewall rules for the load balancer"

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 65535
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags {
        realm = "experimental"
        created-by = "Terraform"
        direction = "bi-dierectional"
        purpose = "application"
    }
}

resource "aws_elb" "load-balancer" {
    name = "load-balancer"
    availability_zones = ["${aws_instance.docker.*.availability_zone}"] 

    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:80/operations/health"
        interval = 30
    }

    tags {
        realm = "experimental"
        created-by = "Terraform"
    }

    instances = ["${aws_instance.docker.*.id}"]
    security_groups = ["${aws_security_group.elb.id}"]
    cross_zone_load_balancing = true
    idle_timeout = 400
    connection_draining = true
    connection_draining_timeout = 400
}

