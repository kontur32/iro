# iro
API, реализованный на [BaseX](http://basex.org/), для обработки средствами XQUERY распределенной пользовательской информации, хранящейся в XML

## API для доступа к функциям:
`http://localhost:8984/иро/кпк/вывод/зачисление?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\`  
- выведет в браузер xml-документ, содержащий сведения для заполнения [приказа о зачислении](http://iro.od37.ru/tpl/приказ_зачисление.docx) для группы слушателей, чьи анкеты находятся в `C:\Users\пользователь\Downloads\ИРО\data\КПК\`

- `http://localhost:8984/иро/` - точка входа
- `кпк/` - раздел документов
- `вывод/` - [модуль](https://github.com/kontur32/iro/blob/dev2/output.xqm "Модуль") документов
- `зачисление/`  - документ
- `?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\` - параметр

## Раздел "КПК"
Для работы с данными по курсам повышения квалификации.  
Все фукнции имеют парамерт `курс` - путь к папке с анкетами слушателей.  
Использует словари:
- [школы Ивановской области](http://iro.od37.ru/dic/schools.xml)
- [муниципальные образования Ивановской области](http://iro.od37.ru/dic/mo.xml)

Использует шаблоны:
- [приказ о зачислении](http://iro.od37.ru/tpl/приказ_зачисление.docx)

### Модули/функции:
- модуль [`вывод`](https://github.com/kontur32/iro/blob/dev2/output.xqm) - формирует данные по группе слушателей КПК:
  - документ `зачисление` - даныне для приказа о зачислении слушателей
  - документ `импорт` - данные для регистрации на дистанте
  - документ `сведения` - данные для заполнения формы "Сведения..."
  - документ `файлы` - содержимое файлов, указанных в параметре `курс`
  - документ `сводная` - строит сводную таблицу с учетом параметров `строки` `столбцы`
  - документ `сводная-итоги` - делает сводную таблицу: `строки` - поля анкеты со [словарями](http://iro.od37.ru/dic/), `столбцы` - любые поля анкеты, параметр `поля` определеяет состав полей в зависимости от принимаемых значений: "итого" - только общие итоги, ".*" - итоги с разбивкой по значениям полей

- модуль [`выгрузка`](https://github.com/kontur32/iro/blob/dev2/download.xqm) - выгружает (сохраняет на диске) формы отчетов по группе слушателей:
  - документ `зачисление` - выгружает в формате .docx приказ о зачислении на основе [шаблона](http://iro.od37.ru/tpl/приказ_зачисление.docx) в папку, указанную в `курс`,
  - остальные документы выгружает в формате .xml


## Ресурсы:
- словари http://iro.od37.ru/dic/  
- шаблоны http://iro.od37.ru/tpl/

## Примеры запросов
- http://localhost:8984/иро/кпк/вывод/зачисление?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\ - выводит данные для приказа о зачислении в браузер
- http://localhost:8984/иро/кпк/выгрузка/зачисление?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\ - созраняет приказ о зачислении в формате .docx
- http://localhost:8984/иро/кпк/вывод/сводная?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\&строки=Муниципалитет&столбцы=Должность - формирует сводную таблицу
- [http://localhost:8984/иро/кпк/вывод/сводная-итоги?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\\&строки=Муниципалитет&столбцы=Тип%20организации&поля=.*](http://localhost:8984/иро/кпк/вывод/сводная-итоги?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\\&строки=Муниципалитет&столбцы=Тип%20организации&поля=.*)
- [http://localhost:8984/иро/кпк/вывод/сводная-итоги?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\\&строки=Возраст&столбцы=Пол&поля=.*](http://localhost:8984/иро/кпк/вывод/сводная-итоги?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\\&строки=Возраст&столбцы=Пол&поля=.*])
- [http://localhost:8984/иро/кпк/вывод/сводная-итоги?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\\&строки=Муниципалитет&столбцы=Тип%20организации&поля=.*](http://localhost:8984/иро/кпк/вывод/сводная-итоги?курс=C:\Users\пользователь\Downloads\ИРО\data\КПК\\&строки=Муниципалитет&столбцы=Тип%20организации&поля=.*)
