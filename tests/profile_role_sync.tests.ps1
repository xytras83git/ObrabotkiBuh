$ErrorActionPreference = 'Stop'

$repositoryPath = Resolve-Path (Join-Path $PSScriptRoot '..')
$processorPath = Get-ChildItem -LiteralPath $repositoryPath -Directory | Where-Object {
    Test-Path -LiteralPath (Join-Path $_.FullName ($_.Name + '.xml'))
} | Select-Object -First 1
$modulePath = Join-Path $processorPath.FullName ($processorPath.Name + '\Ext\ObjectModule.bsl')
$moduleText = Get-Content -LiteralPath $modulePath -Raw -Encoding UTF8

function Decode-Utf8([string]$Value) {
    return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Value))
}

function Assert-Contains([string]$Text, [string]$Value, [string]$Message) {
    if (-not $Text.Contains($Value)) {
        throw $Message
    }
}

function Assert-NotContains([string]$Text, [string]$Value, [string]$Message) {
    if ($Text.Contains($Value)) {
        throw $Message
    }
}

$methodStart = Decode-Utf8 '0KTRg9C90LrRhtC40Y8g0KHQutC+0L/QuNGA0L7QstCw0YLRjNCf0YDQvtGE0LjQu9GM0JLQkdCw0LfRiyjQodGC0YDRg9C60YLRg9GA0LDQn9Cw0YDQsNC80LXRgtGA0L7Qsik='
$methodEnd = Decode-Utf8 '0JrQvtC90LXRhtCk0YPQvdC60YbQuNC4'
$startPosition = $moduleText.IndexOf($methodStart)
$endPosition = $moduleText.IndexOf($methodEnd, $startPosition)
if ($startPosition -lt 0 -or $endPosition -lt 0) {
    throw 'Copy profile method was not found.'
}

$methodBody = $moduleText.Substring($startPosition, $endPosition - $startPosition)
$profileAlreadyExists = Decode-Utf8 '0J/RgNC+0YTQuNC70Ywg0YPQttC1INGB0L7Qt9C00LDQvQ=='
$roleIsFilled = Decode-Utf8 '0JfQvdCw0YfQtdC90LjQtdCX0LDQv9C+0LvQvdC10L3QvijQodGB0YvQu9C60LDQoNC+0LvQuCk='
$roleNotFound = Decode-Utf8 '0KDQvtC70Ywg0L3QtSDQvdCw0LnQtNC10L3QsCDQsiDQsdCw0LfQtQ=='
$getObject = Decode-Utf8 '0KHQv9GA0LDQstC+0YfQvdC40LrQn9GA0L7RhNC40LvRjC7Qn9C+0LvRg9GH0LjRgtGM0J7QsdGK0LXQutGCKCk='
$clearRoles = Decode-Utf8 '0KHQv9GA0LDQstC+0YfQvdC40LrQn9GA0L7RhNC40LvRjC7QoNC+0LvQuC7QntGH0LjRgdGC0LjRgtGMKCk='

Assert-NotContains $methodBody $profileAlreadyExists `
    'An existing profile must be synchronized instead of rejected.'
Assert-Contains $methodBody $roleIsFilled `
    'All incoming roles must be validated before the profile is changed.'
Assert-Contains $methodBody $roleNotFound `
    'A missing role must produce a clear error message.'
Assert-Contains $methodBody $getObject `
    'An existing profile must be opened for synchronization.'
Assert-Contains $methodBody $clearRoles `
    'Old roles must be cleared before writing the exact source role set.'

$resolvePosition = $methodBody.IndexOf($roleIsFilled)
$clearPosition = $methodBody.IndexOf($clearRoles)
if ($resolvePosition -lt 0 -or $clearPosition -lt 0 -or $resolvePosition -gt $clearPosition) {
    throw 'All roles must be resolved before existing roles are cleared.'
}

Write-Output 'profile_role_sync.tests.ps1: PASS'
