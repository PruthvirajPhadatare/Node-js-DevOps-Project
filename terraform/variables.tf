variable "region" {
  default = "ap-south-1"
}

variable "cluster_name" {
  default = "devops-project-eks"
}

variable "node_group_name" {
  default = "devops-project-node-group"
}

variable "node_instance_type" {
  default = "t2.micro"
}

variable "desired_capacity" {
  default = 1
}

variable "min_size" {
  default = 1
}

variable "max_size" {
  default = 1
}

variable "ssh_key_name" {
  description = "SSH key for EC2 nodes"
  default     = "mumbai"
}
