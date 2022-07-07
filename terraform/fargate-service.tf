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
           "hostPort":3000,
           "protocol": "tcp"
        }
     ]
  }
]
DEFINITION

}

resource "aws_ecs_service" "demo" {
  name            = var.project_name
  cluster         = aws_ecs_cluster.main_cluster.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.demo.arn
  launch_type     = "FARGATE"
  depends_on      = [aws_lb_listener.demo]

  deployment_controller {
    type = "ECS" #"CODE_DEPLOY"
  }

  network_configuration {
    subnets          = slice(module.vpc.public_subnets, 1, 2)
    security_groups  = [aws_security_group.ecs-instance-sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.demo.id
    container_name   = var.ecr_repo_name
    container_port   = 3000
  }
  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}
# logs
resource "aws_cloudwatch_log_group" "demo" {
  name = var.project_name
}
