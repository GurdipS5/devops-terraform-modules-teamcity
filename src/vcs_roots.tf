#------------------------------------------------------------------------------
# TeamCity VCS Root Resources
#------------------------------------------------------------------------------
# VCS roots define connections to version control systems.
#
# Supported VCS types:
# - git: Git repositories (GitHub, GitLab, Bitbucket, etc.)
# - svn: Subversion
# - perforce: Perforce Helix
# - mercurial: Mercurial
# - tfs: Azure DevOps / TFS
#
# Authentication methods for Git:
# - anonymous: No authentication (public repos)
# - password: Username and password/token
# - ssh: SSH key authentication
#------------------------------------------------------------------------------

resource "teamcity_vcsroot" "this" {
  for_each = local.vcs_roots_map

  name       = each.value.name
  project_id = teamcity_project.this[each.value.project_key].id

  # Git-specific configuration
  git = each.value.type == "git" ? {
    url             = each.value.url
    branch          = each.value.branch
    branch_spec     = "+:refs/heads/*"
    
    # Authentication based on method
    auth_method     = each.value.auth_method
    username        = each.value.auth_method == "password" ? each.value.username : null
    password        = each.value.auth_method == "password" ? each.value.password : null
    private_key     = each.value.auth_method == "ssh" ? each.value.private_key : null
    passphrase      = each.value.auth_method == "ssh" ? each.value.passphrase : null
    
    # Additional settings
    checkout_policy = "AUTO"
    clean_policy    = "ON_BRANCH_CHANGE"
  } : null

  depends_on = [
    teamcity_project.this
  ]

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# SSH Keys for VCS Roots
#------------------------------------------------------------------------------

resource "teamcity_ssh_key" "this" {
  for_each = var.ssh_keys

  project_id  = teamcity_project.this[each.value.project_key].id
  name        = each.value.name
  private_key = each.value.private_key

  depends_on = [
    teamcity_project.this
  ]

  lifecycle {
    # Don't update if key changed externally
    ignore_changes = [private_key]
  }
}

#------------------------------------------------------------------------------
# VCS Root ID Mapping
#------------------------------------------------------------------------------

locals {
  vcs_root_id_map = {
    for key, vcs in teamcity_vcsroot.this : key => vcs.id
  }
}
