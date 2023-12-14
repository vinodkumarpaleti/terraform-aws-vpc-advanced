resource "aws_vpc" "my_vpc" {
    cidr_block = var.cidr_block
    enable_dns_hostnames = var.enable_dns_hostnames
    enable_dns_support = var.enable_dns_support
  
  tags = merge(
    var.common_tags,
    {
        Name = var.project_name
    },
    var.vpc_tags
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = merge(
    var.common_tags,
    {
        Name = var.project_name
    },
    var.igw_tags
  )
  
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-public-${local.azs[count.index]}"
        #Name = "${var.project_name}-${var.env}-public-${local.azs[count.index]}"
    }
  )
}
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-private-${local.azs[count.index]}"
        #Name = "${var.project_name}-${var.env}-public-${local.azs[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr)
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.database_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-database-${local.azs[count.index]}"
        #Name = "${var.project_name}-${var.env}-public-${local.azs[count.index]}"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-public"
    }
  )
}
resource "aws_eip" "eip" {
  domain   = "vpc"
}
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    {
        Name = var.project_name
        #Name = "${var.project_name}-${var.env}"
    },
    var.nat_gateway_tags
  )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-public"
    }
  )
}
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-public"
    }
  )
}