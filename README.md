# iro
обработка распределенной пользовательской информации в  XML на XQUERY
## API для доступа к функциям:
`http://localhost:8984/иро/кпк/вывод/приказ?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\`  - выведет в браузер xml-документ, содержащий сведения для заполнения [приказа о зачислении](http://iro.od37.ru/tpl/приказ_зачисление.docx) для группы слушателей, чьи анкеты находятся в `C:\Users\пользователь\Downloads\ИРО\data\КПК\`

- http://localhost:8984/иро/ - точка входа
- кпк/ - раздел документов
- вывод/ - [модуль](https://github.com/kontur32/iro/blob/dev2/output.xqm "Модуль") документов
- приказ/  - документ
- ?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\ - параметр

## Раздел "КПК"
Для работы с данными по курсам повышения квалификации
Все фукнции имеют один парамерт `курс` - путь к папке с анкетами слушателей.  
Использует словари:
- [школы Ивановской области](http://iro.od37.ru/dic/schools.xml)
- [муниципальные образования Ивановской области](http://iro.od37.ru/dic/mo.xml)
Использует шаблоны:
- [приказ о зачислении](http://iro.od37.ru/tpl/приказ_зачисление.docx)

### Модули/функции:
- модуль `вывод` - формирует данные по группе слушателей КПК:
  - документ `приказ` - даныне для приказа о зачислении слушателей
  - документ `импорт` - данные для регистрации на дистанте
  - документ `сведения` - данные для заполнения формы "Сведения..."

- модуль `выгрузка` - выгружает (сохраняет на диске) формы отчетов по группе слушателей:
  - документ `зачисление` - выгружает в формате .docx приказ о зачислении на основе [шаблона](http://iro.od37.ru/tpl/приказ_зачисление.docx)


## Ресурсы:
- словари http://iro.od37.ru/dic/  
- шаблоны http://iro.od37.ru/tpl/
