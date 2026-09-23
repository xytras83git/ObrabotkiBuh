$ErrorActionPreference = 'Stop'

$testRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$projectRoot = Split-Path -Parent $testRoot
$objectModule = Join-Path $projectRoot 'ЗагрузкаДанныхИзТакси\ЗагрузкаДанныхИзТакси\Ext\ObjectModule.bsl'
$objectText = Get-Content -Raw -Encoding UTF8 -LiteralPath $objectModule

function Assert-Matches {
    param([string]$Text, [string]$Pattern, [string]$Message)
    if ($Text -notmatch $Pattern) { throw $Message }
}

Assert-Matches $objectText `
    'Функция ДобавитьПользователяИБ\(СтруктураПараметров\)' `
    'В бухгалтерской обработке нет операции добавления пользователя.'
Assert-Matches $objectText `
    'ПользователиИнформационнойБазы\.НайтиПоИмени\(' `
    'Перед созданием не проверяется дубликат имени пользователя ИБ.'
Assert-Matches $objectText `
    'Пользователи\.НовоеОписаниеПользователяИБ\(\)' `
    'Для создания пользователя не используется стандартное описание БСП.'
Assert-Matches $objectText `
    'ДополнительныеСвойства\.Вставить\([\s\S]*?"ОписаниеПользователяИБ"' `
    'Элемент справочника не связывается с пользователем ИБ через БСП.'
Assert-Matches $objectText `
    'ОписаниеПользователяИБ\.АутентификацияСтандартная\s*=\s*Истина' `
    'Для нового пользователя не включена стандартная аутентификация.'
Assert-Matches $objectText `
    'ОписаниеПользователяИБ\.Вставить\("ВходВПрограммуРазрешен",\s*Истина\)' `
    'Новому пользователю не разрешен вход в программу.'
Assert-Matches $objectText `
    'ТипЗапроса\s*=\s*"ДобавитьПользователяИБ"' `
    'Операция добавления пользователя не подключена к диспетчеру запросов.'

Write-Output 'User creation accounting checks passed.'
