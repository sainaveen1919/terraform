resource "aws_iam_role" "asg" {
  name = "${var.name}-backend-asg-role"

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

resource "aws_iam_role_policy_attachment" "asg_eks_worker" {
  role       = aws_iam_role.asg.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "asg_eks_cni" {
  role       = aws_iam_role.asg.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "asg_ecr_read_only" {
  role       = aws_iam_role.asg.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "asg" {
  name = "${var.name}-backend-asg-profile"
  role = aws_iam_role.asg.name
}

resource "aws_launch_template" "backend" {
  name_prefix   = "${var.name}-backend-"
  image_id      = data.aws_ami.bottlerocket.id
  instance_type = var.asg_instance_type
  user_data = base64encode(<<-EOT
    [settings.kubernetes]
    cluster-name = "${local.eks_cluster_name}"
    api-server = "${aws_eks_cluster.this.endpoint}"
    cluster-certificate = "${aws_eks_cluster.this.certificate_authority[0].data}"
    node-labels = "layer=${var.name},nodegroup=backend"
  EOT
  )

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted             = true
      kms_key_id            = aws_kms_key.common.arn
      volume_size           = 20
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
      Name                                               = "${var.name}-backend"
      "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name                                               = "${var.name}-backend"
      "kubernetes.io/cluster/${local.eks_cluster_name}" = "owned"
    }
  }
}

resource "aws_autoscaling_group" "backend" {
  name                = "${var.name}-backend-asg"
  min_size            = 6
  max_size            = 9
  desired_capacity    = 6
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-backend"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${local.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${local.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.asg_eks_worker,
    aws_iam_role_policy_attachment.asg_eks_cni,
    aws_iam_role_policy_attachment.asg_ecr_read_only,
    aws_eks_access_entry.asg_nodes
  ]
}
