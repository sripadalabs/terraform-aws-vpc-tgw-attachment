variable "vpc_id" {
  description = "ID of the existing VPC to attach to the transit gateway."
  type        = string

  validation {
    condition     = trimspace(var.vpc_id) != ""
    error_message = "vpc_id must not be empty."
  }
}

variable "transit_gateway_id" {
  description = "ID of the existing transit gateway."
  type        = string

  validation {
    condition     = trimspace(var.transit_gateway_id) != ""
    error_message = "transit_gateway_id must not be empty."
  }
}

variable "subnet_ids" {
  description = "IDs of existing VPC subnets used for transit gateway attachment ENIs. Supply a subnet in each Availability Zone where the VPC should attach."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0 && alltrue([for id in var.subnet_ids : trimspace(id) != ""]) && length(var.subnet_ids) == length(toset(var.subnet_ids))
    error_message = "subnet_ids must contain unique, non-empty subnet IDs."
  }
}

variable "private_with_internet_route_table_id" {
  description = "ID of the existing VPC route table for private subnets with internet egress."
  type        = string

  validation {
    condition     = trimspace(var.private_with_internet_route_table_id) != ""
    error_message = "private_with_internet_route_table_id must not be empty."
  }
}

variable "private_only_route_table_id" {
  description = "ID of the existing VPC route table for private-only subnets."
  type        = string

  validation {
    condition     = trimspace(var.private_only_route_table_id) != ""
    error_message = "private_only_route_table_id must not be empty."
  }
}

variable "private_with_internet_cidrs" {
  description = "IPv4 destination CIDRs to route from the private-with-internet VPC route table through the transit gateway. No routes are created unless CIDRs are supplied."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.private_with_internet_cidrs : can(cidrnetmask(cidr))]) && length(var.private_with_internet_cidrs) == length(toset(var.private_with_internet_cidrs))
    error_message = "private_with_internet_cidrs must contain unique, valid IPv4 CIDR blocks."
  }
}

variable "private_only_subnet_cidrs" {
  description = "IPv4 destination CIDRs to route from the private-only VPC route table through the transit gateway. No routes are created unless CIDRs are supplied."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.private_without_internet_cidrs : can(cidrnetmask(cidr))]) && length(var.private_without_internet_cidrs) == length(toset(var.private_without_internet_cidrs))
    error_message = "private_without_internet_cidrs must contain unique, valid IPv4 CIDR blocks."
  }
}

variable "transit_gateway_association_route_table_id" {
  description = "ID of the existing transit gateway route table to associate with the VPC attachment."
  type        = string

  validation {
    condition     = trimspace(var.transit_gateway_association_route_table_id) != ""
    error_message = "transit_gateway_association_route_table_id must not be empty."
  }
}

variable "transit_gateway_propagation_route_table_id" {
  description = "IDs of existing transit gateway route tables into which the VPC attachment should propagate its VPC routes."
  type        = string

  validation {
    condition     = trimspace(var.transit_gateway_propagation_route_table_id) != ""
    error_message = "transit_gateway_propagation_route_table_id must not be empty."
  }
}

variable "private_with_internet_subnet_cidrs" {
  description = "IPv4 CIDRs of private subnets with internet egress. Static routes for these prefixes are added to each propagation route table and target this VPC attachment."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.private_with_internet_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "private_with_internet_subnet_cidrs must contain only valid IPv4 CIDR blocks."
  }
}

variable "private_without_internet_subnet_cidrs" {
  description = "IPv4 CIDRs of private-only subnets. Static routes for these prefixes are added to each propagation route table and target this VPC attachment."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.private_without_internet_subnet_cidrs : can(cidrnetmask(cidr))])
    error_message = "private_without_internet_subnet_cidrs must contain only valid IPv4 CIDR blocks."
  }
}

variable "transit_gateway_static_routes" {
  description = "Optional static IPv4 routes in existing Transit Gateway route tables, with destinations reachable through this VPC attachment (for example, networks behind an appliance in the VPC)."
  type = list(object({
    route_table_id         = string
    destination_cidr_block = string
  }))
  default = []

  validation {
    condition = (
      alltrue([
        for route in var.transit_gateway_static_routes :
        trimspace(route.route_table_id) != "" && can(cidrnetmask(route.destination_cidr_block))
      ]) &&
      length(var.transit_gateway_static_routes) == length(toset([
        for route in var.transit_gateway_static_routes :
        "${route.route_table_id}|${route.destination_cidr_block}"
      ]))
    )
    error_message = "transit_gateway_static_routes must contain unique route table and destination pairs with non-empty route table IDs and valid IPv4 CIDRs."
  }
}

variable "tags" {
  description = "Tags to apply to the transit gateway VPC attachment."
  type        = map(string)
  default     = {}
}
