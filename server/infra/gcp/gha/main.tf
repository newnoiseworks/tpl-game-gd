# NOTE: this may not be needed, as this is for a top level one time project
variable "gcp_project" {
  type = string
}

# output WI info as needed for GH stuff
# output "" {}

# top level project
resource "google_project" "omgd_daemon" {
  name = "OMGD ${var.gcp_project} Daemon"
  project_id = "omgd-${var.gcp_project}-cloud-daemon"
}

# WI pool
resource "google_iam_workload_identity_pool" "omgd_wi_pool" {
  project = google_project.omgd_daemon.id
  workload_identity_pool_id = "omgd-${var.gcp_project}-pool"
}

# WI provider
resource "google_iam_workload_identity_pool_provider" "omgd_wi_pool_provider" {
  project = google_project.omgd_daemon.id
  workload_identity_pool_id = google_iam_workload_identity_pool.omgd_wi_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "omgd-${var.gcp_project}-wipp"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "attribute.actor" = "assertion.actor"
    "google.subject" = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
}

# GCP service account
resource "google_service_account" "sa" {
  account_id = "omgd-${var.gcp_project}-gcpsa"
  display_name = "OMGD ${var.gcp_project} Daemon GCP Service Account"
}

# IAM perms for service account; at least project creation & service enabling
data "google_iam_policy" "omgd_daemon" {
  binding {
    role = "roles/assuredworkloads.admin"

    members = [
      "serviceAccount:omgd-${var.gcp_project}-gcpsa@${google_project.omgd_daemon.id}.iam.gserviceaccount.com",
    ]
  }
}

resource "google_service_account_iam_policy" "omgd_daemon_iam" {
  service_account_id = google_service_account.sa.name
  policy_data = data.google_iam_policy.omgd_daemon.policy_data
}


# also bind project permissions? see medium post re: `$ gcloud projects add-iam-policy-binding`
data "google_iam_policy" "omgd_project" {
  binding {
    role = "roles/iam.workloadIdentityUser"

    members = [
      "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.omgd_wi_pool.id}/attribute.repository/tpl-game-gd", # make repo name a variable in yml profile
      "serviceAccount:omgd-${var.gcp_project}-gcpsa@${google_project.omgd_daemon.id}.iam.gserviceaccount.com",
    ]
  }
}

resource "google_service_account_iam_policy" "omgd_project_iam" {
  service_account_id = google_service_account.sa.name
  policy_data = data.google_iam_policy.omgd_project.policy_data
}
