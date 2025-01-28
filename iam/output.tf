output "iam_instance_profile" {
  description = "Instance profile for appserver instance"
  value = aws_iam_instance_profile.appserver_profile
}