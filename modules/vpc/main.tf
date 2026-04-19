
resource "aws_vpc" "main" {
    cidr_block = var.main_cidr
    tags = {
        Name = "main"
        Environment = var.environment
    }
}

resource "aws_subnet" "public_subnet" {
   cidr_block = var.public_subnet_1_cidr
   availability_zone = data.aws_availability_zones.available.names[0]
   vpc_id = aws_vpc.main.id
   map_public_ip_on_launch = true
   tags = {
        Name = "public_subnet"
        Environment = var.environment
    }
}

resource "aws_subnet" "public_subnet_2" {
   cidr_block = var.public_subnet_2_cidr
   availability_zone = data.aws_availability_zones.available.names[1]
   vpc_id = aws_vpc.main.id
   map_public_ip_on_launch = true
   tags = {
        Name = "public_subnet_2"
        Environment = var.environment
    }
}

resource "aws_internet_gateway" "igws"{
    vpc_id = aws_vpc.main.id
    tags={
        Name= "igws"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
    tags={
        Name = "public_rt"
    }
}

resource "aws_route" "public_route" {
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = var.destination_cidr
    gateway_id = aws_internet_gateway.igws.id
}

resource "aws_route_table_association" "public_subnet_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
    subnet_id = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_rt.id
}



resource "aws_subnet" "private_subnet_1" {
   cidr_block = var.private_subnet_1_cidr
   availability_zone = data.aws_availability_zones.available.names[0]
    vpc_id = aws_vpc.main.id
    tags= {
        Name = "private_subnet_1"
        Environment = var.environment
    }
}
resource "aws_subnet" "private_subnet_2" {
   cidr_block = var.private_subnet_2_cidr
   availability_zone = data.aws_availability_zones.available.names[1]
    vpc_id = aws_vpc.main.id
    tags= {
        Name = "private_subnet_2"
        Environment = var.environment
    }
}

resource "aws_eip" "nat_eip" {
    domain = "vpc"
    tags={
        Name = "nat_eip"
    }
}
resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public_subnet.id
    tags={
        Name = "nat_gw"
    }
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.main.id
    tags={
        Name = "private_rt"
    }
}

resource "aws_route" "private_route" {
    route_table_id = aws_route_table.private_rt.id
    destination_cidr_block = var.destination_cidr
    nat_gateway_id = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_subnet_1_association" {
    subnet_id = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
    subnet_id = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.private_rt.id
}


