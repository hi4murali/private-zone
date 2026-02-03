output "target_instance_id" {
  description = "Instance ID of the target (use with SSM)"
  value       = aws_instance.target.id
}

output "target_private_ip" {
  description = "Private IP of the target instance"
  value       = aws_instance.target.private_ip
}

output "private_zone_id" {
  description = "Route 53 private hosted zone ID"
  value       = aws_route53_zone.private.zone_id
}

output "server_fqdn" {
  description = "FQDN of the server A record in the private zone"
  value       = aws_route53_record.server.fqdn
}

output "ssm_start_session" {
  description = "AWS CLI command to connect via SSM Session Manager"
  value       = "aws ssm start-session --target ${aws_instance.target.id}"
}

output "dns_test_command" {
  description = "Command to test private DNS resolution (run inside the SSM session)"
  value       = "dig server.${var.private_zone_name}"
}

output "ssm_port_forward" {
  description = "AWS CLI command to forward the web server port to localhost:8080"
  value       = "aws ssm start-session --target ${aws_instance.target.id} --document-name AWS-StartPortForwardingSession --parameters '{\"portNumber\":[\"${var.web_server_port}\"],\"localPortNumber\":[\"8080\"]}'"
}

output "web_url_local" {
  description = "URL to access the web server after starting the SSM port forward"
  value       = "http://localhost:8080"
}
