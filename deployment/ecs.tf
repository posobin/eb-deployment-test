resource "aws_vpc" "main" {
  cidr_block = "172.17.0.0/16"
}

resource "aws_subnet" "public" {
  cidr_block = "172.17.0.0/24"
  vpc_id     = aws_vpc.main.id
}

# IGW for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_security_group" "ecs_tasks" {
  name        = "eb-deployment-test-ecs-tasks"
  description = "allow all access to the ecs container"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_ecs_cluster" "worker" {
  name = "eb-deployment-ecs"
}

resource "aws_ecs_task_definition" "worker" {
  family = "eb-deployment-worker"
  container_definitions = file("ecs_container_definition.json")
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.fargate.arn
  cpu = "512"
  memory = "1024"
}

resource "aws_ecs_service" "worker" {
  name = "eb-deployment-worker"
  cluster = aws_ecs_cluster.worker.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count = 1
  network_configuration {
    subnets = [aws_subnet.public.id]
    security_groups = [aws_security_group.ecs_tasks.id]
  }
}
