resource "azurerm_dns_zone" "example_dns" {
  name                = "example.com"
  resource_group_name = azurerm_resource_group.example_rg.name
}

resource "azurerm_dns_a_record" "example_dns_a" {
  name                = "www"
  zone_name           = azurerm_dns_zone.example_dns.name
  resource_group_name = azurerm_resource_group.example_rg.name
  ttl                 = 300
  records             = ["1.2.3.4"]
}
