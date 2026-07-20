resource "aws_cognito_user_pool" "api" {
  name = "${var.name}-api-users"
}

resource "aws_cognito_user_pool_client" "api" {
  name         = "${var.name}-api-client"
  user_pool_id = aws_cognito_user_pool.api.id
}
