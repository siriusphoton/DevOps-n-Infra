# 1. NETWORK (VPC)

resource "aws_vpc" "main" {

  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true

  tags = { Name = "${var.project_name}-vpc" }

}



resource "aws_subnet" "public" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true

  availability_zone = "us-east-1a"

}

# Add this under your existing subnet

resource "aws_subnet" "public_2" {

  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.2.0/24"

  map_public_ip_on_launch = true

  availability_zone = "us-east-1b" # Different AZ

}


resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.main.id

}



resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.gw.id

  }

}



resource "aws_route_table_association" "public_assoc" {

  subnet_id = aws_subnet.public.id

  route_table_id = aws_route_table.public_rt.id

}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}


# 2. SECURITY GROUP (Firewall)

resource "aws_security_group" "web_sg" {

  name = "web-server-sg"

  description = "Allow SSH and HTTP"

  vpc_id = aws_vpc.main.id


  /*
  ingress {

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"] # Open SSH (In real life, restrict this IP)

  }
*/


  ingress {

    from_port = 5000

    to_port = 5000

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"] # Flask App Port

  }



  egress { # Allow server to talk to S3/Internet

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}



# 3. SSH KEY GENERATION

resource "tls_private_key" "pk" {

  algorithm = "RSA"

  rsa_bits = 4096

}



resource "aws_key_pair" "kp" {

  key_name = "my-key"

  public_key = tls_private_key.pk.public_key_openssh

}



resource "local_file" "ssh_key" {

  content = tls_private_key.pk.private_key_pem

  filename = "${path.module}/private_key.pem"

  file_permission = "0400"

}



# 4. COMPUTE (EC2)

resource "aws_instance" "web" {

  count = 2
  ami   = "ami-0b6c6ebed2801a5cb" # Ubuntu 22.04 LTS (US-East-1)

  instance_type = "t3.micro"

  subnet_id = aws_subnet.public.id



  # ATTACH SECURITY & IDENTITY

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  iam_instance_profile = "ec2-s3-profile" # Defined in iam.tf (Project 23)

  key_name = aws_key_pair.kp.key_name



  tags = {
    Name = "${var.project_name}-Server-${count.index + 1}" # Names them Server-1, Server-2
  }

}



# 5. OUTPUTS

output "instance_summary" {

  value = {

    for i in range(length(aws_instance.web)) :

    aws_instance.web[i].id => aws_instance.web[i].public_ip

  }

}
