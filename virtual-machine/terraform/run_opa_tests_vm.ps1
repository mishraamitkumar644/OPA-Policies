# ============================================================
# run_opa_tests_vm.ps1
# Run all OPA policy tests for Virtual Machine
#
# Usage (from virtual-machine/terraform/ folder):
#   .\run_opa_tests_vm.ps1
# ============================================================

$OPA = "C:\Tools\OPA\opa.exe"
$PLAN_JSON = "tfplan.json"
$POLICY_DIR = "..\policy"

$tests = @(
  @{ id = "TC-01"; file = "tc01_approved_extensions"; query = "data.azure.vm.tc01_approved_extensions.deny" },
  @{ id = "TC-02"; file = "tc02_mfa_identity_access"; query = "data.azure.vm.tc02_mfa_identity_access.deny" }
)

$pass = 0
$fail = 0

Write-Host ""
Write-Host "============================================================" -ForegroundColor White
Write-Host " OPA Policy Tests — Azure Virtual Machine" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor White
Write-Host ""

foreach ($test in $tests) {
  Write-Host "---------- $($test.id): $($test.file) ----------" -ForegroundColor Yellow

  $result = & $OPA eval `
    --input $PLAN_JSON `
    --data "$POLICY_DIR\$($test.file).rego" `
    $test.query 2>&1 | ConvertFrom-Json

  $violations = $result.result[0].expressions[0].value

  if ($violations.Count -eq 0) {
    Write-Host "  PASS - No violations found" -ForegroundColor Green
    $pass++
  } else {
    foreach ($v in $violations) {
      Write-Host "  FAIL - $v" -ForegroundColor Red
    }
    $fail++
  }
  Write-Host ""
}

Write-Host "============================================================" -ForegroundColor White
Write-Host " RESULTS: Total=$($tests.Count)  PASS=$pass  FAIL=$fail" -ForegroundColor $(if ($fail -eq 0) { "Green" } else { "Red" })
Write-Host "============================================================" -ForegroundColor White
Write-Host ""
