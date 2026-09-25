mock_provider "aws" {}

variables {
  r53_profile_name = "core-cloud-test-profile"
  r53_zone_ids     = ["Z0123456789ABCDEFGHIJ", "Z9876543210KLMNOPQRST"]
  tags = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

# When r53_profile_id is not supplied, a new profile is created with the
# given name and tags.
run "creates_profile_when_no_existing_id" {
  command = plan

  assert {
    condition     = length(aws_route53profiles_profile.this) == 1
    error_message = "Expected exactly one route53 profile to be created when r53_profile_id is empty."
  }

  assert {
    condition     = aws_route53profiles_profile.this[0].name == var.r53_profile_name
    error_message = "Profile name must equal r53_profile_name."
  }

  assert {
    condition     = aws_route53profiles_profile.this[0].tags["Environment"] == "test"
    error_message = "Profile tags must be propagated from var.tags."
  }

  assert {
    condition     = output.route53_profile_name == var.r53_profile_name
    error_message = "route53_profile_name output must equal the profile name when a new profile is created."
  }
}

# One resource association is created per zone id, keyed by the zone id.
run "creates_one_association_per_zone_id" {
  command = plan

  assert {
    condition     = length(aws_route53profiles_resource_association.this) == length(var.r53_zone_ids)
    error_message = "Expected one resource association per r53_zone_ids entry."
  }

  assert {
    condition     = aws_route53profiles_resource_association.this["Z0123456789ABCDEFGHIJ"].name == "Z0123456789ABCDEFGHIJ"
    error_message = "Association name must equal the zone id (map key)."
  }
}

# The resource_arn for each association is derived deterministically from the
# zone id.
run "association_arn_is_derived_from_zone_id" {
  command = plan

  assert {
    condition     = aws_route53profiles_resource_association.this["Z0123456789ABCDEFGHIJ"].resource_arn == "arn:aws:route53:::hostedzone/Z0123456789ABCDEFGHIJ"
    error_message = "resource_arn must be arn:aws:route53:::hostedzone/<zone_id>."
  }

  assert {
    condition     = aws_route53profiles_resource_association.this["Z9876543210KLMNOPQRST"].resource_arn == "arn:aws:route53:::hostedzone/Z9876543210KLMNOPQRST"
    error_message = "resource_arn must be arn:aws:route53:::hostedzone/<zone_id> for every zone."
  }
}

# When an existing r53_profile_id is supplied, no new profile is created and the
# associations use the provided id.
run "uses_existing_profile_id_when_supplied" {
  command = plan

  variables {
    r53_profile_id   = "rp-existing0123456789"
    r53_profile_name = ""
  }

  assert {
    condition     = length(aws_route53profiles_profile.this) == 0
    error_message = "No profile must be created when r53_profile_id is supplied."
  }

  assert {
    condition     = output.route53_profile_id == "rp-existing0123456789"
    error_message = "route53_profile_id output must equal the supplied existing profile id."
  }

  assert {
    condition     = output.route53_profile_name == null
    error_message = "route53_profile_name output must be null when using an existing profile id."
  }
}
