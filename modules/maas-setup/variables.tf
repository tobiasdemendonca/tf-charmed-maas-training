variable "ubuntu_version" {
  description = "The OS version to install on the VMs"
  type        = string
  default     = "24.04"
}

variable "juju_cloud_name" {
  description = "The Juju cloud name to deploy charmed MAAS model"
  type        = string
}

variable "enable_postgres_ha" {
  description = "Whether to enable PostgreSQL HA"
  type        = bool
  default     = false
}

variable "enable_maas_ha" {
  description = "Whether to enable MAAS HA"
  type        = bool
  default     = false
}

variable "lxd_project" {
  description = "The LXD project to deploy Juju machines"
  type        = string
  default     = "default"
}

###
## PostgreSQL configuration
###
variable "charm_postgresql_channel" {
  description = "Operator channel for PostgreSQL deployment"
  type        = string
  default     = "16/candidate"
}

variable "charm_postgresql_revision" {
  description = "Operator channel revision for PostgreSQL deployment"
  type        = number
  default     = null
}

variable "charm_postgresql_config" {
  description = "Operator config for PostgreSQL deployment"
  type        = map(string)
  default     = {}
}

variable "max_connections" {
  description = "Maximum number of concurrent connections to allow to the database server"
  type        = string
  default     = "default"
}

variable "max_connections_per_region" {
  description = "Maximum number of concurrent connections to allow to the database server per region"
  type        = number
  default     = 50
}

###
## MAAS Region configuration
###

variable "charm_maas_region_channel" {
  description = "Operator channel for MAAS Region Controller deployment"
  type        = string
  default     = "3.6/edge"
}

variable "charm_maas_region_revision" {
  description = "Operator channel revision for MAAS Region Controller deployment"
  type        = number
  default     = null
}

variable "charm_maas_region_config" {
  description = "Operator config for MAAS Region Controller deployment"
  type        = map(string)
  default     = {}
}

###
## MAAS Agent configuration
###

variable "enable_rack_mode" {
  description = "Whether to enable MAAS running in region+rack mode"
  type        = bool
  default     = false
}

variable "charm_maas_agent_channel" {
  description = "Operator channel for MAAS Agent Controller deployment"
  type        = string
  default     = "3.6/edge"
}

variable "charm_maas_agent_revision" {
  description = "Operator channel revision for MAAS Agent Controller deployment"
  type        = number
  default     = null
}

variable "charm_maas_agent_config" {
  description = "Operator config for MAAS Agent Controller deployment"
  type        = map(string)
  default     = {}
}

###
## MAAS Admin configuration
###

variable "admin_username" {
  description = "The MAAS admin username"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "The MAAS admin password"
  type        = string
  sensitive   = true
  default     = "insecure"
}

variable "admin_email" {
  description = "The MAAS admin email"
  type        = string
  default     = "admin@maas.io"
}

variable "admin_ssh_import" {
  description = "The MAAS admin SSH key source. Valid sources include 'lp' for Launchpad and 'gh' for GitHub. E.g. 'lp:my_launchpad_username'."
  type        = string
  default     = ""
}
