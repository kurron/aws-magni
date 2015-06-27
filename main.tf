provider "aws" {
    region = "${var.aws_region}"
    max_retries = 10
}

resource "aws_vpc" "asgard" {
    cidr_block = "10.10.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags {
        realm = "experimental"
        created-by = "Terraform"
        purpose = "application"
    }
}

resource "aws_internet_gateway" "gateway" {
    vpc_id = "${aws_vpc.asgard.id}"

    tags {
        realm = "experimental"
        created-by = "Terraform"
        purpose = "application"
    }
}

resource "aws_subnet" "zone-subnet" {
    count = 4 
    availability_zone = "${lookup(var.availability_zones, count.index)}" 
    cidr_block = "${lookup(var.subnets, count.index)}"
    map_public_ip_on_launch = true
    vpc_id = "${aws_vpc.asgard.id}"

    tags {
        realm = "experimental"
        created-by = "Terraform"
        purpose = "application"
    }
}

resource "aws_security_group" "docker-host" {
    name = "docker-host"
    description = "Firewall rules to allow provisioning and application deployment"

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

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

resource "aws_instance" "docker" {
    connection {
        user = "ubuntu"
        key_file = "${lookup(var.key_path, var.aws_region)}"
    }

    count = "${var.docker_instance_count}"
    ami = "${lookup(var.aws_amis, var.aws_region)}"
    availability_zone = "${lookup(var.availability_zones, count.index)}"
    instance_type = "${var.instance_type}"
    key_name = "${lookup(var.key_name, var.aws_region)}"
#   security_groups = ["${aws_security_group.docker-host.name}"]
    subnet_id = "${element( aws_subnet.zone-subnet.*.id, count.index )}"

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

resource "aws_elb" "load-balancer" {
    name = "load-balancer"
    subnets = ["${aws_subnet.zone-subnet.*.id}"] 
    instances = ["${aws_instance.docker.*.id}"]
#   security_groups = ["${aws_security_group.elb.id}"]
    cross_zone_load_balancing = true
    idle_timeout = 400
    connection_draining = true
    connection_draining_timeout = 400

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
}

resource "aws_elasticache_subnet_group" "redis" {
    description = "Subnet group for the Redis cluster"
    name = "redis-cluster"
    subnet_ids = ["${aws_subnet.zone-subnet.*.id}"]
}

resource "aws_elasticache_cluster" "redis" {
    cluster_id = "asgard"
    engine = "redis"
    engine_version = "2.8.19"
    node_type = "cache.t2.micro"
    num_cache_nodes = 1
    parameter_group_name = "default.redis2.8"
    port = 6379
    subnet_group_name = "${aws_elasticache_subnet_group.redis.name}" 
#   security_group_ids = ["${aws_security_group.redis.id}"]
    tags {
        realm = "experimental"
        created-by = "Terraform"
    }
}
