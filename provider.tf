terraform {
  required_providers {
    apstra = {
      source = "Juniper/apstra"
    }
  }
}
provider "apstra" {
  url                     = "https://admin:ReliableCow0%2B@13.38.52.89:21359" 
  tls_validation_disabled = true 
  blueprint_mutex_enabled = false 
  api_timeout             = 0
  experimental            = true
}
