###############################################################
# OPA Test Runner — App Service Apps + Deployment Slots
# Run from: app-service\terraform\
###############################################################

param(
    [string]$OpaPath    = "C:\Tools\OPA\opa.exe",
    [string]$TfPlanJson = "tfplan.json",
    [string]$PolicyRoot = "..\policy"
)

# ── Colour helpers ────────────────────────────────────────────
function Write-Pass($msg) { Write-Host "  ✅ PASS  $msg" -ForegroundColor Green }
function Write-Fail($msg) { Write-Host "  ❌ FAIL  $msg" -ForegroundColor Red   }
function Write-Info($msg) { Write-Host "  ℹ  $msg"        -ForegroundColor Gray  }

# ── Ensure tfplan.json exists ─────────────────────────────────
if (-not (Test-Path $TfPlanJson)) {
    Write-Host "`n[ERROR] $TfPlanJson not found. Run:" -ForegroundColor Red
    Write-Host "  terraform plan -out=tfplan.bin" -ForegroundColor Yellow
    Write-Host "  terraform show -json tfplan.bin | Out-File -Encoding utf8 tfplan.json" -ForegroundColor Yellow
    exit 1
}

###############################################################
# App Service Apps — 18 Test Cases
###############################################################
$appPolicies = @(
    @{ id="TC-01";  file="tc01_https_only";          pkg="azure.appservice.apps.tc01_https_only" },
    @{ id="TC-02";  file="tc02_min_tls";             pkg="azure.appservice.apps.tc02_min_tls" },
    @{ id="TC-03";  file="tc03_http2";               pkg="azure.appservice.apps.tc03_http2" },
    @{ id="TC-04";  file="tc04_remote_debug_off";    pkg="azure.appservice.apps.tc04_remote_debug_off" },
    @{ id="TC-05";  file="tc05_managed_identity";    pkg="azure.appservice.apps.tc05_managed_identity" },
    @{ id="TC-06";  file="tc06_client_cert";         pkg="azure.appservice.apps.tc06_client_cert" },
    @{ id="TC-07";  file="tc07_auth_enabled";        pkg="azure.appservice.apps.tc07_auth_enabled" },
    @{ id="TC-08";  file="tc08_app_insights";        pkg="azure.appservice.apps.tc08_app_insights" },
    @{ id="TC-09";  file="tc09_no_plaintext_secrets";pkg="azure.appservice.apps.tc09_no_plaintext_secrets" },
    @{ id="TC-10";  file="tc10_vnet_integration";    pkg="azure.appservice.apps.tc10_vnet_integration" },
    @{ id="TC-11";  file="tc11_ftps_only";           pkg="azure.appservice.apps.tc11_ftps_only" },
    @{ id="TC-12";  file="tc12_always_on";           pkg="azure.appservice.apps.tc12_always_on" },
    @{ id="TC-13";  file="tc13_health_check";        pkg="azure.appservice.apps.tc13_health_check" },
    @{ id="TC-14";  file="tc14_diagnostic_settings"; pkg="azure.appservice.apps.tc14_diagnostic_settings" },
    @{ id="TC-15";  file="tc15_tags_required";       pkg="azure.appservice.apps.tc15_tags_required" },
    @{ id="TC-16";  file="tc16_ip_restrictions";     pkg="azure.appservice.apps.tc16_ip_restrictions" },
    @{ id="TC-17";  file="tc17_private_endpoint";    pkg="azure.appservice.apps.tc17_private_endpoint" },
    @{ id="TC-18";  file="tc18_no_public_access";    pkg="azure.appservice.apps.tc18_no_public_access" }
)

