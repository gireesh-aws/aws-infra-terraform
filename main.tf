terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Network Layer: Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# 2. Subnet Layer: Public Tier (Web Frontends / Bastion) & Private Tier (Apps / DBs)
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = { Name = "${var.environment}-public-subnet-1a" }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${var.aws_region}a"

  tags = { Name = "${var.environment}-private-subnet-1a" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "${var.aws_region}b"

  tags = { Name = "${var.environment}-private-subnet-1b" }
}

# 3. Internet Gateway for Public Routing
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "${var.environment}-public-rt" }
}

resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

# 4. Security Subnets: Firewall Rules for Compute Instances
resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-web-security-group"
  description = "Allow inbound HTTP web traffic vectors"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. Compute Layer: Auto Scaling Group Template
resource "aws_launch_template" "web_template" {
  name_prefix   = "${var.environment}-web-template-"
  image_id      = "ami-0c7217cdde317cfec" # Standard Amazon Linux 2 AMI
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Enterprise Cluster Running on AWS via Terraform</h1>" > /var/www/html/index.html
              EOF
  )
}

resource "aws_autoscaling_group" "web_asg" {
  vpc_zone_identifier = [aws_subnet.public_1.id]
  desired_capacity    = 2
  max_size            = 4
  min_size            = 1

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
}

# 6. Database Layer: Isolated Private RDS MySQL Instance
resource "aws_db_subnet_group" "db_subnets" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "production_db"
  username             = "cloud_admin"
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.db_subnets.name
  skip_final_snapshot  = true
}