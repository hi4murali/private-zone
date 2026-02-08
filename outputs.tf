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

output "public_fqdn" {
  description = "FQDN of the public instance A record in the private zone"
  value       = aws_route53_record.public.fqdn
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
  value       = "aws ssm start-session --target ${aws_instance.target.id} --document-name AWS-StartPortForwardingSession --parameters '${jsonencode({ portNumber = [tostring(var.web_server_port)], localPortNumber = ["8080"] })}'"
}

output "web_url_local" {
  description = "URL to access the web server after starting the SSM port forward"
  value       = "http://localhost:8080"
}

output "public_instance_id" {
  description = "Instance ID of the public instance"
  value       = aws_instance.public.id
}

output "public_instance_public_ip" {
  description = "Public IP of the public instance"
  value       = aws_instance.public.public_ip
}

output "public_instance_public_dns" {
  description = "AWS-provided public DNS name of the public instance"
  value       = aws_instance.public.public_dns
}

output "public_instance_http_url" {
  description = "HTTP URL to access the public instance web server"
  value       = "http://${aws_instance.public.public_dns}"
}

output "public_ssm_start_session" {
  description = "AWS CLI command to connect to the public instance via SSM"
  value       = "aws ssm start-session --target ${aws_instance.public.id}"
}

output "public_instance_ssh_command" {
  description = "SSH command to connect to the public instance"
  value       = "ssh -i YOUR_KEY.pem ec2-user@${aws_instance.public.public_ip}"
}
