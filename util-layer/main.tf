data "archive_file" "util_layer_code_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/util-layer-code"
  output_path = "${path.module}/files/util-layer-code.zip"
}

resource "aws_lambda_layer_version" "util_layer" {
  filename   = "${path.module}/files/util-layer-code.zip"
  layer_name = "utilLayer"

  compatible_runtimes = ["nodejs14.x"]

  source_code_hash = filebase64sha256(data.archive_file.util_layer_code_lambda.output_path)
}
