# name of project on GCP
variable "gcp_project" {
  type = string
}

# salt for updating below resources in real time as GCP caches many of them, particularly the WIPP
variable "gcp_resource_version" {
  type = number
	default = 4
}

# output WI info as needed for GH stuff
# output "" {}

# WI pool
resource "google_iam_workload_identity_pool" "omgd_wi_pool" {
  project                   = var.gcp_project
  workload_identity_pool_id = "${var.gcp_project}-ghac-wip-${var.gcp_resource_version}"
}

# WI provider
resource "google_iam_workload_identity_pool_provider" "omgd_wip_provider" {
  project                            = var.gcp_project
  workload_identity_pool_id          = google_iam_workload_identity_pool.omgd_wi_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "${var.gcp_project}-ghac-wipp-${var.gcp_resource_version}"

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
  account_id   = "omgd-${var.gcp_project}-sa-${var.gcp_resource_version}"
}

# IAM perms for service account; at least project creation & service enabling
data "google_iam_policy" "omgd_project" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = [
      "serviceAccount:omgd-${var.gcp_project}-sa-${var.gcp_resource_version}@${var.gcp_project}.iam.gserviceaccount.com",
      "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.omgd_wi_pool.name}/attribute.repository/newnoiseworks/tpl-game-gd"
    ]
  }
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      "serviceAccount:omgd-${var.gcp_project}-sa-${var.gcp_resource_version}@${var.gcp_project}.iam.gserviceaccount.com",
      "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.omgd_wi_pool.name}/attribute.repository/newnoiseworks/tpl-game-gd"
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
