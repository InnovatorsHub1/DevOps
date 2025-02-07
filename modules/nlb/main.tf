resource "aws_lb" "nlb" {
  name               = "${var.project_name}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.public_subnet_ids[0], var.public_subnet_ids[1]]

  enable_deletion_protection = false

  tags = merge({
    Environment = var.environment
  })
}

resource "aws_lb_target_group" "nlb" {
  name        = "${var.project_name}-tg"
  port        = var.container_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval           = 30
    protocol           = "TCP"
    port               = "traffic-port"
    timeout            = 6
    unhealthy_threshold = 3
  }

  tags = merge({
    Environment = var.environment
  })
}

resource "aws_lb_listener" "nlb" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb.arn
  }
}