resource "aws_ecs_cluster" "this" {
  name = "${var.cluster_name}-${var.env}"
  setting {
    name  = "containerInsights"
    value = var.env == "prod" ? "enabled" : "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = var.env == "prod" ? "FARGATE" : "FARGATE_SPOT"
  }
}

resource "aws_iam_role" "task_execution" {
  name = "ecs-execution-role-${var.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg-${var.env}"
  vpc_id      = var.vpc_id
  description = "Security group for ECS Tasks"

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"] # Internal VPC traffic only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.service_name}-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name      = var.service_name
    image     = var.container_image
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
  }])
}

resource "aws_ecs_service" "this" {
  name            = "${var.service_name}-${var.env}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = var.env == "prod" ? "FARGATE" : "FARGATE_SPOT"
    weight            = 100
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.subnet_ids
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
