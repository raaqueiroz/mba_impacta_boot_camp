resource "aws_eks_cluster" "jenkins_eks" {
  name     = var.eks_name
  role_arn = var.role_arn

  vpc_config {
    subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets
  }

  tags = {
    Environment = "BootCamp"
    Terraform   = "true"
  }
}