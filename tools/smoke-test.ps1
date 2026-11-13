# Offline smoke test: loads the packaged plugin through the real MCreator 2026.3 classes, creates a
# workspace, renders every base template and generates a block, item and procedure. Gradle is not used.
#
# Usage: pwsh plugin/tools/smoke-test.ps1 -MCreatorPath <path> [-PluginZip <path>]
param(
    [string]$MCreatorPath = $env:MCREATOR_PATH,
    [string]$PluginZip = ''
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($MCreatorPath)) {
    throw 'MCreator installation path is required. Pass -MCreatorPath or set MCREATOR_PATH.'
}

$pluginRoot = Split-Path -Parent $PSScriptRoot
$buildDir = Join-Path $pluginRoot 'build/smoke'

if (-not (Test-Path (Join-Path $MCreatorPath 'mcreator.exe'))) { throw "MCreator not found at $MCreatorPath" }
if ([string]::IsNullOrWhiteSpace($PluginZip)) {
    $PluginZip = Join-Path $pluginRoot 'build/dist/generator-fabric-1.21.8.zip'
}
if (-not $PluginZip -or -not (Test-Path $PluginZip)) { throw 'Plugin archive not found. Run build-plugin.ps1 first.' }

$coreDir = Join-Path $buildDir 'core'
$classesDir = Join-Path $buildDir 'classes'
$homeDir = Join-Path $buildDir 'home'
$testRoot = Join-Path $buildDir 'run'
$installedPluginsDir = Join-Path $testRoot 'plugins'
$pluginsDir = Join-Path $buildDir 'plugins'
$workspaceDir = Join-Path $buildDir 'workspace'
foreach ($dir in @($coreDir, $classesDir, $homeDir, $testRoot, $pluginsDir, $workspaceDir)) {
    if (Test-Path $dir) { Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue; if (Test-Path $dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null } }
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
New-Item -ItemType Directory -Force -Path $installedPluginsDir | Out-Null

Push-Location $coreDir
try {
    & (Join-Path $MCreatorPath 'jdk/bin/jar.exe') xf (Join-Path $MCreatorPath 'mcreator.exe')
} finally {
    Pop-Location
}

# Run from an isolated root. MCreator always treats .\plugins as a trusted plugin
# directory, so this copy contains the installation's core/system plugins and all
# other generators, but not the installed copy of our plugin. The built archive is
# loaded from a separate directory, guaranteeing that the ZIP under test is the
# generator that resolves the Fabric 1.21.8 id.
$installedPlugins = Join-Path $MCreatorPath 'plugins'
Get-ChildItem $installedPlugins -Filter '*.zip' | Where-Object {
    $_.Name -notmatch '^generator-fabric-1\.21\.8(?:-|\.zip$)'
} | Copy-Item -Destination $installedPluginsDir
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
    "-Dsmoke.fixtures=$pluginRoot\tools\fixtures\test-min\elements"
) + $opens + @(
    '-cp', "$classesDir;$coreDir;$lib\*",
    'SmokeTest'
)

Push-Location $testRoot
try {
    & $java @runArgs
    $exit = $LASTEXITCODE
} finally {
    Pop-Location
}
exit $exit

