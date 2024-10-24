variable "sql_server_name" {
  description = "The name of the SQL Server."
  type        = string
}

variable "database_name" {
  description = "The name of the SQL Database."
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name."
  type        = string
}

variable "location" {
  description = "Azure region where the SQL Database will be created."
  type        = string
}

variable "admin_login" {
  description = "Administrator login name for the SQL Server."
  type        = string
}

variable "admin_password" {
  description = "Administrator password for the SQL Server."
  type        = string
  sensitive   = true
}

variable "service_objective" {
  description = "The service level objective for the database (e.g., S0, S1, P1)."
  type        = string
  default     = "S0"
}
