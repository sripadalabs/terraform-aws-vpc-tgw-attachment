locals {
  # vpc route tables update
  vpc_rtb_id_cidr_pairs = [for pair in setproduct(keys(var.private_with_internet_route_table_ids), var.routed_cidrs) : {id = pair[0], cidr = pair[1]}]
  vpc_rtb_id_private_only_cidr_pairs = [for pair in setproduct(keys(var.private_only_route_table_ids), var.routed_cidrs_private_only) : {id = pair[0], cidr = pair[1]}]
}
