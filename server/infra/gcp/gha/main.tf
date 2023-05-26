# NOTE: this may not be needed, as this is for a top level one time project
variable "gcp_project" {
  type = string
}

# output WI info as needed for GH stuff
# output "" {}

# WI pool
resource "google_iam_workload_identity_pool" "omgd_wi_pool" {
  project                   = var.gcp_project
  workload_identity_pool_id = "${var.gcp_project}-ghac-wip"
}

# WI provider
resource "google_iam_workload_identity_pool_provider" "omgd_wip_provider" {
  project                            = var.gcp_project
  workload_identity_pool_id          = google_iam_workload_identity_pool.omgd_wi_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "${var.gcp_project}-ghac-wipp"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "attribute.actor"      = "assertion.actor"
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
}

# GCP service account
resource "google_service_account" "sa" {
  project      = var.gcp_project
  account_id   = "omgd-${var.gcp_project}-sa"
}

# IAM perms for service account; at least project creation & service enabling
data "google_iam_policy" "omgd_project" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = [
      "serviceAccount:omgd-${var.gcp_project}-sa@${var.gcp_project}.iam.gserviceaccount.com",
    ]
  }
}

resource "google_service_account_iam_policy" "omgd_project_iam" {
  service_account_id = google_service_account.sa.name
  policy_data        = data.google_iam_policy.omgd_project.policy_data
}

output "wip" {
  value = google_iam_workload_identity_pool.omgd_wi_pool.id
}

output "wipp" {
  value = google_iam_workload_identity_pool_provider.omgd_wip_provider.name
}

output "sa" {
  value = google_service_account.sa.email
}
