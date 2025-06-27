#!/bin/bash
set -e

# Check if the user provided the path to the private key
if [[ $# -ne 1 ]]; then
  echo "Missing argument: Path to the private key file is required."
  exit 1
fi

KEY_PATH="$1"

# Check if the provided key file exists
if [[ ! -f "$KEY_PATH" ]]; then
  echo "Error: private key file not found in '$KEY_PATH'"
  exit 1
fi





# 1. Apply Terraform configuration
terraform apply -var-file=variables.tfvars -auto-approve


# 2. Get the public IPs of the VMs
VM_DATABASE_IP=$(terraform output -raw vm_db_ip)
VM_WEB_SERVER_IP=$(terraform output -raw vm_web_server_ip)


# 3. Create the Ansible inventory file
cat > hosts <<EOF
[database]
${VM_DATABASE_IP}
[webserver]
${VM_WEB_SERVER_IP}
EOF

echo "'hosts' file generated:"
cat hosts


# 4. Create the Ansible configuration file
cat > ansible.cfg <<EOF
[defaults]
host_key_checking = False
remote_user = ubuntu
private_key_file = ${KEY_PATH}
EOF

echo "'ansible.cfg' file generated"
cat ansible.cfg


# 5. Runs Ansible playbook
ansible-playbook -i hosts playbook.yaml