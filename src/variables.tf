#------------------------------------------------------------------------------
# TeamCity Terraform Module - Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Provider Configuration
#------------------------------------------------------------------------------

variable "teamcity_host" {
  description = "TeamCity server URL (e.g., http://localhost:8111). Can also be set via TEAMCITY_HOST environment variable."
  type        = string
}

variable "teamcity_token" {
  description = "TeamCity access token with admin permissions. Can also be set via TEAMCITY_TOKEN environment variable."
  type        = string
  sensitive   = true
  default     = null
}

variable "max_retries" {
  description = "Maximum number of retries for API requests. Each retry waits 5 seconds."
  type        = number
  default     = 12
}

#------------------------------------------------------------------------------
# Global Server Settings
#------------------------------------------------------------------------------

variable "server_url" {
  description = "Public URL of the TeamCity server (used for links in notifications, etc.)."
  type        = string
  default     = null
}

variable "max_artifact_size" {
  description = "Maximum artifact size in bytes. Set to -1 for unlimited."
  type        = number
  default     = null
}

variable "max_artifact_count" {
  description = "Maximum number of artifacts per build."
  type        = number
  default     = null
}

variable "default_execution_timeout" {
  description = "Default build execution timeout in minutes."
  type        = number
  default     = null
}

variable "default_vcs_check_interval" {
  description = "Default VCS polling interval in seconds."
  type        = number
  default     = null
}

#------------------------------------------------------------------------------
# Authentication Configuration
#------------------------------------------------------------------------------

variable "auth_modules" {
  description = <<-EOT
    Map of authentication modules to configure.
    
    Example:
    {
      "built-in" = {
        type = "built-in"
      }
      "github-oauth" = {
        type          = "github"
        client_id     = "xxx"
        client_secret = "xxx"
      }
    }
    
    Supported types: built-in, github, gitlab, bitbucket, google, ldap
  EOT
  type = map(object({
    type                = string
    client_id           = optional(string, null)
    client_secret       = optional(string, null)
    allow_creating_users = optional(bool, true)
  }))
  default   = {}
  sensitive = true
}

#------------------------------------------------------------------------------
# SMTP / Email Configuration
#------------------------------------------------------------------------------

variable "smtp_config" {
  description = <<-EOT
    SMTP configuration for email notifications.
    
    Example:
    {
      host        = "smtp.example.com"
      port        = 587
      from        = "teamcity@example.com"
      login       = "teamcity"
      password    = "xxx"
      secure      = "starttls"
    }
  EOT
  type = object({
    host     = string
    port     = optional(number, 587)
    from     = string
    login    = optional(string, null)
    password = optional(string, null)
    secure   = optional(string, "starttls") # none, starttls, ssl
  })
  default   = null
  sensitive = true
}

#------------------------------------------------------------------------------
# Cleanup Rules
#------------------------------------------------------------------------------

variable "cleanup_rules" {
  description = <<-EOT
    Global cleanup rules for builds and artifacts.
    
    Example:
    {
      "default-cleanup" = {
        keep_days           = 30
        keep_builds         = 100
        keep_artifacts_days = 14
        cleanup_artifacts   = true
        cleanup_history     = true
      }
    }
  EOT
  type = map(object({
    keep_days           = optional(number, 30)
    keep_builds         = optional(number, null)
    keep_artifacts_days = optional(number, 7)
    cleanup_artifacts   = optional(bool, true)
    cleanup_history     = optional(bool, false)
  }))
  default = {}
}

#------------------------------------------------------------------------------
# License Configuration
#------------------------------------------------------------------------------

variable "license_keys" {
  description = "List of TeamCity license keys to add."
  type        = list(string)
  default     = []
  sensitive   = true
}

#------------------------------------------------------------------------------
# User Configuration
#------------------------------------------------------------------------------

variable "users" {
  description = <<-EOT
    Map of users to create in TeamCity.
    
    Example:
    {
      "admin" = {
        username = "admin"
        name     = "Administrator"
        email    = "admin@example.com"
        password = "secure-password"
        roles    = ["SYSTEM_ADMIN"]
      }
      "developer" = {
        username = "jsmith"
        name     = "John Smith"
        email    = "jsmith@example.com"
        password = "secure-password"
        roles    = ["PROJECT_DEVELOPER"]
      }
    }
    
    Built-in roles: SYSTEM_ADMIN, PROJECT_ADMIN, PROJECT_DEVELOPER, PROJECT_VIEWER
  EOT
  type = map(object({
    username = string
    name     = optional(string, "")
    email    = optional(string, "")
    password = optional(string, null)
    roles    = optional(list(string), [])
  }))
  default   = {}
  sensitive = true
}

#------------------------------------------------------------------------------
# Group Configuration
#------------------------------------------------------------------------------

