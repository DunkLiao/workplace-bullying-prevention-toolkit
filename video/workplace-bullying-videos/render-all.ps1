param(
  [ValidateSet("draft", "standard", "high")]
  [string]$Quality = "standard",

  [string]$Workers = "1",

  [string]$OutputDir = "output",

  [int]$Limit = 0,

  [switch]$NoPause
)

$ErrorActionPreference = "Stop"

$videos = @(
  @{ File = "01_what_is_bullying.html";        Name = "01-what-is-bullying" },
  @{ File = "02_bullying_types.html";          Name = "02-bullying-types" },
  @{ File = "03_reasonable_management.html";   Name = "03-reasonable-management" },
  @{ File = "04_how_to_complain.html";         Name = "04-how-to-complain" },
  @{ File = "05_employer_obligations.html";    Name = "05-employer-obligations" },
  @{ File = "06_investigation_process.html";   Name = "06-investigation-process" },
  @{ File = "07_legal_deadlines.html";         Name = "07-legal-deadlines" },
  @{ File = "08_no_adverse_treatment.html";    Name = "08-no-adverse-treatment" },
  @{ File = "09_top_executive_complaint.html"; Name = "09-top-executive-complaint" },
  @{ File = "10_friendly_workplace.html";      Name = "10-friendly-workplace" }
)

if ($Limit -gt 0 -and $Limit -lt $videos.Count) {
  $videos = @($videos[0..($Limit - 1)])
}

$projectDir = $PSScriptRoot
$outputPath = Join-Path $projectDir $OutputDir
New-Item -ItemType Directory -Force -Path $outputPath | Out-Null

$total = $videos.Count
$success = 0
$failed = 0
$failedItems = @()

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Workplace bullying videos - batch render ($total videos)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Project: $projectDir"
Write-Host "Output:  $outputPath"
Write-Host "Quality: $Quality"
Write-Host "Workers: $Workers"
Write-Host ""

Push-Location $projectDir
try {
  for ($i = 0; $i -lt $total; $i++) {
    $num = $i + 1
    $video = $videos[$i]
    $compositionPath = Join-Path "compositions" $video.File
    $targetPath = Join-Path $outputPath ($video.Name + ".mp4")

    Write-Host "[$num/$total] $($video.Name)" -ForegroundColor Yellow
    Write-Host "  Source: $compositionPath"
    Write-Host "  Output: $targetPath"

    if (-not (Test-Path $compositionPath)) {
      Write-Host "  [FAIL] Composition file not found." -ForegroundColor Red
      $failed++
      $failedItems += $video.Name
      Write-Host ""
      continue
    }

    $startTime = Get-Date
    & npx --yes hyperframes@0.7.22 render `
      --composition $compositionPath `
      --quality $Quality `
      --workers $Workers `
      --output $targetPath

    $exitCode = $LASTEXITCODE
    $elapsed = [Math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)

    if ($exitCode -eq 0 -and (Test-Path $targetPath) -and ((Get-Item $targetPath).Length -gt 0)) {
      Write-Host "  [OK] Rendered in $elapsed seconds." -ForegroundColor Green
      $success++
    } else {
      Write-Host "  [FAIL] Render failed. Exit code: $exitCode" -ForegroundColor Red
      $failed++
      $failedItems += $video.Name
    }

    Write-Host ""
  }
}
finally {
  Pop-Location
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Batch render finished: OK $success / FAIL $failed / TOTAL $total" -ForegroundColor Cyan
Write-Host "  Output folder: $outputPath" -ForegroundColor Cyan
if ($failedItems.Count -gt 0) {
  Write-Host "  Failed items:" -ForegroundColor Red
  foreach ($item in $failedItems) {
    Write-Host "  - $item" -ForegroundColor Red
  }
}
Write-Host "============================================" -ForegroundColor Cyan

if (-not $NoPause) {
  Read-Host "Press Enter to exit"
}
