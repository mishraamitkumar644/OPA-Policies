# TC-09: App settings must not contain plain-text secrets
package azure.appservice.apps.tc09_no_plaintext_secrets

import future.keywords.if
import future.keywords.in

# Patterns that suggest plain-text secrets
sensitive_keys := {
  "password", "secret", "key", "token", "credential",
  "pwd", "pass", "api_key", "apikey", "connectionstring"
}

is_keyvault_ref(value) if {
  startswith(lower(value), "@microsoft.keyvault(")
}

is_env_var(value) if {
  startswith(value, "$(")
}

deny[msg] if {
  resource := input.planned_values.root_module.resources[_]
  resource.type == "azurerm_linux_web_app"
  settings := resource.values.app_settings
  [k, v] := [key, val] | [key, val] := object.get(settings, _, _); key := k; val := v
  lower_key := lower(k)
  sensitive_key := sensitive_keys[_]
  contains(lower_key, sensitive_key)
  not is_keyvault_ref(v)
  not is_env_var(v)
  msg := sprintf("FAIL TC-09: App '%s' app_setting '%s' appears to contain a plain-text secret. Use Key Vault reference.", [resource.address, k])
}
