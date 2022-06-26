module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = "10.13.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.13.1.0/24", "10.13.2.0/24", "10.13.3.0/24"]
  public_subnets  = ["10.13.101.0/24", "10.13.102.0/24", "10.13.103.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
  
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  tags = {
    Terraform = "true"
    Environment = "BootCamp"
  }
}