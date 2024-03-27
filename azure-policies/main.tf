data "azurerm_management_group" "mg" {
  name = "VIITOR_ROOT"
}
locals {
  policy_files = fileset("./policy-defination", "*.json")
  policy_raw_data = [for policy_file in local.policy_files : jsondecode(file("./policy-defination/${policy_file}"))]
}

resource "azurerm_policy_definition" "def" {
  for_each = {for policy_data in local.policy_raw_data : policy_data.properties.displayName => policy_data }
  name         = each.value.properties.displayName
  display_name = each.value.properties.displayName
  description  = each.value.properties.description
  policy_type  = each.value.properties.policyType
  mode         = each.value.properties.mode

  management_group_id = data.azurerm_management_group.mg.id

  metadata    = jsonencode("${each.value.properties.metadata}")
  parameters  = jsonencode("${each.value.properties.parameters}")
  policy_rule = jsonencode("${each.value.properties.policyRule}")

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    read = "10m"
  }
}
