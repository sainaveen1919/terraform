resource "aws_iam_role" "asg" {
  name = "${var.name}-asg-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "asg_ssm" {
  role       = aws_iam_role.asg.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "asg" {
  name = "${var.name}-asg-profile"
  role = aws_iam_role.asg.name
}

resource "aws_launch_template" "linux" {
  name_prefix   = "${var.name}-linux-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.asg_instance_type

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted             = true
      kms_key_id            = aws_kms_key.common.arn
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.asg.name
  }

  network_interfaces {
    security_groups = [aws_security_group.asg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-linux"
    }
  }
}

resource "aws_autoscaling_group" "linux" {
  name                = "${var.name}-linux-asg"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]

  launch_template {
    id      = aws_launch_template.linux.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-linux"
    propagate_at_launch = true
  }
}
