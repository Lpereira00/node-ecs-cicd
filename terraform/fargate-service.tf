resource "aws_ecs_task_definition" "demo" {
  family             = var.project_name
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn      = aws_iam_role.ecs-demo-task-role.arn
  cpu                = 256
  memory             = 512
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]

  container_definitions = <<DEFINITION
[
  {
    "essential": true,
    "image": "${aws_ecr_repository.main_repository.repository_url}",
    "name": "${var.ecr_repo_name}",
    "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
               "awslogs-create-group": "true",
               "awslogs-group" : "${var.project_name}",
               "awslogs-region": "${var.aws_region}",
               "awslogs-stream-prefix": "ecs"
            }
     },
     "secrets": [],
     "environmentFiles" : [
        ],
     "environment": [],
     "portMappings": [
        {
           "containerPort": 3000,
           "hostPort": 3000
        }
     ]
  }
]
DEFINITION

}

resource "aws_ecs_service" "demo" {
  name            = var.project_name
  cluster         = aws_ecs_cluster.main_cluster.id
  desired_count   = 0
  task_definition = aws_ecs_task_definition.demo.arn
  launch_type     = "FARGATE"
  depends_on      = [aws_lb_listener.demo]

  deployment_controller {
    type = "ECS" #"CODE_DEPLOY"
  }

  network_configuration {
    subnets          = slice(module.vpc.private_subnets, 1, 2)
    security_groups  = [aws_security_group.ecs-demo.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.demo.id
    container_name   = var.ecr_repo_name
    container_port   = 3000
  }
  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer
    ]
  }
}

# security group
resource "aws_security_group" "ecs-demo" {
  name        = "${var.project_name}-ecs-sg"
  vpc_id      = module.vpc.vpc_id
  description = "ECS ${var.project_name}"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  egress {
    from_port = 443
    to_port   = 443
    protocol  = "TCP"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

# logs
resource "aws_cloudwatch_log_group" "demo" {
  name = var.project_name
}
