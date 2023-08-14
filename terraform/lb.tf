data "aws_acm_certificate" "issued" {
  domain   = "domainneeded.com"
  statuses = ["ISSUED"]
}

resource "aws_lb" "demo" {

  name               = "application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs-lb-sg.id]
  subnets            = module.vpc.public_subnets

}
resource "aws_lb_target_group" "demo" {
  name     = "${var.project_name}-alb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   =  module.vpc.vpc_id
  target_type = "ip"
  depends_on = [
    aws_lb.demo
  ]
  health_check {
    path = "/"
    port = 3000
    protocol = "HTTP"
    interval = 10
  }
}

resource "aws_lb_listener" "demo" {
  load_balancer_arn = aws_lb.demo.arn
  port = 443
  protocol = "HTTPS"
  certificate_arn = data.aws_acm_certificate.issued.arn

  default_action {
    target_group_arn = aws_lb_target_group.demo.arn
    type = "forward"
  }
}
resource "aws_lb_listener" "demoOne" {
  load_balancer_arn = aws_lb.demo.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }

  }
}


