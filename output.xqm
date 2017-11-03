(:создает XML-файл с таблицей "импорт" для дистанта:)

module  namespace вывод = 'out.iroio.ru';

import module namespace functx = "http://www.functx.com";
import module namespace xlsx = 'xlsx.iroio.ru' at 'module-xlsx.xqm';


declare function вывод:импорт ($path as xs:string) {
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

declare function вывод:сведения($path as xs:string) as node()
{
  let $sch := doc('http://iro.od37.ru/dic/schools.xml')/школы/школа
  let $fl := file:list($path,false(), "*.xlsx")
  let $memb := <слушатели>
                {for $a in $fl
                return xlsx:fields(
                            xlsx:string(
                                xlsx:get-xml(file:read-binary($path||$a), 'xl/worksheets/sheet1.xml'),
                                xlsx:get-xml(file:read-binary($path||$a), 'xl/sharedStrings.xml')
                              )
                            )[not (признак[@имя='Фамилия'] = '')]
              }
              </слушатели>


  let $out:=    for $a in $memb/файл
      let $index := string-join($a/признак[@имя/data()= ('Муниципалитет', 'Организация')]/text(), '')
      let $org := $sch[поле[@имя = ('мо_короткое')]/text() || поле[@имя = ('короткое')]/text() = $index]
      return <слушатель>
                <муниципалитет>{$org/поле[@имя="мо"]/data()}</муниципалитет>
                <организация>{$org/поле[@имя="короткое"]/data()}</организация>
                <руководитель>{$org/поле[@имя="руководитель"]/data()}</руководитель>
                <ФИО_слушателя>{string-join($a/признак[@имя=('Фамилия', 'Имя', 'Отчество')]/text(), ' ')}</ФИО_слушателя>
                <должность>{$a/признак[@имя='Должность']/text()}</должность>
                <номер></номер>
                <дата></дата>
                <срок></срок>
                <адрес_организации>{string-join(($org/поле[@имя="адрес"]/data(), 'ИНН ' || $org/поле[@имя="ИНН"]/data(), 'КПП ' || $org/поле[@имя="КПП"]/data()), ", ")}</адрес_организации>
             </слушатель>
           
  return <слушатели>{$out}</слушатели>
};

declare function вывод:приказ ($path as xs:string) 
 {
    let $mo := doc('http://iro.od37.ru/dic/mo.xml')/mo
    let $memb := xlsx:fields-dir($path, '*.xlsx')
    let $sort := for $i in $memb/child::*
                 order by $i//признак[@имя = "Фамилия"]/text()
                 where $i//признак[@имя = "Фамилия"]/text()
                 return $i
      
    let $rows :=  <строки>
         {for $a in $sort
         return <строка>
                    <номер>
                      {functx:index-of-node($sort, $a) || "."}
                    </номер>
                    <фио>
                      {$a//признак[@имя = "Фамилия"]/text() || " " }{$a//признак[@имя = "Имя"]/text() || " "}{$a//признак[@имя = "Отчество"]/text()}
                    </фио>
                    <должность>
                      {$mo/mo[@name_shot = $a//признак [@имя = "Муниципалитет"]/text()]/text() || ", " 
                       || $a//признак [@имя = "Школа" or @имя = "Организация"]/text() || ", " 
                       || $a//признак [@имя = "Должность"]/text() || " "
                       || $a//признак [@имя = "Предмет"]/text()}
                    </должность>
                 </строка>}
      </строки>
     return $rows
};

(:
declare variable $path := 'C:\Users\пользователь\Downloads\ИРО\data\КПК\';
declare variable $schools :=  'C:\Users\пользователь\Downloads\schools-mo-shot.xml';
вывод:приказ-зачисление ($path)
:)