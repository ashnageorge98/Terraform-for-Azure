variable "storage_account_name" {
  description = "The name of the storage account."
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name."
  type        = string
}

variable "location" {
  description = "Azure region where the storage account will be created."
  type        = string
}

variable "account_tier" {
  description = "Tier of the storage account. Can be Standard or Premium."
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Replication type. Options: LRS, GRS, RA-GRS."
  type        = string
  default     = "LRS"
}

variable "container_name" {
  description = "The name of the storage container."
  type        = string
}

variable "container_access_type" {
  description = "Access type of the container (blob, container)."
  type        = string
  default     = "private"
}
