# Create Azure Policy Definition
resource "azurerm_policy_definition" "example_policy" {
  name         = "policy-deny-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Public IPs"
  
  # Policy Rule JSON structure
  policy_rule = <<POLICY_RULE
  {
    "if": {
      "field": "Microsoft.Network/publicIPAddresses",
      "exists": "true"
    },
    "then": {
      "effect": "deny"
    }
  }
  POLICY_RULE

  description = "This policy denies the creation of public IP addresses."
}

# Assign Policy to a Resource Group
resource "azurerm_policy_assignment" "example_assignment" {
  name                 = "deny-public-ip-assignment"
  policy_definition_id = azurerm_policy_definition.example_policy.id
  scope                = azurerm_resource_group.rg.id
}
