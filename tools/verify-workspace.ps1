# Runs the Gradle build of a generated Fabric 1.21.8 workspace with all caches redirected to the
# repository's caches directory, as required by the project delivery rules.
#
# Usage: pwsh plugin/tools/verify-workspace.ps1 -Workspace "B:\path\to\workspace" [-Tasks build]
param(
    [Parameter(Mandatory = $true)][string]$Workspace,
    [string[]]$Tasks = @('build')
)

$ErrorActionPreference = 'Stop'

$pluginRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent $pluginRoot
$gradleHome = Join-Path $repoRoot 'caches/gradle'
$gradlew = Join-Path $Workspace 'gradlew.bat'

if (-not (Test-Path $gradlew)) { throw "gradlew.bat not found in $Workspace" }
if (-not (Test-Path $gradleHome)) { New-Item -ItemType Directory -Force -Path $gradleHome | Out-Null }

$env:GRADLE_USER_HOME = $gradleHome
Push-Location $Workspace
try {
    & $gradlew '--no-daemon' @Tasks
    exit $LASTEXITCODE
} finally {
    Pop-Location
}
