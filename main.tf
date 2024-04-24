#data "google_secret_manager_secret_version" "postgree_creden" {
#  secret           = "CLOUDSQL_MASTER_PASSWORD"
#  project          = "my-second-project-401808"
#  #pg_master_username   = "postgre_master_username"
#  #pg_master_password   = "postgree_master_password"
#}

#resource "google_sql_database_instance" "pgsql-instance" {
#  name             = "pg-instance"
#  project          = "cellular-tide-421217"
#  region           = "asia-northeast1"
#  database_version = "POSTGRES_14"
#  root_password    = var.root_password
#  settings {
#    tier = "db-custom-2-7680"
#    password_validation_policy {
#      min_length                  = 6
#      reuse_interval              = 2
#      complexity                  = "COMPLEXITY_DEFAULT"
#      disallow_username_substring = true
#      password_change_interval    = "30s"
#      enable_password_policy      = true
#    }
#  }
#  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
#  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
#  deletion_protection = false
#}

#resource "google_sql_database" "default" {
#  name            = "master"
#  project         = google_sql_database_instance.pgsql-instance.project
#  instance        = google_sql_database_instance.pgsql-instance.name
#}

#resource "google_monitoring_dashboard" "dashboard" {
#  project = "cellular-tide-421217"
#  dashboard_json = <<EOF
#{
#  "displayName": "Grid Layout Example",
#  "gridLayout": {
#    "columns": "2",
#    "widgets": [
#      {
#        "title": "Widget 1",
#        "xyChart": {
#          "dataSets": [{
#            "timeSeriesQuery": {
#              "timeSeriesFilter": {
#                "filter": "metric.type=\"agent.googleapis.com/nginx/connections/accepted_count\"",
#                "aggregation": {
#                  "perSeriesAligner": "ALIGN_RATE"
#                }
#              },
#              "unitOverride": "1"
#            },
#            "plotType": "LINE"
#          }],
#          "timeshiftDuration": "0s",
#          "yAxis": {
#            "label": "y1Axis",
#            "scale": "LINEAR"
#          }
#        }
#      },
#      {
#        "text": {
#          "content": "Widget 2",
#          "format": "MARKDOWN"
#        }
#      },
#      {
#        "title": "Widget 3",
#        "xyChart": {
#          "dataSets": [{
#            "timeSeriesQuery": {
#              "timeSeriesFilter": {
#                "filter": "metric.type=\"agent.googleapis.com/nginx/connections/accepted_count\"",
#                "aggregation": {
#                  "perSeriesAligner": "ALIGN_RATE"
#                }
#              },
#              "unitOverride": "1"
#            },
#            "plotType": "STACKED_BAR"
#          }],
#          "timeshiftDuration": "0s",
#          "yAxis": {
#            "label": "y1Axis",
#            "scale": "LINEAR"
#          }
#        }
#      }
#    ]
#  }
#}
#
#EOF
#}

#resource "google_monitoring_metric_descriptor" "basic" {
#  project = "cellular-tide-421217"
#  description = "Daily sales records from all branch stores."
#  display_name = "metric-descriptor"
#  type = "custom.googleapis.com/stores/daily_sales"
#  metric_kind = "GAUGE"
#  value_type = "DOUBLE"
#  unit = "{USD}"
#  labels {
#    key = "store_id"
#    value_type = "STRING"
#    description = "The ID of the store."
#  }
#  launch_stage = "BETA"
#  metadata {
#    sample_period = "60s"
#    ingest_delay = "30s"
#  }
#}

resource "google_monitoring_notification_channel" "basic" {
  project = "cellular-tide-421217"
  display_name = "Test Notification Channel"
  type         = "email"
  labels = {
    email_address = "prabal.saxena@db.com"
  }
  force_delete = false
}

resource "google_monitoring_alert_policy" "alert_policy" {
  project = "cellular-tide-421217"
  enabled = true
  display_name = "Demo Alert Policy"
  combiner     = "OR"

  conditions {
    display_name = "test condition"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/disk/write_bytes_count\" AND resource.type=\"gce_instance\""
      duration   = "60s"
      forecast_options {
        forecast_horizon = "3600s"
      }
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [
  for channel in google_monitoring_notification_channel.basic : "projects/cellular-tide-421217/notificationChannels/2314330700432226190"
  ]
  user_labels = {
    foo = "bar"
  }
}

resource "google_logging_metric" "log_based_metric" {
  project = "cellular-tide-421217"
  name   = "firewall_rules_update"
  filter = "resource.type=\"gce_firewall_rule\" AND severity >= ERROR\n"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "log_matched_alert_policy" {
  project = "cellular-tide-421217"
  enabled = true
  display_name = "matched log alert"
  combiner     = "OR"

  conditions {
    display_name = "demo condition"
    condition_matched_log {
      filter = "protoPayload.methodName=\"v1.compute.networkFirewallPolicies.removeRule\""
    }
  }

  alert_strategy {
    auto_close = "604800s"
    notification_rate_limit {
      period = "300s"
    }
  }

  notification_channels = [
    for channel in google_monitoring_notification_channel.basic : "projects/cellular-tide-421217/notificationChannels/2314330700432226190"
  ]
  user_labels = {
    foo = "bar"
  }
}
