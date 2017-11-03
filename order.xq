(:формирование приказа о зачислении:)
import module namespace functx = "http://www.functx.com";
import module namespace xlsx = 'xlsx.iroio.ru' at 'module-xlsx.xqm';
import module namespace docx = "docx.iroio.ru" at 'module-docx.xqm';

declare namespace w="http://schemas.openxmlformats.org/wordprocessingml/2006/main";
declare namespace приказ = 'order.iroio.ru';

declare function приказ:слушатели ($memb as node()) 
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

declare function приказ:строки ($path as xs:string, $mask as xs:string) 
{
    for $row in приказ:слушатели( xlsx:fields-dir($path, $mask) )/child::*
    return docx:row($row)
};

declare function приказ:записать ($tpl as xs:string,  (:имя файла с шаблоном:)
                                  $path as xs:string, (:папка с данными:)
                                  $output as xs:string) (:имя файла для записи:)
{
  let $template := file:read-binary($tpl)
  let $doc := fn:parse-xml (archive:extract-text($template,  'word/document.xml'))
  let $entry := docx:table-insert-rows ($doc, приказ:строки($path, '*.xlsx'))
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return  file:write-binary($output, $updated)
};

(:
приказ:записать('C:\Users\Пользователь\Downloads\ИРО\шаблоны\шаблон_приказ_зачисление.docx',
              'C:\Users\Пользователь\Downloads\ИРО\data\tmp\', 
              'C:\Users\Пользователь\Downloads\ИРО\data\tmp\приказ_зачисление.docx') 
:)

приказ:слушатели( xlsx:fields-dir('C:\Users\Пользователь\Downloads\ИРО\data\КПК\', '*.xlsx') )