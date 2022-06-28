data "aws_acm_certificate" "issued" {
  domain   = "alblankfactortest.com"
  statuses = ["ISSUED"]
}

resource "aws_eip" "network_eip" {
  vpc = true
}

resource "aws_lb" "demo" {

  name               = "application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs-demo.id]
  subnets            = module.vpc.private_subnets

}
resource "aws_lb_target_group" "demo" {
  name     = "${var.project_name}-alb-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   =  module.vpc.vpc_id
  target_type = "ip"
  depends_on = [
    aws_lb.demo
  ]
  health_check {
    path = "/"
    port = 3000
    protocol = "HTTP"
    interval = 30
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
  port = 3000
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.demo.arn
    type = "forward"
  }
}


resource "aws_lb" "network_loadbalancer" {

  name               = "network-lb"
  internal           = false
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id     =module.vpc.private_subnets[0]
    allocation_id = aws_eip.network_eip.id
  }

}
resource "aws_lb_target_group" "nlb_target_group" {
  name        = "nlb-tg"
  target_type = "alb"
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  port        = 443
  depends_on = [aws_lb.network_loadbalancer]
  health_check {
    path = "/"
    port = 3000
    protocol = "HTTP"
    interval = 30
  }

}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.network_loadbalancer.arn
  port = 443
  protocol = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
    type = "forward"
  }
  depends_on = [aws_lb.network_loadbalancer]
}
resource "aws_lb_listener" "nlb_listener_http" {
  load_balancer_arn = aws_lb.network_loadbalancer.arn
  port = 3000
  protocol = "TCP"
  default_action {
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
    type = "forward"
  }
  depends_on = [aws_lb.network_loadbalancer]
}

resource "aws_lb_target_group_attachment" "target_attachment" {
  target_group_arn = aws_lb_target_group.nlb_target_group.arn
  target_id        = aws_lb.demo.id
  port             = 443
  depends_on = [aws_lb.demo,aws_lb.network_loadbalancer,aws_lb_target_group.nlb_target_group,aws_lb_listener.nlb_listener]
}

