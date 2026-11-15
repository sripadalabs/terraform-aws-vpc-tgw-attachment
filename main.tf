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
  for_each = {for item in local.vpc_rtb_id_cidr_pairs : "${item.id}_${item.cidr}" => item}

  destination_cidr_block = each.value.cidr
  route_table_id         = var.private_with_internet_route_table_ids[each.value.id]
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.this.transit_gateway_id

  timeouts{
    create = "5m"
    delete = "5m"
  }

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}

resource "aws_route" "private_without_internet" {
  for_each = {for item in local.vpc_rtb_id_private_only_cidr_pairs : "${item.id}_${item.cidr}" => item}

  destination_cidr_block = each.value.cidr
  route_table_id         = var.private_only_route_table_ids[each.value.id]
  transit_gateway_id     = aws_ec2_transit_gateway_vpc_attachment.this.transit_gateway_id

  timeouts{
    create = "5m"
    delete = "5m"
  }

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.this]
}

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_association_route_table_id
}

resource "aws_ec2_transit_gateway_route" "vpc_cidrs" {
  for_each = toset(var.vpc_routable_cidrs)

  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.transit_gateway_propagation_route_table_id
}


