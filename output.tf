output "vm_db_ip" {
  value = aws_instance.vm_database.public_ip
}

output "vm_web_server_ip" {
  value = aws_instance.vm_web_server.public_ip
}

output "vm_siem_ip" {
  value = aws_instance.vm_siem.public_ip
}

output "vm_attacker_ip" {
  value = aws_instance.vm_attacker.public_ip
}

output "vm_db_private_ip" {
  value = aws_instance.vm_database.private_ip
}

output "vm_web_server_private_ip" {
  value = aws_instance.vm_web_server.private_ip
}

output "vm_siem_private_ip" {
  value = aws_instance.vm_siem.private_ip
}

output "vm_attacker_private_ip" {
  value = aws_instance.vm_attacker.private_ip
}