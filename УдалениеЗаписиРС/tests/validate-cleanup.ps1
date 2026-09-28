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
    '0KLQtdC60YPRidCw0Y/Qo9C90LjQstC10YDRgdCw0LvRjNC90LDRj9CU0LDRgtCwKCk=',
    '0JzQuNC90LjQvNCw0LvRjNC90YvQudCS0L7Qt9GA0LDRgdGC0JzQuNC90YPRgg=='
)

foreach ($fragmentBase64 in $requiredFragmentsBase64) {
    $fragment = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($fragmentBase64))
    if (-not $moduleText.Contains($fragment)) {
        throw "Required fragment is missing: $fragmentBase64"
    }
}

$recordSetRead = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCf0YDQvtGH0LjRgtCw0YLRjCgpOw=='))
$recordSetClear = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCe0YfQuNGB0YLQuNGC0YwoKTs='))
$recordSetWrite = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCX0LDQv9C40YHQsNGC0Ywo0JjRgdGC0LjQvdCwKTs='))
$readPosition = $moduleText.IndexOf($recordSetRead)
$clearPosition = $moduleText.IndexOf($recordSetClear)
$writePosition = $moduleText.IndexOf($recordSetWrite)
if ($readPosition -lt 0 -or $clearPosition -lt 0 -or $writePosition -lt 0 -or
    $readPosition -gt $clearPosition -or $clearPosition -gt $writePosition) {
    throw 'The selected record set must be read, cleared, and written with replacement in this order.'
}

$requiredDeleteFragmentsBase64 = @(
    '0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5ID0g0KDQtdCz0LjRgdGC0YDRi9Ch0LLQtdC00LXQvdC40Lku0JDQutGC0LjQstC90L7RgdGC0YzQodC10LDQvdGB0L7QstCf0L7Qu9GM0LfQvtCy0LDRgtC10LvQtdC5LtCh0L7Qt9C00LDRgtGM0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5KCk7',
    '0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCe0YLQsdC+0YAu0J7RgNCz0LDQvdC40LfQsNGG0LjRjy7Qo9GB0YLQsNC90L7QstC40YLRjCjQntGA0LPQsNC90LjQt9Cw0YbQuNGPKTs=',
    '0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCf0YDQvtGH0LjRgtCw0YLRjCgpOw==',
    '0JTQu9GPINCa0LDQttC00L7Qs9C+INCX0LDQv9C40YHRjNCQ0LrRgtC40LLQvdC+0YHRgtC4INCY0Lcg0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5INCm0LjQutC7',
    '0JXRgdC70Lgg0JfQsNC/0LjRgdGM0JDQutGC0LjQstC90L7RgdGC0Lgu0JTQsNGC0LDQn9C+0YHQu9C10LTQvdC10LnQkNC60YLQuNCy0L3QvtGB0YLQuNCj0L3QuNCy0LXRgNGB0LDQu9GM0L3QsNGPID49INCT0YDQsNC90LjRhtCw0JDQutGC0LjQstC90L7RgdGC0Lgg0KLQvtCz0LTQsA==',
    '0JrQvtC70LjRh9C10YHRgtCy0L7Qo9C00LDQu9GP0LXQvNGL0YXQl9Cw0L/QuNGB0LXQuSA9INCd0LDQsdC+0YDQl9Cw0L/QuNGB0LXQuS7QmtC+0LvQuNGH0LXRgdGC0LLQvigpOw==',
    '0J3QsNCx0L7RgNCX0LDQv9C40YHQtdC5LtCe0YfQuNGB0YLQuNGC0YwoKTs=',
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

$standardCleanup = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('0KDQtdCz0LjRgdGC0YDRi9Ch0LLQtdC00LXQvdC40Lku0JDQutGC0LjQstC90L7RgdGC0YzQodC10LDQvdGB0L7QstCf0L7Qu9GM0LfQvtCy0LDRgtC10LvQtdC5LtCj0LTQsNC70LjRgtGM0JDQutGC0LjQstC90L7RgdGC0YzQn9C+0LvRjNC30L7QstCw0YLQtdC70LXQudCf0L7QntGA0LPQsNC90LjQt9Cw0YbQuNC4KNCe0YDQs9Cw0L3QuNC30LDRhtC40Y8pOw=='))
if ($moduleText.Contains($standardCleanup)) {
    throw 'The standard cleanup writes a newly created empty set and did not remove records in Shokolad.'
}

Write-Output 'OK: cleanup safety invariants are present.'
