# --- 1. Cluster Role (Control Plane) ---

resource "aws_iam_role" "eks_cluster_role" {

  name = "secure-doc-eks-cluster-role"



  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [{

      Action = "sts:AssumeRole"

      Effect = "Allow"

      Principal = { Service = "eks.amazonaws.com" }

    }]

  })

}



resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

  role = aws_iam_role.eks_cluster_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}



# --- 2. Node Group Role (Worker Nodes) ---

resource "aws_iam_role" "eks_node_role" {

  name = "secure-doc-eks-node-role"



  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [{

      Action = "sts:AssumeRole"

      Effect = "Allow"

      Principal = { Service = "ec2.amazonaws.com" }

    }]

  })

}



# Attachments required for Worker Nodes to work

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {

  role = aws_iam_role.eks_node_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

}



resource "aws_iam_role_policy_attachment" "eks_cni_policy" {

  role = aws_iam_role.eks_node_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

}



resource "aws_iam_role_policy_attachment" "ecr_read_only" {

  role = aws_iam_role.eks_node_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}



# --- 3. CUSTOM: S3 Access for your App ---

resource "aws_iam_role_policy_attachment" "s3_access" {

  role = aws_iam_role.eks_node_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"

}
