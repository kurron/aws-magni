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
        Name = "Asgard Cloud"
        Group = "${var.resource_group}"
        Owner = "${var.resource_owner}"
        Purpose = "Cloud to hold the Asgard assets"
        Provisioner = "${var.resource_provisioned_by}"
        Status = "${var.resource_status}"
    }
}

resource "aws_internet_gateway" "gateway" {
    vpc_id = "${aws_vpc.asgard.id}"

    tags {
        Name = "Asgard Gateway"
        Group = "${var.resource_group}"
        Owner = "${var.resource_owner}"
        Purpose = "Internet gateway in and out of the VPC"
        Provisioner = "${var.resource_provisioned_by}"
        Status = "${var.resource_status}"
    }
}

resource "aws_route_table" "internet" {
    vpc_id = "${aws_vpc.asgard.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gateway.id}"
    }

    tags {
        Name = "Asgard Gateway Route"
        Group = "${var.resource_group}"
        Owner = "${var.resource_owner}"
        Purpose = "Use the gateway to access the internet"
        Provisioner = "${var.resource_provisioned_by}"
        Status = "${var.resource_status}"
    }
}

resource "aws_subnet" "zone-subnet" {
    count = "${var.az_count}" 
    availability_zone = "${lookup(var.availability_zones, count.index)}" 
    cidr_block = "${lookup(var.subnets, count.index)}"
    map_public_ip_on_launch = true
    vpc_id = "${aws_vpc.asgard.id}"

    tags {
        Name = "Change Me"
        Group = "${var.resource_group}"
        Owner = "${var.resource_owner}"
        Purpose = "Change Me"
        Provisioner = "${var.resource_provisioned_by}"
        Status = "${var.resource_status}"
    }
}

resource "aws_network_acl" "asgard" {
    vpc_id = "${aws_vpc.asgard.id}"
    subnet_ids = ["${aws_subnet.zone-subnet.*.id}"]

    egress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 0
        to_port = 65535
    }

    ingress {
        protocol = "tcp"
        rule_no = 100
        action = "allow"
        cidr_block =  "0.0.0.0/0"
        from_port = 22
        to_port = 22
    }

    tags {
        Name = "Default firewall rules"
        Group = "${var.resource_group}"
        Owner = "${var.resource_owner}"
        Purpose = "Subnet firewall rules"
        Provisioner = "${var.resource_provisioned_by}"
        Status = "${var.resource_status}"
    }
}

resource "aws_security_group" "docker" {
    name = "docker"
    description = "Firewall rules for the Docker hosts"
    vpc_id = "${aws_vpc.asgard.id}"
    
    ingress {
      from_port = 22
      to_port = 22 
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
        Name = "Docker Firewall Rules"
        Group = "${var.resource_group}"
        Owner = "${var.resource_owner}"
        Purpose = "Controls port access to the Docker containers"
        Provisioner = "${var.resource_provisioned_by}"
        Status = "${var.resource_status}"
    }
}

resource "aws_route_table_association" "subnet-route" {
    count = "${var.az_count}" 
    subnet_id = "${element( aws_subnet.zone-subnet.*.id, count.index )}"
    route_table_id = "${aws_route_table.internet.id}"
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
    tags {
        Name = "Redis Cluster"
        Group = "${var.resource_group}"
        Owner = "${var.resource_owner}"
        Purpose = "Provides fault-tolerant Redis instances"
        Provisioner = "${var.resource_provisioned_by}"
        Status = "${var.resource_status}"
    }
}

resource "aws_instance" "docker" {
    connection {
        user = "ubuntu"
        key_file = "${lookup(var.key_path, var.aws_region)}"
    }

    # put one instance in each AZ
    count = "${var.az_count}"
    ami = "${lookup(var.aws_amis, var.aws_region)}"
    availability_zone = "${element( aws_subnet.zone-subnet.*.availability_zone, count.index )}"
    instance_type = "${var.instance_type}"
    key_name = "${lookup(var.key_name, var.aws_region)}"
    vpc_security_group_ids = ["${aws_security_group.docker.id}"]
    subnet_id = "${element( aws_subnet.zone-subnet.*.id, count.index )}"

    tags {
        Name = "Docker Host ${count.index}"
        Group = "${var.resource_group}"
        Owner = "${var.resource_owner}"
        Purpose = "Hosts Docker containers"
        Provisioner = "${var.resource_provisioned_by}"
        Status = "${var.resource_status}"
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
    idle_timeout = 60
    connection_draining = true
    connection_draining_timeout = 60

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
        Name = "Asgard Load Balander"
        Group = "${var.resource_group}"
        Owner = "${var.resource_owner}"
        Purpose = "Balances web traffic between instances"
        Provisioner = "${var.resource_provisioned_by}"
        Status = "${var.resource_status}"
    }
}

