# security group
resource "aws_security_group" "ecs-lb-sg" {
  name        = "${var.project_name}-ecs-lb-sg"
  vpc_id      = module.vpc.vpc_id
  description = "ECS ${var.project_name}"

}

resource aws_security_group_rule "lb_ingress_https" {
  from_port         = 443
  protocol          = "TCP"
  security_group_id = aws_security_group.ecs-lb-sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port           = 443
  type              = "ingress"
}

resource aws_security_group_rule "lb_ingress_http" {
  from_port         =  80
  protocol          = "TCP"
  security_group_id = aws_security_group.ecs-lb-sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port           = 80
  type              = "ingress"
}

resource aws_security_group_rule "lb_egress_https" {

  from_port         = 3000
  protocol          = "TCP"
  security_group_id = aws_security_group.ecs-lb-sg.id
  source_security_group_id = aws_security_group.ecs-instance-sg.id
  to_port           = 3000
  type              = "egress"
}

# security group
resource "aws_security_group" "ecs-instance-sg" {
  name        = "${var.project_name}-ecs-instance-sg"
  vpc_id      = module.vpc.vpc_id
  description = "ECS ${var.project_name}"

}
  resource aws_security_group_rule "instance_ingress_check" {

    from_port         = 443
    protocol          = "tcp"
    security_group_id = aws_security_group.ecs-instance-sg.id
    source_security_group_id = aws_security_group.ecs-lb-sg.id
    to_port           = 443
    type              = "ingress"
  }
resource aws_security_group_rule "instance_ingress_healthcheck" {

  from_port         = 3000
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs-instance-sg.id
  source_security_group_id = aws_security_group.ecs-lb-sg.id
  to_port           = 3000
  type              = "ingress"
}



resource aws_security_group_rule "instance_egress_https" {

  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs-instance-sg.id
  cidr_blocks = ["0.0.0.0/0"]
  to_port           = 0
  type              = "egress"
}
