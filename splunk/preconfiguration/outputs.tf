output "hec_tokens" {
  value = zipmap(keys(splunk_inputs_http_event_collector.hec-token)[*], values(splunk_inputs_http_event_collector.hec-token)[*].token)
}

output "hec_token_index" {
  value = var.hec_token_index
}
