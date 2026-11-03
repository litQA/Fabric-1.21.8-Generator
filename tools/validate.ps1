# Compiles and runs the static generator validator against the shipped resources.
# Requires the MCreator EAP installation (for the JDK and the Freemarker / SnakeYAML libraries).
param(
    [string]$MCreatorPath = 'B:\QA\Documents\App\Mods\DSH\Fabric_Generator_1.21.8\MCreatorEAP2026344621'
)

$ErrorActionPreference = 'Stop'

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
