resource "aws_efs_file_system" "jenkins_efs" {
  creation_token = var.efs_token

  tags = {
    Environment = "BootCamp"
    Terraform   = "true"
  }
}

resource "aws_efs_mount_target" "jenkins_efs_mount" {
  file_system_id = aws_efs_file_system.jenkins_efs.id
  subnet_id      = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  security_groups = [aws_eks_cluster.jenkins_eks.vpc_config[0].cluster_security_group_id]
}