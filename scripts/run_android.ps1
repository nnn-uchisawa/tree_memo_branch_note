param(
    [string]$JavaHome,
    [string]$Device,
    [switch]$BuildOnly
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $JavaHome) {
    $jdkRoot = Join-Path $projectRoot '.tooling/java17'
    $jdk = Get-ChildItem -LiteralPath $jdkRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'bin/java.exe') } |
        Select-Object -First 1
    if (-not $jdk) {
        throw 'Java 17 のパスを -JavaHome で指定してください。'
    }
    $JavaHome = $jdk.FullName
}
$resolvedJdk = (Resolve-Path -LiteralPath $JavaHome).Path
if (-not (Test-Path -LiteralPath (Join-Path $resolvedJdk 'bin/java.exe'))) {
    throw '指定された JavaHome に bin/java.exe がありません。'
}

$previousGradleOptions = $env:GRADLE_OPTS
Push-Location $projectRoot
try {
    # この実行だけ Gradle の JDK を指定し、Flutter のグローバル設定は変更しない。
    $env:GRADLE_OPTS = "$previousGradleOptions `"-Dorg.gradle.java.home=$resolvedJdk`""
    if ($BuildOnly) {
        & flutter build apk --debug --flavor local
    } elseif ($Device) {
        & flutter run --flavor local -d $Device
    } else {
        & flutter run --flavor local
    }
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter の実行が失敗しました (exit code: $LASTEXITCODE)。"
    }
} finally {
    $env:GRADLE_OPTS = $previousGradleOptions
    Pop-Location
}
