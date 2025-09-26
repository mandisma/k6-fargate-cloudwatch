#-----------------------------
# Networking
#-----------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "k6-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "k6-igw" }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 0)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "k6-public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 1)
  availability_zone       = length(data.aws_availability_zones.available.names) > 1 ? data.aws_availability_zones.available.names[1] : data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "k6-public-b" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "k6-public-rt" }
}

resource "aws_route" "public_inet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "task" {
  name        = "k6-fargate-sg"
  description = "Security group for k6 Fargate tasks"
  vpc_id      = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "k6-fargate-sg" }
}

#-----------------------------
# ECR
#-----------------------------
resource "aws_ecr_repository" "k6" {
  name                 = "custom-k6"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = { Name = "custom-k6" }
}

#-----------------------------
# ECS Cluster
#-----------------------------
resource "aws_ecs_cluster" "this" {
  name = "K6Cluster"
}

#-----------------------------
# IAM Roles
#-----------------------------
resource "aws_iam_role" "execution" {
  name               = "ecsTaskExecutionRole-k6"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

resource "aws_iam_role_policy_attachment" "execution_ssm" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "execution_cwagent" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "execution_ecs" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "ecsTaskRole-k6"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}

resource "aws_iam_role_policy_attachment" "task_cwagent" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

#-----------------------------
# SSM Parameter for CloudWatch Agent config
#-----------------------------
resource "aws_ssm_parameter" "cwagent_config" {
  name  = "ecs-cwagent-sidecar-fargate"
  type  = "String"
  value = <<JSON
{
    "metrics": {
        "namespace": "k6",
        "metrics_collected": {
            "statsd": {
                "service_address": ":8125",
                "metrics_collection_interval": 1,
                "metrics_aggregation_interval": 0
            }
        }
    }
}
JSON
}

#-----------------------------
# CloudWatch Logs
#-----------------------------
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${aws_ecs_cluster.this.name}"
  retention_in_days = 7
}

#-----------------------------
# Task Definition
#-----------------------------
locals {
  k6_image = "${aws_ecr_repository.k6.repository_url}:latest"
}

resource "aws_ecs_task_definition" "k6" {
  family                   = "K6Task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "16384"
  memory                   = "65536"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "k6"
      image     = local.k6_image
      essential = true
      ulimits = [{
        name      = "nofile"
        hardLimit = 32768
        softLimit = 8192
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = aws_ecs_cluster.this.name
        }
      }
    },
    {
      name      = "cloudwatch-agent"
      image     = "amazon/cloudwatch-agent:latest"
      essential = true
      secrets = [{
        name      = "CW_CONFIG_CONTENT"
        valueFrom = aws_ssm_parameter.cwagent_config.arn
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = aws_ecs_cluster.this.name
        }
      }
    }
  ])
}

resource "aws_cloudwatch_dashboard" "k6" {
  dashboard_name = "k6"
  dashboard_body = templatefile("${path.module}/cloudwatch-metrics-dashboard/dashboard.json.tftpl", { region = var.region })
}
