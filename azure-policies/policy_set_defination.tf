locals {
  policy_def_files = fileset("./policy_set_definations", "*.json")
  policy_def_file_raw_data = [for def_file_data in local.policy_def_files : jsondecode(file("./policy_set_definations/${def_file_data}"))]
}


resource "azurerm_policy_set_definition" "policy_set" {
  for_each = {for policy_set_def in local.policy_def_file_raw_data : policy_set_def.properties.displayName => policy_set_def  }

  name         = each.value.properties.displayName
  policy_type  = each.value.properties.policyType
  display_name = each.value.properties.displayName

  parameters = jsonencode("${each.value.properties.parameters}")

  dynamic "policy_definition_reference" {
    for_each = [
      for item in each.value.properties.policyDefinitions :
      {
          policyDefinitionId          = item.policyDefinitionId
          parameters                  = try(jsonencode(item.parameters), null)
          policyDefinitionReferenceId = try(item.policyDefinitionReferenceId, null)
      }
    ]
    content {
      policy_definition_id = policy_definition_reference.value["policyDefinitionId"]
      parameter_values     = policy_definition_reference.value["parameters"]
      reference_id         = policy_definition_reference.value["policyDefinitionReferenceId"]
    }
  }
}
