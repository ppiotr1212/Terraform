resource "null_resource" "download_ssh_key" {
  triggers = {
    timestamp = "${replace("${timestamp()}", "/[-| |T|Z|:]/", "")}"
  }

  provisioner "local-exec" {
    command = "mkdir -p ~/.ssh/ &&  aws s3 cp s3://${var.bucket_name}/panda_kurs.pem ~/.ssh/panda_kurs.pem || true && chmod 400 ~/.ssh/panda_kurs.pem"
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tpl",
  { ansible_ip = "${join("\n", aws_instance.panda.*.public_ip)}" })
  filename = "${path.module}/../inventory"
}