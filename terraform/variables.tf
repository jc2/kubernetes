variable "resource_group_name" {
    type = string
    default = "k8s-group"
}

variable "location" {
    type = string
    default = "East US"
}

variable "acr_name" {
    type = string
    default = "jc2acr"
}

variable "k8s_cluster_name" {
    type = string
    default = "django-cluster"
}

variable "k8s_dns_prefix" {
    type = string
    default = "jc2"
}

variable "k8s_vm_size" {
    type = string
    default = "Standard_D2_v2"
}

variable "db_server_name" {
    type = string
    default = "k8s-db"
}

variable "db_user" {
    type = string
}

variable "db_password" {
    type = string
}

variable "db_name" {
    type = string
}

variable "broker_name" {
    type = string
    default = "k8s-redis"
}

variable "files_account_name" {
    type = string
    default = "jc2storageaccount"
}

variable "files_name" {
    type = string
    default = "djangovolume"
}