$ErrorActionPreference = 'Stop'

$modulePath = Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot '..') -Filter 'Module.bsl' -Recurse |
    Where-Object { $_.FullName -like '*\Forms\*\Ext\Form\Module.bsl' } |
    Select-Object -First 1 -ExpandProperty FullName
if (-not $modulePath) {
    throw 'Form module was not found.'
}
$moduleText = Get-Content -LiteralPath $modulePath -Raw -Encoding UTF8

$requiredFragmentsBase64 = @(
    '0J/RgNC+0YbQtdC00YPRgNCwINCf0YDQvtCy0LXRgNC40YLRjNCX0LDQv9C40YHRjA==',
    '0J/RgNC+0YbQtdC00YPRgNCwINCj0LTQsNC70LjRgtGM0JfQsNC/0LjRgdGM',
    '0KTRg9C90LrRhtC40Y8g0J/QvtC70YPRh9C40YLRjNCU0LDQvdC90YvQtdCX0LDQv9C40YHQuNCd0LDQodC10YDQstC10YDQtQ==',
    '0KTRg9C90LrRhtC40Y8g0KPQtNCw0LvQuNGC0YzQl9Cw0L/QuNGB0YzQndCw0KHQtdGA0LLQtdGA0LU=',
    '0JzQtdC90LXQtNC20LXRgNCX0LDQv9C40YHQuC7Qn9GA0L7Rh9C40YLQsNGC0YwoKQ==',
    '0JzQtdC90LXQtNC20LXRgNCX0LDQv9C40YHQuC7Qo9C00LDQu9C40YLRjCgp',
    '0KLQtdC60YPRidCw0Y/Qo9C90LjQstC10YDRgdCw0LvRjNC90LDRj9CU0LDRgtCwKCk=',
    '0JzQuNC90LjQvNCw0LvRjNC90YvQudCS0L7Qt9GA0LDRgdGC0JzQuNC90YPRgg=='
)

foreach ($fragmentBase64 in $requiredFragmentsBase64) {
    $fragment = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($fragmentBase64))
    if (-not $moduleText.Contains($fragment)) {
        throw "Required fragment is missing: $fragmentBase64"
    }
}

$readFragment = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('0JzQtdC90LXQtNC20LXRgNCX0LDQv9C40YHQuC7Qn9GA0L7Rh9C40YLQsNGC0YwoKQ=='))
$deleteFragment = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('0JzQtdC90LXQtNC20LXRgNCX0LDQv9C40YHQuC7Qo9C00LDQu9C40YLRjCgp'))
$readPosition = $moduleText.IndexOf($readFragment)
$deletePosition = $moduleText.IndexOf($deleteFragment)
if ($readPosition -lt 0 -or $deletePosition -lt 0 -or $readPosition -gt $deletePosition) {
    throw 'Delete must happen only after reading the record by key.'
}

Write-Output 'OK: cleanup safety invariants are present.'
