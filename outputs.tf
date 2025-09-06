output "ec2_public_ips" {
  description = "Public IPs of all EC2 instances"
  value       = [for i in aws_instance.ubuntu_ec2 : i.public_ip]
}
