output "vm_db_ip" {
  value = aws_instance.vm_database.public_ip
}

output "vm_web_server_ip" {
  value = aws_instance.vm_web_server.public_ip
}