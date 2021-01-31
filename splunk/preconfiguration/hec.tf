resource "splunk_global_http_event_collector" "http" {
  disabled = false
  enable_ssl = true
  port = 8088
}

resource "splunk_inputs_http_event_collector" "hec-token" {
  for_each = toset(var.nodes[*].alias)
  name       = each.value
  index      = "main"
  indexes    = ["main", "history", "summary"]
  sourcetype = "log4j"
  disabled   = false
  use_ack    = 0
}