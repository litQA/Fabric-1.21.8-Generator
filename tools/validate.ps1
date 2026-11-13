# Compiles and runs the static generator validator against the shipped resources.
# Requires the MCreator EAP installation (for the JDK and the Freemarker / SnakeYAML libraries).
param(
    [string]$MCreatorPath = $env:MCREATOR_PATH
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($MCreatorPath)) {
    throw 'MCreator installation path is required. Pass -MCreatorPath or set MCREATOR_PATH.'
}

$pluginRoot = Split-Path -Parent $PSScriptRoot
$javac = Join-Path $MCreatorPath 'jdk/bin/javac.exe'
$java = Join-Path $MCreatorPath 'jdk/bin/java.exe'
$lib = Join-Path $MCreatorPath 'lib'
if (-not (Test-Path $javac)) { throw "MCreator JDK not found at $MCreatorPath" }

$classpath = @(
    (Join-Path $lib 'freemarker-2.3.35.jar'),
    (Join-Path $lib 'snakeyaml-engine-3.2.jar')
) -join ';'

$outDir = Join-Path $pluginRoot 'build/validator'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

& $javac -encoding UTF-8 -cp $classpath -d $outDir (Join-Path $PSScriptRoot 'GeneratorValidator.java')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& $java -cp "$outDir;$classpath" GeneratorValidator (Join-Path $pluginRoot 'src/main/resources')
exit $LASTEXITCODE
