$ErrorActionPreference = 'Stop'

$repositoryPath = Resolve-Path (Join-Path $PSScriptRoot '..')
$sourceRoot = Get-ChildItem -LiteralPath $repositoryPath -Directory | Where-Object {
    $_.Name -ne 'tests' -and $_.Name -ne '.git'
} | Select-Object -First 1
$modulePath = (Get-ChildItem -LiteralPath $sourceRoot.FullName -Recurse -Filter 'ObjectModule.bsl' -File |
    Select-Object -First 1).FullName
$moduleText = Get-Content -LiteralPath $modulePath -Raw -Encoding UTF8

function Decode-Utf8([string]$Value) {
    return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Value))
}

$fullNameBranch = Decode-Utf8 '0JXRgdC70Lgg0JjQvNGP0KHQstC+0LnRgdGC0LLQsC7QmtC70Y7RhyA9ICLQn9C+0LvQvdC+0LXQmNC80Y8iINCi0L7Qs9C00LA='
$unlimitedStringType = Decode-Utf8 '0KLQuNC/0JrQvtC70L7QvdC60LggPSDQndC+0LLRi9C5INCe0L/QuNGB0LDQvdC40LXQotC40L/QvtCyKCLQodGC0YDQvtC60LAiKTs='
$elseIf = Decode-Utf8 '0JjQvdCw0YfQtdCV0YHQu9C4'

$branchStart = $moduleText.IndexOf($fullNameBranch)
if ($branchStart -lt 0) {
    throw 'FullName must have a dedicated unlimited string branch.'
}

$branchEnd = $moduleText.IndexOf($elseIf, $branchStart)
if ($branchEnd -lt 0) {
    throw 'FullName branch end was not found.'
}

$branchText = $moduleText.Substring($branchStart, $branchEnd - $branchStart)
if (-not $branchText.Contains($unlimitedStringType)) {
    throw 'FullName must use an unlimited string type.'
}
Write-Output 'role_full_name_length.tests.ps1: PASS'
