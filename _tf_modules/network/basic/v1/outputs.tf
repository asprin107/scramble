output "main_vpc_id" {
  value = aws_vpc.main.id
}

output "subnets_public_ids" {
  value = [for _map in aws_subnet.subnets_public : _map.id]
}

output "subnets_private_ids" {
  value = [for _map in aws_subnet.subnets_private : _map.id]
}

output "subnets_public" {
  value = aws_subnet.subnets_public
}

output "subnets_private" {
  value = aws_subnet.subnets_private
}

output "nat_eips" {
  value = aws_eip.nat_ip
}

output "nat_ips" {
  value = [for _map in aws_eip.nat_ip : _map.public_ip]
}