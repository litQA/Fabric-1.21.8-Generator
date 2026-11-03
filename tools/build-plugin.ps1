# Packages the generator plugin archive consumed by MCreator.
# The archive root contains plugin.json and LICENSE, followed by the fabric-1.21.8 generator and its
# private fabric-1.21.8-base/{datapack,neoforge} layers. Base layers intentionally do not contain a
# generator.yaml, so MCreator does not list them as separate generators, and their namespaced paths
# cannot collide with other 1.21.8 generator plugins.

$ErrorActionPreference = 'Stop'

$pluginRoot = Split-Path -Parent $PSScriptRoot
$resources = Join-Path $pluginRoot 'src/main/resources'
$buildDir = Join-Path $pluginRoot 'build'
$stageDir = Join-Path $buildDir 'plugin-stage'
$distDir = Join-Path $buildDir 'dist'

$archiveName = "generator-fabric-1.21.8.zip"

if (Test-Path $stageDir) { Remove-Item $stageDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $stageDir, $distDir | Out-Null

Copy-Item (Join-Path $pluginRoot 'plugin.json') $stageDir
Copy-Item (Join-Path $pluginRoot 'LICENSE') $stageDir
foreach ($generator in @('fabric-1.21.8', 'fabric-1.21.8-base')) {
    Copy-Item (Join-Path $resources $generator) (Join-Path $stageDir $generator) -Recurse
}
# The base layers are imported by path and must not be registered as standalone generators.
Remove-Item (Join-Path $stageDir 'fabric-1.21.8-base/generator.yaml') -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $stageDir 'fabric-1.21.8-base/datapack/generator.yaml') -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $stageDir 'fabric-1.21.8-base/neoforge/generator.yaml') -Force -ErrorAction SilentlyContinue

$archive = Join-Path $distDir $archiveName
if (Test-Path $archive) { Remove-Item $archive -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($stageDir, $archive, [System.IO.Compression.CompressionLevel]::Optimal, $false)
Remove-Item $stageDir -Recurse -Force

$size = (Get-Item $archive).Length
Write-Host ("Packaged {0} ({1:N0} KB)" -f $archive, ($size / 1KB))
