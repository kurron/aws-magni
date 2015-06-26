output "docker_security_group_name" {
  value = "${aws_security_group.docker-host.name}"
}

output "docker_security_group_id" {
  value = "${aws_security_group.docker-host.id}"
}

output "docker_security_group_description" {
  value = "${aws_security_group.docker-host.description}"
}

output "docker_security_group_vpc" {
  value = "${aws_security_group.docker-host.vpc_id}"
}

output "docker_id" {
  value = "${aws_instance.docker.count.index.id}"
}

output "docker_az" {
  value = "${aws_instance.docker.count.index.availability_zone}"
}

output "docker_key" {
  value = "${aws_instance.docker.count.index.key_name}"
}

output "docker_private_ip" {
  value = "${aws_instance.docker.count.index.private_ip}"
}

output "docker_public_dns" {
  value = "${aws_instance.docker.count.index.public_dns}"
}

output "docker_public_ip" {
  value = "${aws_instance.docker.count.index.public_ip}"
}

output "docker_subnet_id" {
  value = "${aws_instance.docker.count.index.subnet_id}"
}

output "elb_security_group_name" {
  value = "${aws_security_group.elb.name}"
}

output "elb_security_group_id" {
  value = "${aws_security_group.elb.id}"
}

output "elb_security_group_description" {
  value = "${aws_security_group.elb.description}"
}

output "elb_security_group_vpc" {
  value = "${aws_security_group.elb.vpc_id}"
}

output "elb_id" {
  value = "${aws_elb.load-balancer.id}"
}

output "elb_name" {
  value = "${aws_elb.load-balancer.name}"
}

output "elb_dns_name" {
  value = "${aws_elb.load-balancer.dns_name}"
}

output "elb_instances" {
  value = "${aws_elb.load-balancer.instances}"
}

output "elb_source_security_group" {
  value = "${aws_elb.load-balancer.source_security_group}"
}

output "elb_zone_id" {
  value = "${aws_elb.load-balancer.zone_id}"
}

output "redis_cluster_id" {
  value = "${aws_elasticache_cluster.redis.cluster_id}"
}

output "redis_engine" {
  value = "${aws_elasticache_cluster.redis.engine}"
}

output "redis_engine_version" {
  value = "${aws_elasticache_cluster.redis.engine_version}"
}

output "redis_node_type" {
  value = "${aws_elasticache_cluster.redis.node_type}"
}

output "redis_num_cache_nodes" {
  value = "${aws_elasticache_cluster.redis.num_cache_nodes}"
}

output "redis_parameter_group_name" {
  value = "${aws_elasticache_cluster.redis.paramter_group_name}"
}

output "redis_subnet_group_name" {
  value = "${aws_elasticache_cluster.redis.subnet_group_name}"
}

output "redis_security_group_names" {
  value = "${aws_elasticache_cluster.redis.security_group_names}"
}

output "redis_security_group_ids" {
  value = "${aws_elasticache_cluster.redis.security_group_ids}"
}