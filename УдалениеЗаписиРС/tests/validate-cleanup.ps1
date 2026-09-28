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
    '0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCX0LDQv9C40YHQsNGC0Ywo0JjRgdGC0LjQvdCwKTs=',
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
$deleteFragment = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCX0LDQv9C40YHQsNGC0Ywo0JjRgdGC0LjQvdCwKTs='))
$readPosition = $moduleText.IndexOf($readFragment)
$deletePosition = $moduleText.IndexOf($deleteFragment)
if ($readPosition -lt 0 -or $deletePosition -lt 0 -or $readPosition -gt $deletePosition) {
    throw 'Delete must happen only after reading the record by key.'
}

$requiredDeleteFragmentsBase64 = @(
    '0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5ID0g0KDQtdCz0LjRgdGC0YDRi9Ch0LLQtdC00LXQvdC40Lku0JDQutGC0LjQstC90L7RgdGC0YzQodC10LDQvdGB0L7QstCf0L7Qu9GM0LfQvtCy0LDRgtC10LvQtdC5LtCh0L7Qt9C00LDRgtGM0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5KCk7',
    '0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCe0YLQsdC+0YAu0J7RgNCz0LDQvdC40LfQsNGG0LjRjy7Qo9GB0YLQsNC90L7QstC40YLRjCjQntGA0LPQsNC90LjQt9Cw0YbQuNGPKTs=',
    '0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCe0YLQsdC+0YAu0J/QvtC70YzQt9C+0LLQsNGC0LXQu9GMLtCj0YHRgtCw0L3QvtCy0LjRgtGMKNCf0L7Qu9GM0LfQvtCy0LDRgtC10LvRjCk7',
    '0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCe0LHQvNC10L3QlNCw0L3QvdGL0LzQuC7Ql9Cw0LPRgNGD0LfQutCwID0g0JjRgdGC0LjQvdCwOw==',
    '0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCX0LDQv9C40YHQsNGC0Ywo0JjRgdGC0LjQvdCwKTs='
)

foreach ($fragmentBase64 in $requiredDeleteFragmentsBase64) {
    $fragment = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($fragmentBase64))
    if (-not $moduleText.Contains($fragment)) {
        throw "Required safe-delete fragment is missing: $fragmentBase64"
    }
}

$recordManagerDelete = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('0JzQtdC90LXQtNC20LXRgNCX0LDQv9C40YHQuC7Qo9C00LDQu9C40YLRjCgpOw=='))
if ($moduleText.Contains($recordManagerDelete)) {
    throw 'Record manager deletion must not be used because register handlers can restore the record.'
}

Write-Output 'OK: cleanup safety invariants are present.'
