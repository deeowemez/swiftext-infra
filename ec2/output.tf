output "appserver_instance_ids" {
  description = "The IDs of the created app server instances"
  value       = aws_instance.appserver[*].id
}

output "bastion_instance_id" {
  description = "The IDs of the created bastion host instance"
  value       = aws_instance.bastion_host.id
}

# Private Key Values
output "bastion_private_key_pem" {
  value     = tls_private_key.bastion_key.private_key_pem
  sensitive = true
}

output "appserver_private_key_pem" {
  value     = tls_private_key.appserver_key.private_key_pem
  sensitive = true
}