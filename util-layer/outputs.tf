output "util_layer_arn_array" {
  description = "Util layer arn array"
  value       = [aws_lambda_layer_version.util_layer.arn]
}
