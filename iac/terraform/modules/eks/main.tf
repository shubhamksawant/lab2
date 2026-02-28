# IAM Role for EKS Cluster
resource "aws_iam_role" "cluster_role" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "eks.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

# EKS Cluster (Private Access Only)
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false # Internal Security via LoadBalancer only
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

# IAM OIDC Provider for fine-grained permissions
data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# IAM Role for Managed Node Groups
resource "aws_iam_role" "node_role" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

# Node Worker Policies + EBS CSI Driver Support
resource "aws_iam_role_policy_attachment" "node_policy_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}
resource "aws_iam_role_policy_attachment" "node_policy_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}
resource "aws_iam_role_policy_attachment" "node_policy_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

# Correct IRSA (Least Privilege) for the EBS CSI Driver
data "aws_iam_policy_document" "ebs_csi_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name               = "${var.cluster_name}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_trust.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Node Group 1: On-Demand (t3.micro)
resource "aws_eks_node_group" "on_demand" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-on-demand"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = var.on_demand_desired_size
    max_size     = 5
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy_worker,
    aws_iam_role_policy_attachment.node_policy_cni,
    aws_iam_role_policy_attachment.node_policy_registry
  ]
}

# Node Group 2: Spot Instances (Type passed via variable)
resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-spot"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids

  capacity_type  = "SPOT"
  instance_types = [var.spot_instance_type] 

  scaling_config {
    desired_size = var.spot_desired_size
    max_size     = 5
    min_size     = var.spot_min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy_worker,
    aws_iam_role_policy_attachment.node_policy_cni,
    aws_iam_role_policy_attachment.node_policy_registry
  ]
}

# Dynamic EKS Add-ons
resource "aws_eks_addon" "addons" {
  for_each = { for addon in var.eks_addons : addon.name => addon }

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.value.name
  addon_version               = each.value.version
  resolve_conflicts_on_update = "PRESERVE"
  resolve_conflicts_on_create = "OVERWRITE"
  
  # Inject IRSA precisely for the CSI driver
  service_account_role_arn = each.value.name == "aws-ebs-csi-driver" ? aws_iam_role.ebs_csi_role.arn : null

  depends_on = [
    aws_eks_node_group.on_demand,
    aws_eks_node_group.spot
  ]
}

# Default Storage Class for ebs-csi
resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  # Prevents Provider initialization failure by forcing strict chronological execution
  depends_on = [
    aws_eks_cluster.this,
    aws_eks_addon.addons,
    aws_eks_node_group.on_demand # Ensure nodes actually exist to receive the driver
  ]
}
