###############################################################################
# Prompted variables (user will be asked to supply them at plan/apply time
# if a .tfvars file is not supplied); there are no default values
###############################################################################

variable "admin_email" {
  type        = string
  description = "REQUIRED.  Email address of the administrator of this HPCC Systems cluster.\nExample entry: jane.doe@hpccsystems.com"
  validation {
    condition     = length(regexall("^[^@]+@[^@]+$", var.admin_email)) > 0
    error_message = "Value must at least look like a valid email address."
  }
}

variable "admin_name" {
  type        = string
  description = "REQUIRED.  Name of the administrator of this HPCC Systems cluster.\nExample entry: Jane Doe"
}

variable "admin_username" {
  type        = string
  description = "REQUIRED.  Username of the administrator of this HPCC Systems cluster.\nExample entry: jdoe"
  validation {
    condition     = length(var.admin_username) > 1 && length(regexall(" ", var.admin_username)) == 0
    error_message = "Value must at least two characters in length and contain no spaces."
  }
}

variable "azure_region" {
  type        = string
  description = "REQUIRED.  The Azure region abbreviation in which to create these resources.\nMust be one of [\"eastus\", \"eastus2\", \"centralus\"].\nExample entry: eastus2"
  validation {
    condition     = contains(["eastus", "eastus2", "centralus"], var.azure_region)
    error_message = "Value must be one of [\"eastus\", \"eastus2\", \"centralus\"]."
  }
}

variable "enable_premium_storage" {
  description = "OPTIONAL.  If true, premium ($$$) storage will be created for the following storage shares: Dali.\nDefaults to false."
  type        = bool
  default     = false
}

variable "extra_tags" {
  description = "OPTIONAL.  Map of name => value tags that can will be associated with the cluster.\nFormat is '{\"name\"=\"value\" [, \"name\"=\"value\"]*}'.\nThe 'name' portion must be unique.\nTo add no tags, enter '{}'."
  type        = map(string)
  default     = {}
}

variable "product_name" {
  type        = string
  description = "REQUIRED.  Abbreviated product name, suitable for use in Azure naming.\nMust be 2-23 characters in length, all lowercase or numeric characters.\nExample entry: myproduct"
  validation {
    condition     = length(regexall("^[a-z][a-z0-9]{1,22}$", var.product_name)) == 1
    error_message = "Value must be 2-23 characters in length, all lowercase letters or numbers, no spaces."
  }
}

variable "storage_dali_gb" {
  type        = number
  default     = 250
  description = "OPTIONAL.  The amount of storage reserved for Dali in gigabytes.\nMust be 10 or more.\nOPTIONAL, defaults to 250."
  validation {
    condition     = var.storage_dali_gb >= 10
    error_message = "Value must be 10 or more."
  }
}

variable "storage_data_gb" {
  type        = number
  default     = 500
  description = "OPTIONAL.  The amount of storage reserved for data in gigabytes.\nMust be 10 or more.\nOPTIONAL, defaults to 500."
  validation {
    condition     = var.storage_data_gb >= 10
    error_message = "Value must be 10 or more."
  }
}

variable "storage_lz_gb" {
  type        = number
  default     = 10
  description = "OPTIONAL.  The amount of storage reserved for the landing zone in gigabytes.\nMust be 1 or more.\nOPTIONAL, defaults to 10."
  validation {
    condition     = var.storage_lz_gb >= 1
    error_message = "Value must be 1 or more."
  }
}
