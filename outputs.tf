output "ec2_name_ip_map" {
  description = "Map of EC2 instance Name to Public IP"
  value = { for idx, inst in aws_instance.ubuntu_ec2 : inst.tags["Name"] => inst.public_ip }
}
