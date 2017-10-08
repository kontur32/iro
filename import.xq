import module namespace functx = "http://www.functx.com";

import module namespace xlsx = 'xlsx.iroio.ru' at 'module-xlsx.xqm';
import module namespace docx = "docx.iroio.ru" at 'module-docx.xqm';

declare namespace w="http://schemas.openxmlformats.org/wordprocessingml/2006/main";
declare namespace импорт = 'order.iroio.ru';

declare function импорт:слушатели ($memb as node()) 
{
  let $mo := doc('C:\Users\Пользователь\Downloads\ИРО\dic\mo2.xml')/mo
    let $sort := for $i in $memb/child::*
                 order by $i//признак[@имя = "Фамилия"]/text()
                 where $i//признак[@имя = "Фамилия"]/text()
                 return $i
      
    let $rows :=  <строки>
         {for $a in $sort
         return <строка>
                    <ячейка>
                      {functx:index-of-node($sort, $a) || "."}
                    </ячейка>
                    <ячейка>
                      {$a//признак[@имя = "Фамилия"]/text() || " " }{$a//признак[@имя = "Имя"]/text() || " "}{$a//признак[@имя = "Отчество"]/text()}
                    </ячейка>
                    <ячейка>
                      {$mo/mo[@name_shot = $a//признак [@имя = "Муниципалитет"]/text()]/text() || ", " 
                       || $a//признак [@имя = "Школа" or @имя = "Организация"]/text() || ", " 
                       || $a//признак [@имя = "Должность"]/text() || " "
                       || $a//признак [@имя = "Предмет"]/text()}
                    </ячейка>
                 </строка>}
      </строки>
     return $rows 
};


let $path := 'C:\Users\Пользователь\Downloads\ИРО\data\tmp\'
let $fl := file:list($path,false(), "*.xlsx")
let $memb := <слушатели группа = '{$path}'>
              {for $a in $fl
              return xlsx:fields($path||$a, 'xl/worksheets/sheet1.xml')}
            </слушатели>
let $fields := ('Электронная почта', 'Фамилия', 'Имя', 'Отчество', 'Телефон', 'Организация', 'Должность', 'Стаж', 'Дата последнего ПК')

return 
<слушатели>
{
  for $b in $memb/child::*
  return
      <слушатель>
       <курс>Здесь должно быть название курса...</курс> 
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