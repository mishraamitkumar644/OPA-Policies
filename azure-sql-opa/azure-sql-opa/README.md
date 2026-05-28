# Azure SQL OPA Compliance Tests
## Directory Structure

```
azure-sql-opa/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
└── policy/
    ├── tc01_tde_cmk.rego
    ├── tc02_data_encryption.rego
    ├── tc03_min_tls.rego
    ├── tc04_entra_auth.rego
    ├── tc05_auditing_enabled.rego
    ├── tc06_audit_retention.rego
    ├── tc07_public_network_access.rego
    └── tc08_firewall_rules.rego
```

---

## Prerequisites

```bash
# Install OPA
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64_static
chmod +x opa
sudo mv opa /usr/local/bin/

# Verify
opa version
```

---

## Step 1 — Terraform Setup

```bash
cd terraform

# Copy and fill in your values
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your actual values

# Init and plan
terraform init
terraform plan -out=tfplan.binary

# Convert plan to JSON for OPA
terraform show -json tfplan.binary > tfplan.json
```

---

## Step 2 — Run OPA Tests (Each Policy Separately)

```bash
# TC-01: TDE with Customer Managed Key
opa eval \
  --input tfplan.json \
  --data ../policy/tc01_tde_cmk.rego \
  "data.azure.sql.tc01_tde_cmk.deny"

# TC-02: Data Encryption ON
opa eval \
  --input tfplan.json \
  --data ../policy/tc02_data_encryption.rego \
  "data.azure.sql.tc02_data_encryption.deny"

# TC-03: Minimum TLS 1.2
opa eval \
  --input tfplan.json \
  --data ../policy/tc03_min_tls.rego \
  "data.azure.sql.tc03_min_tls.deny"

# TC-04: Entra Authentication
opa eval \
  --input tfplan.json \
  --data ../policy/tc04_entra_auth.rego \
  "data.azure.sql.tc04_entra_auth.deny"

# TC-05: Auditing Enabled
opa eval \
  --input tfplan.json \
  --data ../policy/tc05_auditing_enabled.rego \
  "data.azure.sql.tc05_auditing_enabled.deny"

# TC-06: Audit Retention > 90 days
opa eval \
  --input tfplan.json \
  --data ../policy/tc06_audit_retention.rego \
  "data.azure.sql.tc06_audit_retention.deny"

# TC-07: Public Network Access Disabled
opa eval \
  --input tfplan.json \
  --data ../policy/tc07_public_network_access.rego \
  "data.azure.sql.tc07_public_network_access.deny"

# TC-08: No Overly Permissive Firewall Rules
opa eval \
  --input tfplan.json \
  --data ../policy/tc08_firewall_rules.rego \
  "data.azure.sql.tc08_firewall_rules.deny"
```

---

## Step 3 — Run ALL Policies at Once

```bash
opa eval \
  --input tfplan.json \
  --data ../policy/ \
  "data"
```

---

## Step 4 — Run as Pass/Fail (CI/CD style)

```bash
# This returns exit code 1 if any deny rule fires
opa eval \
  --input tfplan.json \
  --data ../policy/ \
  --fail-defined \
  "data.azure.sql.tc01_tde_cmk.deny" \
  "data.azure.sql.tc02_data_encryption.deny" \
  "data.azure.sql.tc03_min_tls.deny" \
  "data.azure.sql.tc04_entra_auth.deny" \
  "data.azure.sql.tc05_auditing_enabled.deny" \
  "data.azure.sql.tc06_audit_retention.deny" \
  "data.azure.sql.tc07_public_network_access.deny" \
  "data.azure.sql.tc08_firewall_rules.deny"

echo "Exit code: $?"
# 0 = all passed, 1 = one or more failed
```

---

## Expected Output

### PASS (empty array = no violations):
```json
{
  "result": [
    {
      "expressions": [
        {
          "value": [],
          "text": "data.azure.sql.tc01_tde_cmk.deny"
        }
      ]
    }
  ]
}
```

### FAIL (violation message returned):
```json
{
  "result": [
    {
      "expressions": [
        {
          "value": [
            "TC-01 FAIL: Resource 'azurerm_mssql_server_transparent_data_encryption.tde' — TDE must use a Customer Managed Key."
          ]
        }
      ]
    }
  ]
}
```

---

## Test Cases Summary

| TC   | Resource                                          | What is Checked                        |
|------|---------------------------------------------------|----------------------------------------|
| TC-01 | azurerm_mssql_server_transparent_data_encryption | TDE uses Customer Managed Key          |
| TC-02 | azurerm_mssql_database                           | transparent_data_encryption = true     |
| TC-03 | azurerm_mssql_server                             | minimum_tls_version = 1.2 or 1.3      |
| TC-04 | azurerm_mssql_server                             | Entra admin configured with object_id  |
| TC-05 | azurerm_mssql_server_extended_auditing_policy    | enabled = true + storage configured    |
| TC-06 | azurerm_mssql_server_extended_auditing_policy    | retention_in_days > 90                 |
| TC-07 | azurerm_mssql_server                             | public_network_access_enabled = false  |
| TC-08 | azurerm_mssql_firewall_rule                      | No 0.0.0.0/255.255.255.255 rules       |
