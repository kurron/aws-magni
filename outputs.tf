
output "docker_id" {
  value = "${aws_instance.docker.count.index.id}"
}

output "docker_az" {
  value = "${aws_instance.docker.docker.count.availability_zone}"
}

output "docker_key" {
  value = "${aws_instance.docker.docker.count.key_name}"
}

output "docker_private_ip" {
  value = "${aws_instance.docker.docker.count.private_ip}"
}

output "docker_public_dns" {
  value = "${aws_instance.docker.docker.count.public_dns}"
}

output "docker_public_ip" {
  value = "${aws_instance.docker.docker.count.public_ip}"
}

output "docker_subnet_id" {
  value = "${aws_instance.docker.docker.count.subnet_id}"
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

output "website_id" {
  value = "${aws_s3_bucket.web-site.id}"
}

output "website_hosted_zone_id" {
  value = "${aws_s3_bucket.web-site.hosted_zone_id}"
}

output "website_region" {
  value = "${aws_s3_bucket.web-site.region}"
}

output "website_endpoint" {
  value = "${aws_s3_bucket.web-site.website_endpoint}"
}

output "sqs_id" {
  value = "${aws_sqs_queue.example_queue.id}"
}

output "sqs_arn" {
  value = "${aws_sqs_queue.example_queue.arn}"
}

output "sns_id" {
  value = "${aws_sns_topic.example_topic.id}"
}


output "sns_arn" {
  value = "${aws_sns_topic.example_topic.arn}"
}

output "mysql_id" {
  value = "${aws_db_instance.mysql.id}"
}

output "mysql_address" {
  value = "${aws_db_instance.mysql.address}"
}

output "mysql_storage" {
  value = "${aws_db_instance.mysql.allocated_storage}"
}

output "mysql_az" {
  value = "${aws_db_instance.mysql.availability_zone}"
}

output "mysql_backup_retention_period" {
  value = "${aws_db_instance.mysql.backup_retention_period}"
}

output "mysql_backup_window" {
  value = "${aws_db_instance.mysql.backup_window}"
}

output "mysql_endpoint" {
  value = "${aws_db_instance.mysql.endpoint}"
}

output "mysql_engine" {
  value = "${aws_db_instance.mysql.engine}"
}

output "mysql_engine_version" {
  value = "${aws_db_instance.mysql.engine_version}"
}

output "mysql_instance_class" {
  value = "${aws_db_instance.mysql.instance_class}"
}

output "mysql_maintenance_windows" {
  value = "${aws_db_instance.mysql.maintenance_window}"
}

output "mysql_multi_az" {
  value = "${aws_db_instance.mysql.multi_az}"
}

output "mysql_name" {
  value = "${aws_db_instance.mysql.name}"
}

output "mysql_port" {
  value = "${aws_db_instance.mysql.port}"
}

output "mysql_status" {
  value = "${aws_db_instance.mysql.status}"
}

output "mysql_username" {
  value = "${aws_db_instance.mysql.username}"
}

output "mysql_storage_encrypted" {
  value = "${aws_db_instance.mysql.storage_encrypted}"
}

#output "nginx_image" {
# value = "${docker_image.nginx.latest}"
#}

