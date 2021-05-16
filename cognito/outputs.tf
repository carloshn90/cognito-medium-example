output "royal_user_pool_id" {
    value = aws_cognito_user_pool.royal_user_pool.id
}

output "royal_user_pool_client_id" {
    value = aws_cognito_user_pool_client.royal_user_pool_client.id
}

output "royal_cognito_user_pool_name" {
    value = aws_cognito_user_pool.royal_user_pool.name
}

output "royal_cognito_user_pool_arn" {
    value = aws_cognito_user_pool.royal_user_pool.arn
}
