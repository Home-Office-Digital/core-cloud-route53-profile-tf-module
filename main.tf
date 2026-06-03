resource "aws_route53profiles_profile" "this" {
  count = local.input_profile_id != "" ? 0 : 1

  name = var.r53_profile_name
  tags = var.tags
}

locals {
  input_profile_id = trimspace(var.r53_profile_id)
  selected_profile_id = local.input_profile_id != "" ? var.r53_profile_id : aws_route53profiles_profile.this[0].id
}

resource "aws_route53profiles_resource_association" "this" {
  for_each = toset(var.r53_zone_ids)

  name         = each.key
  profile_id   = local.selected_profile_id
  resource_arn = "arn:aws:route53:::hostedzone/${each.key}"
}