env                    = "prod"
spot_instance_type     = "t3.medium"
spot_min_size          = 2
spot_desired_size      = 5
on_demand_desired_size = 3

eks_addons = [
  { name = "vpc-cni", version = "v1.16.0-eksbuild.1" },
  { name = "kube-proxy", version = "v1.29.0-eksbuild.1" },
  { name = "aws-ebs-csi-driver", version = "v1.28.0-eksbuild.1" },
  { name = "coredns", version = "v1.11.1-eksbuild.4" }
]
