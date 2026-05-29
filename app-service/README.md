# App Service OPA Policy — Complete Test Guide

## Folder Structure
```
app-service/
├── terraform/
│   ├── main.tf           ← Compliant + Non-compliant resources
│   ├── variables.tf
│   └── outputs.tf
├── policy/
│   ├── app-service-apps/              ← 18 policies (TC-01 to TC-18)
│   │   ├── tc01_https_only.rego
│   │   ├── tc02_min_tls.rego
│   │   ├── tc03_http2.rego
│   │   ├── tc04_remote_debug_off.rego
│   │   ├── tc05_managed_identity.rego
│   │   ├── tc06_client_cert.rego
│   │   ├── tc07_auth_enabled.rego
│   │   ├── tc08_app_insights.rego
│   │   ├── tc09_no_plaintext_secrets.rego
│   │   ├── tc10_vnet_integration.rego
│   │   ├── tc11_ftps_only.rego
│   │   ├── tc12_always_on.rego
│   │   ├── tc13_health_check.rego
│   │   ├── tc14_diagnostic_settings.rego
│   │   ├── tc15_tags_required.rego
│   │   ├── tc16_ip_restrictions.rego
│   │   ├── tc17_private_endpoint.rego
│   │   └── tc18_no_public_access.rego
│   └── app-service-deployment-slots/  ← 12 policies (DS-TC-01 to DS-TC-12)
│       ├── ds_tc01_https_only.rego
│       ├── ds_tc02_min_tls.rego
│       ├── ds_tc03_http2.rego
│       ├── ds_tc04_remote_debug_off.rego
│       ├── ds_tc05_managed_identity.rego
│       ├── ds_tc06_auth_enabled.rego
│       ├── ds_tc07_app_insights.rego
│       ├── ds_tc08_client_cert.rego
│       ├── ds_tc09_vnet_integration.rego
│       ├── ds_tc10_diagnostic_settings.rego
│       ├── ds_tc11_ftps_only.rego
│       └── ds_tc12_tags_required.rego
└── Run-OPATests.ps1      ← Full automated runner
```

---

## Step 1 — Generate tfplan.json
```powershell
cd app-service\terraform
terraform init
terraform plan -out=tfplan.bin
terraform show -json tfplan.bin | Out-File -Encoding utf8 tfplan.json
```

---

## Step 2 — Run All Tests (One Command)
```powershell
cd app-service\terraform
..\Run-OPATests.ps1
```

---

## Step 3 — Individual Commands

### APP SERVICE APPS

**TC-01 — HTTPS Only**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc01_https_only.rego "data.azure.appservice.apps.tc01_https_only.deny"
```

**TC-02 — Minimum TLS 1.2**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc02_min_tls.rego "data.azure.appservice.apps.tc02_min_tls.deny"
```

**TC-03 — HTTP/2 Enabled**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc03_http2.rego "data.azure.appservice.apps.tc03_http2.deny"
```

**TC-04 — Remote Debugging Off**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc04_remote_debug_off.rego "data.azure.appservice.apps.tc04_remote_debug_off.deny"
```

**TC-05 — Managed Identity**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc05_managed_identity.rego "data.azure.appservice.apps.tc05_managed_identity.deny"
```

**TC-06 — Client Certificate Required**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc06_client_cert.rego "data.azure.appservice.apps.tc06_client_cert.deny"
```

**TC-07 — Authentication Enabled**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc07_auth_enabled.rego "data.azure.appservice.apps.tc07_auth_enabled.deny"
```

**TC-08 — App Insights Connected**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc08_app_insights.rego "data.azure.appservice.apps.tc08_app_insights.deny"
```

**TC-09 — No Plain-Text Secrets**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc09_no_plaintext_secrets.rego "data.azure.appservice.apps.tc09_no_plaintext_secrets.deny"
```

**TC-10 — VNet Integration**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc10_vnet_integration.rego "data.azure.appservice.apps.tc10_vnet_integration.deny"
```

**TC-11 — FTPS Only**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc11_ftps_only.rego "data.azure.appservice.apps.tc11_ftps_only.deny"
```

**TC-12 — Always On**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc12_always_on.rego "data.azure.appservice.apps.tc12_always_on.deny"
```

**TC-13 — Health Check Path**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc13_health_check.rego "data.azure.appservice.apps.tc13_health_check.deny"
```

**TC-14 — Diagnostic Settings**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc14_diagnostic_settings.rego "data.azure.appservice.apps.tc14_diagnostic_settings.deny"
```

**TC-15 — Required Tags**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc15_tags_required.rego "data.azure.appservice.apps.tc15_tags_required.deny"
```

**TC-16 — IP Restrictions**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc16_ip_restrictions.rego "data.azure.appservice.apps.tc16_ip_restrictions.deny"
```