variable "groups" {
  description = <<-EOT
    Map of user groups to create.
    
    Example:
    {
      "developers" = {
        name        = "Developers"
        description = "Development team"
        users       = ["jsmith", "jdoe"]
        roles       = ["PROJECT_DEVELOPER"]
        parent_group = null
      }
    }
  EOT
  type = map(object({
    name         = string
    description  = optional(string, "")
    users        = optional(list(string), [])
    roles        = optional(list(string), [])
    parent_group = optional(string, null)
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Role Configuration
#------------------------------------------------------------------------------

variable "custom_roles" {
  description = <<-EOT
    Map of custom roles to create.
    
    Example:
    {
      "deploy-manager" = {
        name        = "Deploy Manager"
        permissions = [
          "RUN_BUILD",
          "VIEW_PROJECT",
          "VIEW_BUILD_CONFIGURATION_SETTINGS"
        ]
        included_roles = ["PROJECT_VIEWER"]
      }
    }
  EOT
  type = map(object({
    name           = string
    permissions    = optional(list(string), [])
    included_roles = optional(list(string), [])
  }))
  default = {}
}

#------------------------------------------------------------------------------
# Project Configuration
#------------------------------------------------------------------------------

variable "projects" {
  description = <<-EOT
    Map of projects to create in TeamCity.
    
    Example:
    {
      "web-app" = {
        id          = "WebApp"
        name        = "Web Application"
        description = "Main web application"
        parent_id   = "_Root"
        vcs_roots = {
          "github" = {
            name        = "GitHub Repo"
            type        = "git"
            url         = "git@github.com:org/repo.git"
            branch      = "refs/heads/main"
            auth_method = "ssh"
            private_key = "..."
          }
        }
        parameters = {
          "env.ENVIRONMENT" = "production"
        }
        versioned_settings = {
          enabled         = true
          vcs_root_id     = "github"
          format          = "kotlin"
          build_settings  = "PREFER_SETTINGS_FROM_VCS"
          show_changes    = true
        }
      }
    }
  EOT
  type = map(object({
    id          = optional(string, "")
    name        = optional(string, "")
    description = optional(string, "")
    parent_id   = optional(string, "_Root")
    archived    = optional(bool, false)
    parameters  = optional(map(string), {})
    vcs_roots = optional(map(object({
      name        = optional(string, "")
      type        = optional(string, "git")
      url         = string
      branch      = optional(string, "refs/heads/main")
      auth_method = optional(string, "anonymous") # anonymous, password, ssh
      username    = optional(string, null)
      password    = optional(string, null)
      private_key = optional(string, null)
      passphrase  = optional(string, null)
    })), {})
    versioned_settings = optional(object({
      enabled        = optional(bool, false)
      vcs_root_key   = optional(string, null)
      format         = optional(string, "kotlin") # kotlin or xml
      build_settings = optional(string, "PREFER_SETTINGS_FROM_VCS")
      show_changes   = optional(bool, true)
    }), null)
  }))
  default   = {}
  sensitive = true
}

#------------------------------------------------------------------------------
# Connection Configuration
#------------------------------------------------------------------------------

variable "connections" {
  description = <<-EOT
    Map of connections (GitHub, GitLab, etc.) to create on the Root project.
    
    Example:
    {
      "github-app" = {
        type              = "github_app"
        display_name      = "GitHub App"
        app_id            = "12345"
        client_id         = "xxx"
        client_secret     = "xxx"
        private_key       = "..."
        webhook_secret    = "xxx"
        owner_url         = "https://github.com/myorg"
      }
      "github-oauth" = {
        type          = "github"
        display_name  = "GitHub OAuth"
        client_id     = "xxx"
        client_secret = "xxx"
      }
    }
  EOT
  type = map(object({
    type           = string # github, github_app, gitlab, bitbucket, space
    display_name   = string
    client_id      = optional(string, null)
    client_secret  = optional(string, null)
    app_id         = optional(string, null)
    private_key    = optional(string, null)
    webhook_secret = optional(string, null)
    owner_url      = optional(string, null)
    server_url     = optional(string, null)
  }))
  default   = {}
  sensitive = true
}

#------------------------------------------------------------------------------
# SSH Keys Configuration
#------------------------------------------------------------------------------

variable "ssh_keys" {
  description = <<-EOT
    Map of SSH keys to upload to projects.
    
    Example:
    {
      "deploy-key" = {
        project_key = "web-app"
        name        = "Deploy Key"
        private_key = "..."
        passphrase  = null
      }
    }
  EOT
  type = map(object({
    project_key = string
    name        = string
    private_key = string
    passphrase  = optional(string, null)
  }))
  default   = {}
  sensitive = true
}

#------------------------------------------------------------------------------
# Agent Pool Configuration
#------------------------------------------------------------------------------

variable "agent_pools" {
  description = <<-EOT
    Map of agent pools to create.
    
    Example:
    {
      "linux-pool" = {
        name         = "Linux Agents"
        max_agents   = 10
        project_ids  = ["WebApp", "ApiGateway"]
      }
    }
  EOT
  type = map(object({
    name        = string
    max_agents  = optional(number, null)
    project_ids = optional(list(string), [])
  }))
  default = {}
}
