output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "eip" {
  value = module.vpc.eip_id
}

output "aws_route_table" {
  value = module.vpc.route_table_ids
}

