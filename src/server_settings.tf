#------------------------------------------------------------------------------
# TeamCity Global Server Settings
#------------------------------------------------------------------------------
# Configures server-wide settings that affect all projects and builds.
#
# These settings are typically configured once during initial setup
# and rarely changed afterwards.
#------------------------------------------------------------------------------

resource "teamcity_global_settings" "this" {
  count = var.server_url != null ? 1 : 0

  root_url = var.server_url

  # Artifact settings
  max_artifact_size  = var.max_artifact_size
  max_artifact_count = var.max_artifact_count

  # Build settings  
  default_execution_timeout = var.default_execution_timeout

  # VCS settings
  default_vcs_check_interval = var.default_vcs_check_interval
}

#------------------------------------------------------------------------------
# SMTP Configuration
#------------------------------------------------------------------------------

resource "teamcity_email_settings" "this" {
  count = var.smtp_config != null ? 1 : 0

  host     = var.smtp_config.host
  port     = var.smtp_config.port
  from     = var.smtp_config.from
  login    = var.smtp_config.login
  password = var.smtp_config.password
  secure   = var.smtp_config.secure
}

#------------------------------------------------------------------------------
# License Keys
#------------------------------------------------------------------------------

resource "teamcity_license" "this" {
  for_each = toset(var.license_keys)

  key = each.value
}

#------------------------------------------------------------------------------
# Cleanup Rules
#------------------------------------------------------------------------------

resource "teamcity_cleanup_settings" "this" {
  for_each = var.cleanup_rules

  enabled               = true
  max_cleanup_duration  = 60
  daily_cleanup_time    = "03:00"
}
