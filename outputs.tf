output "route53_profile_name" {
  value = local.input_profile_id != "" ? null : aws_route53profiles_profile.this[0].name
}

output "route53_profile_arn" {
  value = local.input_profile_id != "" ? null : aws_route53profiles_profile.this[0].arn
}

output "route53_profile_id" {
  value = local.selected_profile_id
}

output "aws_route53profiles_resource_association_name" {
  value = values(aws_route53profiles_resource_association.this)[*].name
}

output "aws_route53profiles_resource_association_id" {
  value = values(aws_route53profiles_resource_association.this)[*].id
}
