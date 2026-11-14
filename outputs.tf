output "attachment_id" {
  description = "ID of the created transit gateway VPC attachment."
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "attachment_vpc_id" {
  description = "ID of the VPC connected by the attachment."
  value       = aws_ec2_transit_gateway_vpc_attachment.this.vpc_id
}

output "attachment_transit_gateway_id" {
  description = "ID of the transit gateway connected by the attachment."
  value       = aws_ec2_transit_gateway_vpc_attachment.this.transit_gateway_id
}

output "association_id" {
  description = "ID of the transit gateway route table association."
  value       = aws_ec2_transit_gateway_route_table_association.this.id
}

output "propagation_ids" {
  description = "Map of transit gateway route table IDs to their propagation resource IDs."
  value       = { for route_table_id, propagation in aws_ec2_transit_gateway_route_table_propagation.this : route_table_id => propagation.id }
}

output "private_with_internet_route_ids" {
  description = "Map of destination CIDRs to their VPC route resource IDs for the private-with-internet route table."
  value       = { for cidr, route in aws_route.private_with_internet : cidr => route.id }
}

output "private_without_internet_route_ids" {
  description = "Map of destination CIDRs to their VPC route resource IDs for the private-only route table."
  value       = { for cidr, route in aws_route.private_without_internet : cidr => route.id }
}