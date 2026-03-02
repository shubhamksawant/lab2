provider "aws" {
  region = "us-east-1"
}

locals {
  env     = "prod"
  service = "ec2"
}

module "ec2" {
  source           = "../../modules/ec2"
  ami_id           = "ami-0123456789abcdef0"
  subnet_id        = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  env              = "prod"
  private_key_path = "~/.ssh/id_rsa"
  public_key       = "ssh-rsa YOUR_PUBLIC_KEY"
}

resource "local_file" "ansible_inventory" {
  content  = "[app_nodes]\n${module.ec2.public_ip}\n"
  filename = "${path.module}/../../../ansible/inventory_${local.env}.ini"
}

resource "null_resource" "trigger_ansible" {
  triggers = {
    inventory_hash = local_file.ansible_inventory.content_md5
  }

  provisioner "local-exec" {
    command = <<EOT
      until nc -z ${module.ec2.public_ip} 22; do echo 'Waiting for SSH...'; sleep 5; done
      ansible-playbook -i ${local_file.ansible_inventory.filename} ../../../ansible/setup.yml --private-key ~/.ssh/id_rsa
    EOT

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }

  depends_on = [local_file.ansible_inventory]
}

