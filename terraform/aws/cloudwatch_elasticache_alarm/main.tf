resource "terraform_data" "cw_script" {
  provisioner "local-exec" {
    command = "python cw_script.py"
    interpreter = ["python", "bash"]
  }
}
