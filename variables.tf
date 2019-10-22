variable "name" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "db" {
  type = "map"
}

variable "postgres_admin_password" { type = "string" }

variable "tags" {
  type = "map"
}