**TC-17 — Private Endpoint**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc17_private_endpoint.rego "data.azure.appservice.apps.tc17_private_endpoint.deny"
```

**TC-18 — No Public Access**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-apps\tc18_no_public_access.rego "data.azure.appservice.apps.tc18_no_public_access.deny"
```

---

### APP SERVICE DEPLOYMENT SLOTS

**DS-TC-01 — HTTPS Only**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc01_https_only.rego "data.azure.appservice.slots.ds_tc01_https_only.deny"
```

**DS-TC-02 — Minimum TLS 1.2**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc02_min_tls.rego "data.azure.appservice.slots.ds_tc02_min_tls.deny"
```

**DS-TC-03 — HTTP/2 Enabled**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc03_http2.rego "data.azure.appservice.slots.ds_tc03_http2.deny"
```

**DS-TC-04 — Remote Debugging Off**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc04_remote_debug_off.rego "data.azure.appservice.slots.ds_tc04_remote_debug_off.deny"
```

**DS-TC-05 — Managed Identity**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc05_managed_identity.rego "data.azure.appservice.slots.ds_tc05_managed_identity.deny"
```

**DS-TC-06 — Authentication Enabled**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc06_auth_enabled.rego "data.azure.appservice.slots.ds_tc06_auth_enabled.deny"
```

**DS-TC-07 — App Insights Connected**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc07_app_insights.rego "data.azure.appservice.slots.ds_tc07_app_insights.deny"
```

**DS-TC-08 — Client Certificate Required**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc08_client_cert.rego "data.azure.appservice.slots.ds_tc08_client_cert.deny"
```

**DS-TC-09 — VNet Integration**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc09_vnet_integration.rego "data.azure.appservice.slots.ds_tc09_vnet_integration.deny"
```

**DS-TC-10 — Diagnostic Settings**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc10_diagnostic_settings.rego "data.azure.appservice.slots.ds_tc10_diagnostic_settings.deny"
```

**DS-TC-11 — FTPS Only**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc11_ftps_only.rego "data.azure.appservice.slots.ds_tc11_ftps_only.deny"
```

**DS-TC-12 — Required Tags**
```powershell
C:\Tools\OPA\opa.exe eval --input tfplan.json --data ..\policy\app-service-deployment-slots\ds_tc12_tags_required.rego "data.azure.appservice.slots.ds_tc12_tags_required.deny"
```

---

## Expected Results

| TC       | Resource          | Expected | Rule |
|----------|-------------------|----------|------|
| TC-01    | non_compliant     | ❌ FAIL  | https_only = false |
| TC-02    | non_compliant     | ❌ FAIL  | TLS 1.0 |
| TC-03    | non_compliant     | ❌ FAIL  | http2 disabled |
| TC-04    | non_compliant     | ❌ FAIL  | remote debug ON |
| TC-05    | non_compliant     | ❌ FAIL  | no identity |
| TC-06    | non_compliant     | ❌ FAIL  | no client cert |
| TC-07    | non_compliant     | ❌ FAIL  | no auth_settings |
| TC-08    | non_compliant     | ❌ FAIL  | no App Insights |
| TC-09    | non_compliant     | ❌ FAIL  | plain-text DB_PASSWORD |
| TC-10    | non_compliant     | ❌ FAIL  | no VNet integration |
| TC-11    | non_compliant     | ❌ FAIL  | FTP allowed |
| TC-12    | compliant         | ✅ PASS  | P-tier sets always_on |
| TC-13    | compliant         | ✅ PASS  | health_check_path = /health |
| TC-14    | compliant         | ✅ PASS  | diagnostic setting exists |
| TC-15    | compliant         | ✅ PASS  | 3 required tags present |
| TC-16    | restricted        | ✅ PASS  | IP restriction block present |
| TC-17    | compliant         | ✅ PASS  | private endpoint defined |
| TC-18    | compliant         | ✅ PASS  | deny-all rule + PE present |
| DS-TC-01 | slot_non_compliant| ❌ FAIL  | https_only = false |
| DS-TC-02 | slot_non_compliant| ❌ FAIL  | TLS 1.0 |
| DS-TC-03 | slot_non_compliant| ❌ FAIL  | http2 disabled |
| DS-TC-04 | slot_non_compliant| ❌ FAIL  | remote debug ON |
| DS-TC-05 | slot_non_compliant| ❌ FAIL  | no identity |
| DS-TC-06 | slot_non_compliant| ❌ FAIL  | no auth_settings |
| DS-TC-07 | slot_non_compliant| ❌ FAIL  | no App Insights |
| DS-TC-08 | slot_non_compliant| ❌ FAIL  | no client cert |
| DS-TC-09 | slot_non_compliant| ❌ FAIL  | no VNet |
| DS-TC-10 | slot_compliant    | ✅ PASS  | diagnostic setting exists |
| DS-TC-11 | slot_non_compliant| ❌ FAIL  | FTP allowed |
| DS-TC-12 | slot_non_compliant| ❌ FAIL  | no tags |
