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