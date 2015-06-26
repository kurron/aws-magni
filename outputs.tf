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

