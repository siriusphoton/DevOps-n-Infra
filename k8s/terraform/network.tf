# 1. Dedicated VPC for Kubernetes

resource "aws_vpc" "eks_vpc" {

  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true

  enable_dns_support = true

  tags = { Name = "eks-vpc" }

}



# 2. Subnets (EKS needs at least 2 AZs)

resource "aws_subnet" "eks_subnet_1" {

  vpc_id = aws_vpc.eks_vpc.id

  cidr_block = "10.0.1.0/24"

  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true



  tags = {

    Name = "eks-subnet-1"

    "kubernetes.io/cluster/secure-doc-cluster" = "shared" # Required for EKS

    "kubernetes.io/role/elb" = "1" # Required for Load Balancers

  }

}



resource "aws_subnet" "eks_subnet_2" {

  vpc_id = aws_vpc.eks_vpc.id

  cidr_block = "10.0.2.0/24"

  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true



  tags = {

    Name = "eks-subnet-2"

    "kubernetes.io/cluster/secure-doc-cluster" = "shared"

    "kubernetes.io/role/elb" = "1"

  }

}



# 3. Internet Gateway & Routing

resource "aws_internet_gateway" "eks_igw" {

  vpc_id = aws_vpc.eks_vpc.id

}



resource "aws_route_table" "eks_rt" {

  vpc_id = aws_vpc.eks_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.eks_igw.id

  }

}



resource "aws_route_table_association" "a" {

  subnet_id = aws_subnet.eks_subnet_1.id

  route_table_id = aws_route_table.eks_rt.id

}



resource "aws_route_table_association" "b" {

  subnet_id = aws_subnet.eks_subnet_2.id

  route_table_id = aws_route_table.eks_rt.id

}
