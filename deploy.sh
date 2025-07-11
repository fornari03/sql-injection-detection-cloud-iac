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
terraform init
terraform apply -auto-approve


# 2. Get the public IPs of the VMs and the db private IP
VM_DATABASE_IP=$(terraform output -raw vm_db_ip)
VM_WEB_SERVER_IP=$(terraform output -raw vm_web_server_ip)
VM_SIEM_IP=$(terraform output -raw vm_siem_ip)
VM_ATTACKER_IP=$(terraform output -raw vm_attacker_ip)
PRIVATE_IP_DATABASE=$(terraform output -raw vm_db_private_ip)


# 3. Create the Ansible inventory file
cat > hosts <<EOF
[database]
${VM_DATABASE_IP}
[webserver]
${VM_WEB_SERVER_IP}
[siem]
${VM_SIEM_IP}
[attacker]
${VM_ATTACKER_IP}
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

echo "'ansible.cfg' file generated:"
cat ansible.cfg

# 5. Create the Ansible variables file
cat > ansible_vars.yaml <<EOF
---
postgres_user: "postgres"
postgres_password: "postgres"
postgres_port: 5432
db_name: "web_server_db"
db_host: "${PRIVATE_IP_DATABASE}"
snort_interface: "enX0"
EOF

# 5. Runs Ansible playbook
ansible-playbook -i hosts playbook.yaml