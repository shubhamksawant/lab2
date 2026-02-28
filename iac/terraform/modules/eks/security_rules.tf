resource "aws_security_group_rule" "eks_control_plane_webhook" {
  type                     = "ingress"
  from_port                = 9443
  to_port                  = 9443
  protocol                 = "tcp"
  # Assuming nodes inherit the underlying cluster SG, we open internal paths
  security_group_id        = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description              = "Allow EKS Control Plane to communicate with nodes for CSI admission webhook"
}
