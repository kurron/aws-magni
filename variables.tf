variable "aws_region" {
    description = "AWS region to launch servers."
    default = "us-east-1"
}

variable "resource_group" {
    description = "What group we should tag all of the resources with."
    default = "Asgard Experiment"
}

variable "resource_owner" {
    description = "What organization owns the resource."
    default = "Asgard Team"
}

variable "resource_purpose" {
    description = "What is the purpose of the resource."
    default = "Operations Experimentation"
}

variable "resource_status" {
    description = "Should the resource be considered stable or unstable (a work in progress)."
    default = "Unstable"
}

variable "resource_provisioned_by" {
    description = "The tool that was used to provision the resource."
    default = "Terraform"
}

variable "instance_type" {
    description = "AWS EC2 instance type."
    default = "t2.micro"
}

variable "az_count" {
    description = "How many availability zones to target."
    default = 4 
}

variable "key_name" {
    description = "Name of the SSH keypair to use in AWS."
    default = {
        us-east-1      = "us-east-1"
        us-west-1      = "us-west-1"
        us-west-2      = "us-west-2"
        eu-west-1      = "eu-west-1"
        eu-central-1   = "eu-central-1"
        sa-east-1      = "sa-east-1"
        ap-southeast-1 = "ap-southeast-1"
        ap-southeast-2 = "ap-southeast-2"
        ap-northeast-1 = "ap-northeast-1"
    }
}

variable "key_path" {
    description = "Path to the private portion of the SSH key specified."
    default = {
        us-east-1      = "/home/vagrant/aws/us-east-1.pem"
        us-west-1      = "/home/vagrant/aws/us-west-1.pem"
        us-west-2      = "/home/vagrant/aws/us-west-2.pem"
        eu-west-1      = "/home/vagrant/aws/eu-west-1.pem"
        eu-central-1   = "/home/vagrant/aws/eu-central-1.pem"
        sa-east-1      = "/home/vagrant/aws/sa-east-1.pem"
        ap-southeast-1 = "/home/vagrant/aws/ap-southeast-1.pem"
        ap-southeast-2 = "/home/vagrant/aws/ap-southeast-2.pem"
        ap-northeast-1 = "/home/vagrant/aws/ap-northeast-1.pem"
    }
}

# Ubuntu Server 14.04 LTS (HVM), SSD Volume Type, 64-bit 
variable "aws_amis" {
    description = "AMI to build the instance from."
    default = {
        us-east-1      = "ami-47d5102c"
        us-west-1      = "ami-df6a8b9b"
        us-west-2      = "ami-5189a661"
        eu-west-1      = "ami-47a23a30"
        eu-central-1   = "ami-accff2b1"
        sa-east-1      = "ami-4d883350"
        ap-southeast-1 = "ami-96f1c1c4"
        ap-southeast-2 = "ami-69631053"
        ap-northeast-1 = "ami-936d9d93"
    }
}

variable "availability_zones" {
    description = "The availability zone to place the Docker host in."
    default = {
        "0"      = "us-east-1a"
        "1"      = "us-east-1b"
        "2"      = "us-east-1d"
        "3"      = "us-east-1e"
    }
}

variable "subnets" {
    description = "The subnet masks to use for each availability zone"
    default = {
        "0"      = "10.10.10.0/24"
        "1"      = "10.10.20.0/24"
        "2"      = "10.10.30.0/24"
        "3"      = "10.10.40.0/24"
    }
}


