variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  default     = "Aryan"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  default     = "my-keypair" # replace with your key pair
}