###############################################################
# App Service Deployment Slots — 12 Test Cases
###############################################################
$slotPolicies = @(
    @{ id="DS-TC-01"; file="ds_tc01_https_only";        pkg="azure.appservice.slots.ds_tc01_https_only" },
    @{ id="DS-TC-02"; file="ds_tc02_min_tls";           pkg="azure.appservice.slots.ds_tc02_min_tls" },
    @{ id="DS-TC-03"; file="ds_tc03_http2";             pkg="azure.appservice.slots.ds_tc03_http2" },
    @{ id="DS-TC-04"; file="ds_tc04_remote_debug_off";  pkg="azure.appservice.slots.ds_tc04_remote_debug_off" },
    @{ id="DS-TC-05"; file="ds_tc05_managed_identity";  pkg="azure.appservice.slots.ds_tc05_managed_identity" },
    @{ id="DS-TC-06"; file="ds_tc06_auth_enabled";      pkg="azure.appservice.slots.ds_tc06_auth_enabled" },
    @{ id="DS-TC-07"; file="ds_tc07_app_insights";      pkg="azure.appservice.slots.ds_tc07_app_insights" },
    @{ id="DS-TC-08"; file="ds_tc08_client_cert";       pkg="azure.appservice.slots.ds_tc08_client_cert" },
    @{ id="DS-TC-09"; file="ds_tc09_vnet_integration";  pkg="azure.appservice.slots.ds_tc09_vnet_integration" },
    @{ id="DS-TC-10"; file="ds_tc10_diagnostic_settings";pkg="azure.appservice.slots.ds_tc10_diagnostic_settings" },
    @{ id="DS-TC-11"; file="ds_tc11_ftps_only";         pkg="azure.appservice.slots.ds_tc11_ftps_only" },
    @{ id="DS-TC-12"; file="ds_tc12_tags_required";     pkg="azure.appservice.slots.ds_tc12_tags_required" }
)

function Run-PolicyGroup {
    param($Title, $PolicySubDir, $Policies)

    Write-Host "`n" + ("=" * 62) -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host ("=" * 62) -ForegroundColor Cyan

    $pass = 0; $fail = 0; $errors = 0

    foreach ($p in $Policies) {
        $regoPath = "$PolicyRoot\$PolicySubDir\$($p.file).rego"
        $query    = "$($p.pkg).deny"

        Write-Host "`n  [$($p.id)]" -ForegroundColor White

        if (-not (Test-Path $regoPath)) {
            Write-Host "  ⚠  Policy file not found: $regoPath" -ForegroundColor Yellow
            $errors++
            continue
        }

        try {
            $raw     = & $OpaPath eval --input $TfPlanJson --data $regoPath $query 2>&1
            $json    = $raw | ConvertFrom-Json
            $results = $json.result[0].expressions[0].value

            if ($null -eq $results -or $results.Count -eq 0) {
                Write-Pass "No violations"
                $pass++
            } else {
                foreach ($v in $results) { Write-Fail $v }
                $fail++
            }
        } catch {
            Write-Host "  ⚠  Error running OPA: $_" -ForegroundColor Yellow
            $errors++
        }
    }

    Write-Host "`n  Summary: PASS=$pass  FAIL=$fail  ERROR=$errors" -ForegroundColor Magenta
    return @{ pass=$pass; fail=$fail; errors=$errors }
}

# ── Run both groups ───────────────────────────────────────────
$r1 = Run-PolicyGroup "APP SERVICE APPS (TC-01 to TC-18)"      "app-service-apps"            $appPolicies
$r2 = Run-PolicyGroup "APP SERVICE DEPLOYMENT SLOTS (DS-TC-01 to DS-TC-12)" "app-service-deployment-slots" $slotPolicies

# ── Grand total ───────────────────────────────────────────────
$totalPass   = $r1.pass   + $r2.pass
$totalFail   = $r1.fail   + $r2.fail
$totalErrors = $r1.errors + $r2.errors

Write-Host "`n" + ("=" * 62) -ForegroundColor Yellow
Write-Host " GRAND TOTAL — PASS: $totalPass   FAIL: $totalFail   ERRORS: $totalErrors" -ForegroundColor Yellow
Write-Host ("=" * 62) -ForegroundColor Yellow
