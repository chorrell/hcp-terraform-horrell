# Email addresses are kept out of the code. Their values are Terraform variables on the hcp-terraform workspace, set in
# the HCP UI. Plans run remotely, so a local `terraform plan` uses them too. Both are sensitive, so plan output and the
# HCP UI redact them; the values are still stored in state.

variable "organization_email" {
  description = "Admin email address of the horrell organization"
  type        = string
  sensitive   = true
}

variable "alert_emails" {
  description = "Addresses for the horrell-ca workspace's alert_emails variable"
  type        = list(string)
  sensitive   = true
}
