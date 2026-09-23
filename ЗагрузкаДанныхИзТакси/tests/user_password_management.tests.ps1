$ErrorActionPreference = 'Stop'

$testRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$projectRoot = Split-Path -Parent $testRoot
$objectModule = Join-Path $projectRoot 'ЗагрузкаДанныхИзТакси\Ext\ObjectModule.bsl'
$objectText = Get-Content -Raw -Encoding UTF8 -LiteralPath $objectModule

function Assert-Matches {
    param([string]$Text, [string]$Pattern, [string]$Message)
    if ($Text -notmatch $Pattern) { throw $Message }
}

Assert-Matches $objectText `
    '(?s)Функция ДобавитьПользователяИБ\(СтруктураПараметров\).*?ПотребоватьСменуПароляПриВходе' `
    'Добавление пользователя не обрабатывает требование смены пароля при входе.'
Assert-Matches $objectText `
    'Функция ИзменитьПарольПользователяИБ\(СтруктураПараметров\)' `
    'В обработке бухгалтерии нет операции изменения пароля.'
Assert-Matches $objectText `
    'ОписаниеПользователяИБ\.Пароль\s*=\s*Пароль' `
    'Новый пароль не передается механизму пользователей БСП.'
Assert-Matches $objectText `
    'ОписаниеПользователяИБ\.Вставить\("ПотребоватьСменуПароляПриВходе"' `
    'Требование смены пароля не передается механизму пользователей БСП.'
Assert-Matches $objectText `
    'СтруктураПараметров\.ТипЗапроса\s*=\s*"ИзменитьПарольПользователяИБ"' `
    'Операция изменения пароля не подключена к маршрутизации запросов.'

Write-Output 'User password management accounting checks passed.'
