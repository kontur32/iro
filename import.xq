(:создает XML-файл с таблицей "импорт" для дистанта:)

import module namespace functx = "http://www.functx.com";
import module namespace xlsx = 'xlsx.iroio.ru' at 'module-xlsx.xqm';

declare namespace импорт = 'order.iroio.ru';


declare function импорт:слушатели ($path as xs:string) {
let $fl := file:list($path,false(), "*.xlsx")
let $memb := <слушатели группа = '{$path}'>
              {for $a in $fl
              return xlsx:fields(
                          xlsx:string(
                              xlsx:get-xml(file:read-binary($path||$a), 'xl/worksheets/sheet1.xml'),
                              xlsx:get-xml(file:read-binary($path||$a), 'xl/sharedStrings.xml')
                            )
                          )
            }
            </слушатели>

return 
    <слушатели>
        {for $b in $memb/child::*[признак[@имя = 'Форма']/text() = 'анкета']
          return
              <слушатель>
                 <курс>{$memb/child::*[признак[@имя = 'Форма']/text() = 'курс']/признак[@имя='Название']/text()}</курс> 
                 <почта>{$b/признак[@имя = "Электронная почта"]/data()}</почта>
                 <пароль>{substring(random:uuid(), 1, 6)}</пароль>
                 <фамилия>{$b/признак[@имя = "Фамилия"]/data()}</фамилия>
                 <имя>{$b/признак[@имя = "Имя"]/data()}</имя>
                 <отчество>{$b/признак[@имя = "Отчество"]/data()}</отчество>
                 <телефон>{$b/признак[@имя = "Телефон"]/data()}</телефон>
                 <организация>{$b/признак[@имя = "Организация"]/data()}</организация>
                 <должность>{$b/признак[@имя = "Должность"]/data()}</должность>
                 <дата_пк>{$b/признак[@имя = "Дата последнего ПК"]/data()}</дата_пк>
              </слушатель>
        }
    </слушатели>
};

declare variable $path := 'C:\Users\Пользователь\Downloads\ИРО\data\tmp\';

file:write($path|| 'import.xml', импорт:слушатели ($path), map{"method": "xml", 'omit-xml-declaration':'no'}) 