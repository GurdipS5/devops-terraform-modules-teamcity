#------------------------------------------------------------------------------
# TeamCity User Resources
#------------------------------------------------------------------------------
# Users represent individual accounts that can access TeamCity.
#
# User properties:
# - username: Unique login identifier
# - name: Display name
# - email: Email address for notifications
# - password: Initial password (should be changed on first login)
# - roles: System-wide roles assigned to the user
#------------------------------------------------------------------------------

resource "teamcity_user" "this" {
  for_each = var.users

  username = each.value.username
  name     = each.value.name != "" ? each.value.name : each.value.username
  email    = each.value.email
  password = each.value.password

  lifecycle {
    # Don't update password if changed externally
    ignore_changes = [password]
  }
}

#------------------------------------------------------------------------------
# TeamCity Group Resources
#------------------------------------------------------------------------------
# Groups organize users and simplify permission management.
#
# Group features:
# - Assign roles to multiple users at once
# - Create hierarchical group structures
# - Automatically add users based on authentication provider
#------------------------------------------------------------------------------

resource "teamcity_group" "this" {
  for_each = var.groups

  key         = each.key
  name        = each.value.name
  description = each.value.description

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Group Membership
#------------------------------------------------------------------------------
# Note: Group membership is typically managed through the group resource
# or role assignments. The TeamCity provider may handle membership
# differently depending on version.
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# User ID Mapping
#------------------------------------------------------------------------------

locals {
  user_id_map = {
    for key, user in teamcity_user.this : key => user.id
  }

  group_id_map = {
    for key, group in teamcity_group.this : key => group.id
  }
}
