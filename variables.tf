variable "secretkey" {
    type = string
  }

  variable "accesskey" {
    type = string
    
  }

  variable "instance_type" {
    description = "Type of EC2 instance to provision"
    default     = "t2.micro"
  }
