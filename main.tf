# Specify the provider and access details
provider "aws" {
    # we'll source it from AWS_ACCESS_KEY_ID in the environment
#   access_key = "${var.aws_access_key}"
    # we'll source it from AWS_SECRET_ACCESS_KEY in the environment
#   secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
    max_retries = 10
}

resource "aws_s3_bucket" "web-site" {
    bucket = "s3-website-test-kurron-org"
    acl = "public-read"

    tags {
        realm = "experimental"
        created-by = "Terraform"
    }

    website {
        index_document = "index.html"
        error_document = "error.html"
    }
}

resource "aws_sqs_queue" "example_queue" {
    name = "example-queue"
}

resource "aws_sns_topic" "example_topic" {
    name = "example-topic"
}

resource "aws_security_group" "mysql-access" {
    name = "mysql-access"
    description = "Firewall rules to allow public access to MySQL"

    ingress {
      from_port = 3306
      to_port = 3306
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

resource "aws_db_instance" "mysql" {
    count = 1
    identifier = "mysql"
    allocated_storage = 20
    engine = "mysql"
    engine_version = "5.6.23"
    instance_class = "db.t2.micro"
    storage_type = "gp2"
    username = "terraform"
    password = "terraform"
    publicly_accessible = true
    vpc_security_group_ids = ["${aws_security_group.mysql-access.id}"]
    tags {
        realm = "experimental"
        created-by = "Terraform"
    }
}

resource "aws_security_group" "web-access" {
    name = "web-access"
    description = "Firewall rules to allow provisioning and application deployment"

    tags {
        realm = "experimental"
        created-by = "Terraform"
        direction = "bi-dierectional"
        purpose = "application"
    }
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

resource "aws_security_group_rule" "inbound-ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.web-access.id}"
}

#resource "aws_security_group_rule" "inbound-docker" {
#   type = "ingress"
#   from_port = 2375
#   to_port = 2375
#   protocol = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]

#   security_group_id = "${aws_security_group.web-access.id}"
#}

resource "aws_security_group_rule" "inbound-http" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.web-access.id}"
}

resource "aws_security_group_rule" "inbound-https" {
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.web-access.id}"
}

resource "aws_security_group_rule" "allow-all-outbound" {
    type = "egress"
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.web-access.id}"
}

resource "aws_instance" "docker" {
    connection {
        user = "ubuntu"
        key_file = "${lookup(var.key_path, var.aws_region)}"
    }

    count = "${var.docker_instance_count}"
#   count = 1 
    ami = "${lookup(var.aws_amis, var.aws_region)}"
    instance_type = "${var.instance_type}"
    key_name = "${lookup(var.key_name, var.aws_region)}"
    security_groups = ["${aws_security_group.web-access.name}"]

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

#provider "docker" {
#   host = "tcp://${aws_instance.docker.public_ip}:2375/"
#   depends_on = ["aws_instance.docker"]
#}

#resource "docker_image" "nginx" {
#   image = "nginx"
#   keep_updated = true
#}

#resource "docker_container" "nginx" {
#   image = "${docker_image.nginx.latest}"
#   name = "nginx"
#   hostname = "nginx"
#   must_run = true
#   ports {
#       internal = 80
#       external = 80
#   }
#}

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
        target = "HTTP:80/"
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

