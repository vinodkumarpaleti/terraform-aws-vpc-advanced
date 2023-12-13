locals {
    azs = slice (data.aws_availability_zones.available.names,0,2)
  }

# output "azs" {
#   value = local.azs
# }