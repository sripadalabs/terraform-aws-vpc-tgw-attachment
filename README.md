# terraform-aws-vpc-tgw-attachment

Creates an AWS Transit Gateway VPC attachment, adds caller-selected routes to existing VPC route tables, associates the attachment with an existing Transit Gateway route table, and optionally enables propagation into one or more existing Transit Gateway route tables.

The attachment enables appliance mode and disables the Transit Gateway default route-table association and propagation; it associates with the route table you specify and only enables the requested propagations. The module does not create a VPC, subnet, VPC route table, Transit Gateway, or Transit Gateway route table. It also does not create static Transit Gateway routes. Propagation advertises the VPC attachment's routes into the selected Transit Gateway route tables.

## Requirements

| Name | Version |
| --- | --- |
| Terraform | >= 1.3.0 |
| AWS provider | >= 5.0.0, < 7.0.0 |

Configure the AWS provider in the calling root module and grant it permissions to manage Transit Gateway VPC attachments, VPC routes, route-table associations, and route-table propagations. The supplied VPC and route tables must exist, and the supplied Transit Gateway route tables must belong to the supplied Transit Gateway.

The attachment requires one or more subnet IDs. AWS requires attachment subnets in distinct Availability Zones; choose subnets that provide the intended VPC connectivity. For a Transit Gateway shared from another AWS account, the Transit Gateway owner may need to accept the attachment request separately. This module does not create an accepter.

## Usage

```hcl
module "vpc_tgw_attachment" {
  source = "git::https://github.com/sripadalabs/terraform-aws-vpc-tgw-attachment.git"

  vpc_id                                      = "vpc-0123456789abcdef0"
  subnet_ids                                  = ["subnet-0123456789abcdef0", "subnet-abcdef01234567890"]
  transit_gateway_id                          = "tgw-0123456789abcdef0"
  private_with_internet_route_table_id        = "rtb-0123456789abcdef0"
  private_without_internet_route_table_id     = "rtb-abcdef01234567890"
  private_with_internet_cidrs                 = ["10.20.0.0/16"]
  private_without_internet_cidrs              = ["10.30.0.0/16"]
  transit_gateway_association_route_table_id  = "tgw-rtb-0123456789abcdef0"
  transit_gateway_propagation_route_table_ids = ["tgw-rtb-0123456789abcdef0", "tgw-rtb-abcdef01234567890"]

  tags = {
    Name        = "example-vpc-attachment"
    Environment = "production"
  }
}
```

Set either CIDR list to `[]` (or omit it) to create no VPC routes for that route table. CIDRs are explicit destinations: this module does not add a default route (`0.0.0.0/0`) unless it is explicitly supplied. IPv4 CIDRs are supported.

The two VPC route table IDs may refer to the same table if that matches the network design. CIDR values within each list must be unique; duplicate values are rejected during input validation.

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `vpc_id` | ID of the existing VPC to attach. | `string` | n/a | yes |
| `subnet_ids` | Existing subnet IDs used for attachment ENIs; choose subnets in distinct Availability Zones. | `list(string)` | n/a | yes |
| `transit_gateway_id` | ID of the existing Transit Gateway. | `string` | n/a | yes |
| `private_with_internet_route_table_id` | Existing VPC route table ID for private subnets with internet egress. | `string` | n/a | yes |
| `private_without_internet_route_table_id` | Existing VPC route table ID for private-only subnets. | `string` | n/a | yes |
| `private_with_internet_cidrs` | IPv4 CIDRs routed from the private-with-internet VPC route table through the Transit Gateway. | `list(string)` | `[]` | no |
| `private_without_internet_cidrs` | IPv4 CIDRs routed from the private-only VPC route table through the Transit Gateway. | `list(string)` | `[]` | no |
| `transit_gateway_association_route_table_id` | Existing Transit Gateway route table to associate with the attachment. | `string` | n/a | yes |
| `transit_gateway_propagation_route_table_ids` | Existing Transit Gateway route tables into which the attachment propagates routes. | `set(string)` | `[]` | no |
| `tags` | Tags applied to the attachment. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| --- | --- |
| `attachment_id` | Created Transit Gateway VPC attachment ID. |
| `attachment_vpc_id` | Attached VPC ID. |
| `attachment_transit_gateway_id` | Connected Transit Gateway ID. |
| `association_id` | Transit Gateway route table association ID. |
| `propagation_ids` | Map of propagation route table IDs to propagation IDs. |
| `private_with_internet_route_ids` | Map of destination CIDRs to VPC route IDs for the private-with-internet table. |
| `private_without_internet_route_ids` | Map of destination CIDRs to VPC route IDs for the private-only table. |