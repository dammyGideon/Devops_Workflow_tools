output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnet.id,
    aws_subnet.public_subnet_2.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
}

output "eip_id" {
  value = aws_eip.nat_eip.id
}

output "route_table_ids" {
  value = [
    aws_route_table.public_rt.id,
    aws_route_table.private_rt.id
  ]
}
