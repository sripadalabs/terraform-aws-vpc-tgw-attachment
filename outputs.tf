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
