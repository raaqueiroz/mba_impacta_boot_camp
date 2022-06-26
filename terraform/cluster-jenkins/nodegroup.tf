resource "aws_eks_node_group" "jenkins_node_group" {
  cluster_name    = aws_eks_cluster.jenkins_eks.name
  node_group_name = "${var.eks_name}_group_01"
  node_role_arn   = var.role_arn
  subnet_ids      = [data.terraform_remote_state.vpc.outputs.private_subnets[0]]

  capacity_type   = var.nodegroup_capacity_type
  disk_size       = var.nodegroup_disk_size
  instance_types  = var.nodegroup_instance_types

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Environment = "BootCamp"
    Terraform   = "true"
  }
}