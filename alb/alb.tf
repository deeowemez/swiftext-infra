resource "aws_lb" "alb" {
  name               = "swiftext-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "swiftext-alb"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.appserver.arn
  }
}

resource "aws_lb_target_group" "appserver" {
  name     = "appserver-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "HTTP"
    path     = "/health"
  }

  tags = {
    Name = "appserver-target-group"
  }

  depends_on = [var.vpc_id]
}

resource "aws_lb_target_group_attachment" "appserver" {
  count            = length(var.appserver_instance_ids)
  target_group_arn = aws_lb_target_group.appserver.arn
  target_id        = var.appserver_instance_ids[count.index]
  port             = 5000
  depends_on       = [aws_lb_target_group.appserver]
}
