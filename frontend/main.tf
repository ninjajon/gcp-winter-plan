//create a service account
resource "google_service_account" "cloudrun_sa" {
  project      = var.project
  account_id   = "${var.prefix}-run-sa"
  display_name = "Cloud Run Service Account"
}

//assign roles to the service account
resource "google_project_iam_member" "cloudrun_sa_roles" {
  project = var.project
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_cloud_run_service" "cloud_run_srv" {
  project  = var.project
  name     = "${var.prefix}-run"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/run:${var.image_version}"
      }
      service_account_name = google_service_account.cloudrun_sa.email

    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.cloud_run_srv.location
  project  = google_cloud_run_service.cloud_run_srv.project
  service  = google_cloud_run_service.cloud_run_srv.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

# create a serverless neg for my cloud run
resource "google_compute_region_network_endpoint_group" "default" {
  project               = var.project
  name                  = "${var.prefix}-run-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.cloud_run_srv.name
  }
}

module "lb" {
  source = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"

  project = var.project
  name    = "${var.prefix}-run"

  ssl                             = true
  managed_ssl_certificate_domains = [var.dns_name]
  https_redirect                  = true
  backends = {
    default = {
      description            = null
      enable_cdn             = false
      custom_request_headers = null

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group = google_compute_region_network_endpoint_group.default.id
        }
      ]

      iap_config = {
        enable               = true
        oauth2_client_id     = "486962734106-hkhtpouo54hl4nvav54cr6htnaoq4f3q.apps.googleusercontent.com"
        oauth2_client_secret = "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"
      }

      security_policy = null
    }
  }
}

# create a DNS record for my load balancer
resource "google_dns_record_set" "default" {
  name         = "${var.dns_name}."
  type         = "A"
  ttl          = 300
  managed_zone = "ninjajon-com"
  rrdatas      = [module.lb.external_ip]
  depends_on   = [module.lb]
}

# data project details
data "google_project" "project" {
  project_id = var.project
}

# assign Cloud Run Invoker role to the IAP default service account
resource "google_project_iam_member" "iap_invoker" {
  project = var.project
  role    = "roles/run.invoker"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-iap.iam.gserviceaccount.com"
}
