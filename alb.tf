resource "aws_default_subnet" "default_az" {
  count            = length(var.availability_zones)
  availability_zone = var.availability_zones[count.index]
}

resource "aws_default_vpc" "default" {}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_pub.id]
  subnets            = aws_default_subnet.default_az[*].id
}

resource "aws_lb_listener" "alb_listener_frontend" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "5000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_frontend.arn
  }
}

resource "aws_lb_target_group" "tg_frontend" {
  name        = "tg-frontend"
  port        = 5000
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_lb_target_group_attachment" "tg_attch_frontend" {
  count            = length(aws_instance.panda)
  target_group_arn = aws_lb_target_group.tg_frontend.arn
  target_id        = aws_instance.panda[count.index].id
  port             = 5000
}

resource "aws_lb_listener" "alb_listener_backend" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "5001"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_backend.arn
  }
}

resource "aws_lb_target_group" "tg_backend" {
  name        = "tg-backend"
  port        = 5001
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_default_vpc.default.id
}

resource "aws_lb_target_group_attachment" "tg_attch_backend" {
  count            = length(aws_instance.panda)
  target_group_arn = aws_lb_target_group.tg_backend.arn
  target_id        = aws_instance.panda[count.index].id
  port             = 5001
}