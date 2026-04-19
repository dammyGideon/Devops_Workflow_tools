provider "aws" {
  region = var.region
}

module "vpc" {
   source = "../../modules/vpc"

  main_cidr            = var.main_cidr
  environment          = var.environment
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
}


//security group for bastion host 

resource "aws_security_group" "alb_sg" {
  name   = "${var.environment}-alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "${var.environment}-ec2-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
//ami-098e39bafa7e7303d

resource "aws_launch_template" "app" {
  name_prefix   = "app-template"
  image_id      = "ami-098e39bafa7e7303d"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello from Auto Scaling EC2" > /var/www/html/index.html
              EOF
  )
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  vpc_zone_identifier = module.vpc.private_subnet_ids

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  health_check_type = "ELB"
}

# resource "aws_instance" "app"{
#     ami = "ami-098e39bafa7e7303d"
#     instance_type = "t3.micro"
#     subnet_id = module.vpc.public_subnet_ids[0]
#     vpc_security_group_ids = [aws_security_group.ec2_sg.id]

#     user_data = <<-EOF
#                 #!/bin/bash
#                 yum install -y httpd
#                 systemctl start httpd
#                 systemctl enable httpd
#                 echo "Hello from public EC2" > /var/www/html/index.html
#                 EOF

#     tags = {
#         Name = "app"
#         Environment = var.environment
#     }
# }

resource "aws_alb" "alb"{
    name = "${var.environment}-alb"
    load_balancer_type = "application"
    subnets = module.vpc.public_subnet_ids 
    security_groups = [aws_security_group.alb_sg.id]
    tags = {
        Name = "alb"
        Environment = var.environment
    }
}

resource "aws_lb_target_group" "tg" {
  name    = "${var.environment}-tg"
  port = 80 
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.alb.arn
  port = 80 
  protocol = "HTTP"
  default_action{
    type= "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id = aws_launch_template.app.id
    port = 80
}
