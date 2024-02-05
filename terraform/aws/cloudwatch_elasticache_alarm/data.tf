data "terraform_data" "cw_script" {
  provisioner "local-exec" {
    command = "python cw_script.py"
    interpreter = ["python", "bash"]
  }
}

data "aws_sns_topic" "sns" {
  name = var.sns_topic
}
