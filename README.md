# sql-injection-detection-aws-iac
Repository for a set up of a vulnerable web environment to simulate SQL Injection attacks and detect them using IDS/IPS tools, scripts, and log analysis. Infrastructure is provisioned using Terraform and configured with Ansible on AWS Free Tier resources


## Installation and Usage

1. **Install Required Tools**
    - Download and install [Terraform](https://www.terraform.io/downloads.html).
    - Download and install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (not just the core).
    - Download and install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

2. **Set Up AWS Credentials and SSH Keys**
    - Create an AWS account and generate an Access Key for CLI usage.
    - Run `aws configure` to set up your credentials.
    - Create a SSH `key_pair` for your VMs

3. **Configure Variables**
    - Edit `variables.tfvars` and set your `key_pair` and IP address.
    - You can find your IP address with:  
      ```bash
      curl https://ipinfo.io/ip
      ```

4. **Prepare Deployment Script**
    - Make the deployment script executable:  
      ```bash
      chmod +x deploy.sh
      ```

5. **Deploy Infrastructure**
    - Run the deployment script, passing the path to your private key:  
      ```bash
      ./deploy.sh path-to-private-key
      ```
    - The script runs `terraform apply -var-file=variables.tfvars` and `ansible-playbook -i hosts playbook.yaml`.  
      You can also run these commands manually if needed.

6. **Access the Virtual Machines**
    - SSH into the web server VM:  
      ```bash
      ssh ubuntu@<IP_VM> -i path-to-private-key
      ```
    - On the database VM, you can test the database setup:  
      ```bash
      psql -U postgres -d web_server_db
      ```

7. **Troubleshooting**
    - If you see an error like:
      ```
      fatal: [<IP>]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: ssh: connect to host <IP> port 22: Connection timed out", "unreachable": true}
      ```
      This can rarely happen when running `deploy.sh`. If it does, simply run the script again.

8. **Simulate and Detect SQL Injection Attacks**
    - On the attacker VM, run:
      ```bash
      sqlmap -u "http://<PRIVATE_IP_WEB>/test_db_connection.php?id=1" --batch --level=2 --risk=2
      ```
    - On the web VM, monitor Snort alerts:
      ```bash
      sudo tail -f /var/log/snort/alert
      ```

9. **Destroy and Clean Up the Environment**
    - To remove all provisioned resources and avoid unnecessary charges, run:
        ```bash
        terraform destroy -var-file=variables.tfvars
        ```
- **WARNING: If you do NOT destroy the infrastructure after use, AWS may CHARGE YOU for active resources if you exceed the AWS Free Tier limits!**