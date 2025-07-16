output "maas_api_url" {
  value = data.external.maas_get_api_url.result.api_url
}

output "maas_api_key" {
  value = data.external.maas_get_api_key.result.api_key
}

output "maas_machines" {
  value = split(",", data.external.maas_get_rack_controllers.result.machines)
}
