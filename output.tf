output "vm_db_ip" {
  value = aws_instance.vm_database.public_ip
}