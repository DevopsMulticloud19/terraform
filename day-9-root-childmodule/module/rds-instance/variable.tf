variable "db_instance_name" {
  description = "Name of the RDS instance"
  default     = ""
}

variable "db_username" {
  description = "Master DB username"
  default     = ""
}

variable "db_password" {
  description = "Master DB password"
  default     = ""
}

variable "db_instance_class" {
  description = "Instance type for RDS"
  default     = ""

}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  default     = 
}

variable "engine" {
  description = "Database engine (e.g., mysql, postgres)"
  default     = ""
}

