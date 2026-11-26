terraform {
  # OpenTofu managed
  required_version = ">= 1.13.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.29"
    }
  }

  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "cloudflare/zetlabs.net/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true

    endpoints = {
      s3 = "https://e0924c382d21ac0f10aee606b82687ce.r2.cloudflarestorage.com"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "cloudflare_zone_id" {
  description = "Zone ID"
  type        = string
  default     = "691ceca457f17b055c015aae77c1a6bc"
}

variable "cloudflare_api_token" {
  description = "API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_domain" {
  description = "Domain"
  type        = string
  default     = "zetlabs.net"
}
