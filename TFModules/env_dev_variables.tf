variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "sql_admin_password" {
  description = "The admin password for the SQL Server"
  type        = string
  sensitive   = true
}
