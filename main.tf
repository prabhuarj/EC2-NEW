data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_filter.owner] # Bitnami
}

resource "aws_instance" "vm" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  subnet_id              = module.blog_vpc.public_subnets[0]
  vpc_security_group_ids = [module.sg.security_group_id]

  tags = {
    Name = "prabhuvm"
  }
}

module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.environment.name
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  public_subnets  = ["${var.environment.network_prefix}.101.0/24", "${var.environment.network_prefix}.102.0/24", "${var.environment.network_prefix}.103.0/24"]


  tags = {
    Terraform = "true"
    Environment = var.environment.name
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.8.0"

  name    = "blog-alb"
  load_balancer_type = "application"

  vpc_id  = module.blog_vpc.vpc_id
  subnets = module.blog_vpc.public_subnets
  security_groups    = [module.sg.security_group_id]

  listeners = {
    ex-http = {
      port     = 80
      protocol = "HTTP"
      
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix      = "h1"
      protocol         = "HTTP"
      port             = 80
      target_type      = "instance"
      target_id        = aws_instance.vm.id
    }
  }

  tags = {
    Environment = "Dev"
    Project     = "Env"
  }
}


module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"
  vpc_id = module.blog_vpc.vpc_id
  name = "blog_new"

  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}




