$ErrorActionPreference = 'Stop'

$testRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$projectRoot = Split-Path -Parent $testRoot
$objectModule = Join-Path $projectRoot 'ЗагрузкаДанныхИзТакси\Ext\ObjectModule.bsl'
$objectText = Get-Content -Raw -Encoding UTF8 -LiteralPath $objectModule

function Assert-Matches {
    param([string]$Text, [string]$Pattern, [string]$Message)
    if ($Text -notmatch $Pattern) { throw $Message }
}

function Assert-NotMatches {
    param([string]$Text, [string]$Pattern, [string]$Message)
    if ($Text -match $Pattern) { throw $Message }
}

Assert-Matches $objectText `
    'Функция ПолучитьСписокАктуальныхСотрудников\(СтруктураПараметров\)' `
    'В обработке нет метода получения актуальных сотрудников ЗУП.'
Assert-Matches $objectText `
    'ЗначениеДатаСреза\s*=\s*Неопределено;\s*Если СтруктураПараметров\.Свойство\(ИмяПараметраДатаСреза, ЗначениеДатаСреза\)' `
    'Выходной параметр ЗначениеДатаСреза используется до определения.'
Assert-Matches $objectText `
    'РегистрСведений\.КадроваяИсторияСотрудников\.СрезПоследних\([\s\S]{0,100}&ДатаСреза,[\s\S]{0,100}Активность\s*=\s*ИСТИНА\)' `
    'Актуальные кадровые данные должны получаться срезом последних на дату.'
Assert-Matches $objectText `
    'ПОМЕСТИТЬ ВТ_КадроваяИстория' `
    'Срез кадровой истории должен быть материализован до соединения со справочниками.'
Assert-Matches $objectText `
    'ВидыКадровыхСобытий\.Увольнение' `
    'Из списка сотрудников не исключены уволенные.'
Assert-Matches $objectText `
    'Некорректное значение параметра ДатаСреза' `
    'Некорректная дата среза должна возвращать прикладную ошибку.'
$employeeMethod = [regex]::Match(
    $objectText,
    '(?s)Функция ПолучитьСписокАктуальныхСотрудников\(СтруктураПараметров\).*?КонецФункции')
if (-not $employeeMethod.Success) {
    throw 'Не найдено тело метода получения сотрудников.'
}
if ($employeeMethod.Value -match 'ДатаИзСтроки') {
    throw 'Метод не должен подменять некорректную дату значением 01.01.2000.'
}
Assert-Matches $objectText `
    'Результат\.Вставить\("ТаблицаСотрудников"' `
    'Ответ не содержит таблицу сотрудников.'
Assert-Matches $objectText `
    'СтруктураПараметров\.Операция\s*=\s*"РаботаССотрудниками"' `
    'Операция работы с сотрудниками не подключена к диспетчеру запросов.'
Assert-Matches $objectText `
    'СтруктураПараметров\.ТипЗапроса\s*=\s*"ПолучитьСписокАктуальныхСотрудников"' `
    'Запрос списка сотрудников не подключен к диспетчеру запросов.'
Assert-NotMatches $objectText `
    '(?<![А-Яа-яA-Za-z0-9_])УчетНДСКлиентСервер\s*\.' `
    'Статическая ссылка на отсутствующий в ЗУП модуль УчетНДСКлиентСервер ломает создание обработки.'
Assert-NotMatches $objectText `
    '(?<![А-Яа-яA-Za-z0-9_])УчетНДСВызовСервераПовтИсп\s*\.' `
    'Статическая ссылка на бухгалтерский модуль УчетНДСВызовСервераПовтИсп нарушает переносимость обработки.'
Assert-NotMatches $objectText `
    '(?m)^(?!\s*//).*?(?<![А-Яа-яA-Za-z0-9_])УчетнаяПолитика\s*\.' `
    'Статическая ссылка на отсутствующий в ЗУП модуль УчетнаяПолитика ломает создание обработки.'
Assert-NotMatches $objectText `
    '(?<![А-Яа-яA-Za-z0-9_])ОбработкаОшибок\s*\.' `
    'Статическая ссылка на отсутствующий в ЗУП модуль ОбработкаОшибок ломает создание обработки.'

Write-Output 'ZUP employee list checks passed.'
