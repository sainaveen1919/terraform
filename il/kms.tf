resource "aws_kms_key" "common" {
  description             = "Common CMK for ${var.name} encrypted resources"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.name}-common-cmk"
  }
}

resource "aws_kms_alias" "common" {
  name          = "alias/${var.name}-common"
  target_key_id = aws_kms_key.common.key_id
}
