param(
    [string]$ExpectedVersion = "v1.0.0"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $Root

$Failed = $false

function Pass([string]$Message) {
    Write-Host "[PASS] $Message" -ForegroundColor Green
}

function Fail([string]$Message) {
    Write-Host "[FAIL] $Message" -ForegroundColor Red
    $script:Failed = $true
}

Write-Host ""
Write-Host "===== PHASE 0 VALIDATION =====" -ForegroundColor Cyan
Write-Host "Root: $Root"

$RequiredFiles = @(
    "CONTRACT_VERSION",
    ".env.example",
    "docs\phase0\PHASE_0_CONTRACT_FREEZE.md",
    "contracts\openapi\order-service.v1.yaml",
    "contracts\openapi\inventory-service.v1.yaml",
    "contracts\fixtures\inventory-adjustment.request.json",
    "contracts\fixtures\inventory-adjustment.applied.response.json",
    "contracts\fixtures\inventory-adjustment.duplicate.response.json",
    "contracts\fixtures\inventory-adjustment.insufficient-stock.response.json",
    "docs\member-1\MEMBER_1_ORDER_EXECUTION.md",
    "docs\member-2\MEMBER_2_INVENTORY_EXECUTION.md",
    "docs\integration\INTEGRATION_EXECUTION.md",
    "docs\integration\FINAL_ACCEPTANCE_CHECKLIST.md",
    ".github\pull_request_template.md"
)

foreach ($File in $RequiredFiles) {
    if (Test-Path $File) {
        Pass $File
    }
    else {
        Fail "Missing $File"
    }
}

if (Test-Path "CONTRACT_VERSION") {
    $Version = (Get-Content "CONTRACT_VERSION" -Raw).Trim()
    if ($Version -eq $ExpectedVersion) {
        Pass "Contract version = $ExpectedVersion"
    }
    else {
        Fail "Contract version '$Version' != '$ExpectedVersion'"
    }
}

$FixtureFiles = Get-ChildItem ".\contracts\fixtures\*.json" -ErrorAction SilentlyContinue
foreach ($File in $FixtureFiles) {
    try {
        Get-Content $File.FullName -Raw | ConvertFrom-Json | Out-Null
        Pass "Valid JSON: $($File.Name)"
    }
    catch {
        Fail "Invalid JSON: $($File.Name)"
    }
}

$Phase0 = Get-Content ".\docs\phase0\PHASE_0_CONTRACT_FREEZE.md" -Raw
$RequiredTerms = @(
    "READY_TO_SHIP",
    "INVENTORY_PENDING",
    "INVENTORY_UNCERTAIN",
    "SHIPPED",
    "FAILED",
    "APPLIED",
    "ALREADY_APPLIED",
    "operationId",
    "2000 ms",
    "5000 ms",
    "crash_after_commit",
    "rolling average Order response time over the previous 30 seconds",
    "ONE LOGICAL INVENTORY OPERATION = ONE BUSINESS EFFECT"
)

foreach ($Term in $RequiredTerms) {
    if ($Phase0 -match [regex]::Escape($Term)) {
        Pass "Frozen term: $Term"
    }
    else {
        Fail "Missing frozen term: $Term"
    }
}

$OrderSpec = Get-Content ".\contracts\openapi\order-service.v1.yaml" -Raw
$OrderTerms = @(
    "/api/v1/orders",
    "/api/v1/orders/{orderId}/ship",
    "/health",
    "/metrics",
    "INVENTORY_UNCERTAIN",
    "ALREADY_APPLIED",
    "X-Correlation-Id",
    "X-Test-Fault-Mode"
)

foreach ($Term in $OrderTerms) {
    if ($OrderSpec -match [regex]::Escape($Term)) {
        Pass "Order OpenAPI: $Term"
    }
    else {
        Fail "Order OpenAPI missing: $Term"
    }
}

$InventorySpec = Get-Content ".\contracts\openapi\inventory-service.v1.yaml" -Raw
$InventoryTerms = @(
    "/api/v1/inventory/adjustments",
    "/api/v1/inventory/{productId}",
    "/health",
    "/metrics",
    "APPLIED",
    "ALREADY_APPLIED",
    "operationId",
    "crash_after_commit"
)

foreach ($Term in $InventoryTerms) {
    if ($InventorySpec -match [regex]::Escape($Term)) {
        Pass "Inventory OpenAPI: $Term"
    }
    else {
        Fail "Inventory OpenAPI missing: $Term"
    }
}

$Env = Get-Content ".\.env.example" -Raw
$EnvTerms = @(
    "ORDER_SERVICE_PORT=3001",
    "INVENTORY_SERVICE_PORT=3002",
    "FRONTEND_PORT=5173",
    "ORDER_DB_HOST_PORT=5433",
    "INVENTORY_DB_HOST_PORT=5434",
    "INVENTORY_HTTP_TIMEOUT_MS=2000",
    "INVENTORY_LATENCY_MS=5000",
    "PROMETHEUS_PORT=9090",
    "GRAFANA_PORT=3000"
)

foreach ($Term in $EnvTerms) {
    if ($Env -match [regex]::Escape($Term)) {
        Pass "Environment: $Term"
    }
    else {
        Fail "Environment missing: $Term"
    }
}

git diff --check
if ($LASTEXITCODE -eq 0) {
    Pass "git diff --check"
}
else {
    Fail "git diff --check"
}

if ($Failed) {
    Write-Host ""
    Write-Host "PHASE 0 VALIDATION FAILED" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "PHASE 0 VALIDATION PASSED" -ForegroundColor Green
exit 0
