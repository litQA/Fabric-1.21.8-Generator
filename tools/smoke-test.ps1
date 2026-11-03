# Offline smoke test: loads the packaged plugin through the real MCreator 2026.3 classes, creates a
# workspace, renders every base template and generates a block, item and procedure. Gradle is not used.
#
# Usage: pwsh plugin/tools/smoke-test.ps1 [-MCreatorPath <path>] [-PluginZip <path>]
param(
    [string]$MCreatorPath = 'B:\QA\Documents\App\Mods\DSH\Fabric_Generator_1.21.8\MCreatorEAP2026344621',
    [string]$PluginZip = ''
)

$ErrorActionPreference = 'Stop'

$pluginRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent $pluginRoot
$buildDir = Join-Path $pluginRoot 'build/smoke'

if (-not (Test-Path (Join-Path $MCreatorPath 'mcreator.exe'))) { throw "MCreator not found at $MCreatorPath" }
if ([string]::IsNullOrWhiteSpace($PluginZip)) {
    $PluginZip = Get-ChildItem (Join-Path $pluginRoot 'build/dist') -Filter 'generator-fabric-1.21.8-*.zip' |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $PluginZip -or -not (Test-Path $PluginZip)) { throw 'Plugin archive not found. Run build-plugin.ps1 first.' }

$coreDir = Join-Path $buildDir 'core'
$classesDir = Join-Path $buildDir 'classes'
$homeDir = Join-Path $buildDir 'home'
$pluginsDir = Join-Path $buildDir 'plugins'
$workspaceDir = Join-Path $buildDir 'workspace'
foreach ($dir in @($coreDir, $classesDir, $homeDir, $pluginsDir, $workspaceDir)) {
    if (Test-Path $dir) { Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue; if (Test-Path $dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null } }
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

Push-Location $coreDir
try {
    & (Join-Path $MCreatorPath 'jdk/bin/jar.exe') xf (Join-Path $MCreatorPath 'mcreator.exe')
} finally {
    Pop-Location
}

Copy-Item $PluginZip (Join-Path $pluginsDir (Split-Path $PluginZip -Leaf))
$lib = Join-Path $MCreatorPath 'lib'
$classpath = "$coreDir;$lib\*"
$javac = Join-Path $MCreatorPath 'jdk/bin/javac.exe'
$java = Join-Path $MCreatorPath 'jdk/bin/java.exe'

& $javac -encoding UTF-8 -cp $classpath -d $classesDir (Join-Path $PSScriptRoot 'SmokeTest.java')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$env:MCREATOR_HOME = $homeDir
$env:MCREATOR_PLUGINS_FOLDER = $pluginsDir
$env:TEMP = $homeDir
$env:TMP = $homeDir
$opens = @(
    '--add-opens=java.base/java.lang=ALL-UNNAMED',
    '--add-opens=java.base/java.util=ALL-UNNAMED',
    '--add-opens=java.base/java.lang.reflect=ALL-UNNAMED',
    '--add-opens=java.base/java.io=ALL-UNNAMED',
    '--add-opens=java.base/java.nio=ALL-UNNAMED',
    '--add-opens=java.desktop/java.awt=ALL-UNNAMED',
    '--add-opens=java.desktop/sun.awt=ALL-UNNAMED',
    '--add-opens=java.desktop/java.awt.image=ALL-UNNAMED',
    '--add-opens=java.desktop/javax.swing=ALL-UNNAMED'
)
$runArgs = @(
    "-Djava.awt.headless=true",
    "-Dlog_directory=$homeDir",
    "-Dsmoke.out=$workspaceDir",
    "-Dsmoke.fixtures=$repoRoot\workspace\test-min\elements"
) + $opens + @(
    '-cp', "$classesDir;$coreDir;$lib\*",
    'SmokeTest'
)

Push-Location $MCreatorPath
try {
    & $java @runArgs
    $exit = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $exit

