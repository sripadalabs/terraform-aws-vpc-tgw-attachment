resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  appliance_mode_support                          = "enable"
  subnet_ids                                      = var.subnet_ids
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  transit_gateway_id                              = var.transit_gateway_id
  vpc_id                                          = var.vpc_id

  tags = var.tags

  lifecycle {
    precondition {
      condition = length(setintersection(
        var.private_with_internet_subnet_cidrs,
        var.private_without_internet_subnet_cidrs
      )) == 0
      error_message = "A subnet CIDR cannot be configured in both private subnet groups."
    }
  }
}

resource "aws_route" "private_with_internet" {
  for_each = toset(var.private_with_internet_cidrs)

  destination_cidr_block = each.value
  route_table_id         = var.private_with_internet_route_table_id
  transit_gateway_id     = var.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}

resource "aws_route" "private_without_internet" {
  for_each = toset(var.private_only_subnet_cidrs)

  destination_cidr_block = each.value
  route_table_id         = var.private_only_route_table_id
  transit_gateway_id     = var.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_association_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {  

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_propagation_route_table_id
}

locals {
  transit_gateway_private_with_internet_routes = {
    for pair in setproduct(
      var.transit_gateway_propagation_route_table_id,
      var.private_with_internet_subnet_cidrs
    ) :
    "${pair[0]}|${pair[1]}" => {
      route_table_id         = pair[0]
      destination_cidr_block = pair[1]
    }
  }

  transit_gateway_private_without_internet_routes = {
    for pair in setproduct(
      var.transit_gateway_propagation_route_table_id,
      var.private_only_subnet_cidrs
    ) :
    "${pair[0]}|${pair[1]}" => {
      route_table_id         = pair[0]
      destination_cidr_block = pair[1]
    }
  }

  transit_gateway_explicit_static_routes = {
    for route in var.transit_gateway_static_routes :
    "${route.route_table_id}|${route.destination_cidr_block}" => route
    if !contains(keys(local.transit_gateway_private_with_internet_routes), "${route.route_table_id}|${route.destination_cidr_block}") &&
    !contains(keys(local.transit_gateway_private_without_internet_routes), "${route.route_table_id}|${route.destination_cidr_block}")
  }
}

resource "aws_ec2_transit_gateway_route" "private_with_internet" {
  for_each = local.transit_gateway_private_with_internet_routes

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = each.value.route_table_id
}

resource "aws_ec2_transit_gateway_route" "private_without_internet" {
  for_each = local.transit_gateway_private_without_internet_routes

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = each.value.route_table_id
}

resource "aws_ec2_transit_gateway_route" "static" {
  for_each = local.transit_gateway_explicit_static_routes

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = each.value.route_table_id
}
