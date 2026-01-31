# 1. The Control Plane

resource "aws_eks_cluster" "main" {

  name = "secure-doc-cluster"

  role_arn = aws_iam_role.eks_cluster_role.arn



  vpc_config {

    subnet_ids = [

      aws_subnet.eks_subnet_1.id,

      aws_subnet.eks_subnet_2.id

    ]

  }



  depends_on = [

    aws_iam_role_policy_attachment.eks_cluster_policy

  ]

}



# 2. The Worker Nodes (EC2s)

resource "aws_eks_node_group" "main" {

  cluster_name = aws_eks_cluster.main.name

  node_group_name = "standard-workers"

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = [

    aws_subnet.eks_subnet_1.id,

    aws_subnet.eks_subnet_2.id

  ]



  scaling_config {

    desired_size = 2

    max_size = 3

    min_size = 1

  }



  instance_types = ["t3.small"]

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  depends_on = [

    aws_iam_role_policy_attachment.eks_worker_node_policy,

    aws_iam_role_policy_attachment.eks_cni_policy,

    aws_iam_role_policy_attachment.ecr_read_only,

    aws_iam_role_policy_attachment.s3_access
  ]

}

resource "aws_launch_template" "eks_nodes" {

  name = "secure-doc-node-template"



  metadata_options {

    http_endpoint = "enabled"

    http_tokens = "required"

    http_put_response_hop_limit = 2 # <--- THE MAGIC FIX (Allows Pods to reach Metadata)

    instance_metadata_tags = "enabled"

  }



  # Optional: Tagging

  tag_specifications {

    resource_type = "instance"

    tags = {

      Name = "secure-doc-worker-node"

    }

  }

}
