# 1. The Load Balancer Device

resource "aws_lb" "app_lb" {

  name = "secure-doc-lb"

  internal = false

  load_balancer_type = "application"

  security_groups = [aws_security_group.lb_sg.id]

  subnets = [aws_subnet.public.id, aws_subnet.public_2.id] # ALB needs 2 subnets!

}



# 2. The Target Group (Who receives the traffic?)

resource "aws_lb_target_group" "app_tg" {

  name = "secure-doc-tg"

  port = 5000

  protocol = "HTTP"

  vpc_id = aws_vpc.main.id



  health_check {

    path = "/"

    protocol = "HTTP"

    matcher = "200"

    interval = 15

    timeout = 3

    healthy_threshold = 2

    unhealthy_threshold = 2

  }

}



# 3. The Listener (The Ear)

resource "aws_lb_listener" "front_end" {

  load_balancer_arn = aws_lb.app_lb.arn

  port = "80"

  protocol = "HTTP"



  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.app_tg.arn

  }

}



# 4. Attach Instances to the Target Group

resource "aws_lb_target_group_attachment" "app_attach" {

  count = 2

  target_group_arn = aws_lb_target_group.app_tg.arn

  target_id = aws_instance.web[count.index].id # References the 2 instances

  port = 5000

}


# Security Group for Load Balancer (Open to World on Port 80)

resource "aws_security_group" "lb_sg" {

  name = "lb-sg"

  description = "Allow HTTP to Load Balancer"

  vpc_id = aws_vpc.main.id



  ingress {

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }



  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}

output "app_alb" {

  value = aws_lb.app_lb.dns_name

}
