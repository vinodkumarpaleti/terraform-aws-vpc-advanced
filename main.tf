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