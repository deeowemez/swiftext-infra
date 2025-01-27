output "appserver_instance_ids" {
  description = "The IDs of the created app server instances"
  value       = aws_instance.appserver[*].id
}

output "bastion_instance_id" {
  description = "The IDs of the created bastion host instance"
  value       = aws_instance.bastion_host.id
}