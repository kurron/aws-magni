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



