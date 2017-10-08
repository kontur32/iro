(:модуль обработки файлов xlsx:)

module  namespace xlsx = 'xlsx.iroio.ru';

(: функция возвращает содержимое компонента $xml_name из файла $xls_name :)
declare function xlsx:get-xml ($xls_name as xs:string, $xml_name as xs:string) as node ()
  {
    fn:parse-xml(replace(archive:extract-text(file:read-binary($xls_name), $xml_name), "xmlns=", "a="))
  };

 
(:функция возращает лист Excel $sheet_name из из файла $xlsx_fullname
 в форме дерева, заменяя значения индексов текстовых полей на их значения:)
 declare function xlsx:string ($xlsx_fullname as xs:string, $sheet_name as xs:string) as node()
   {
      let $strings :=  xlsx:get-xml ($xlsx_fullname,  "xl/sharedStrings.xml")/sst/si/t
      let $sheet_data :=  xlsx:get-xml ($xlsx_fullname, $sheet_name)
      
      let $new := 
          copy $c := $sheet_data 
          modify 
                for $i in $c//c[@t='s']
                return replace value of node $i/v with $strings[number($i/v/text()+1)]/text()
          return $c
      return $new 
   };
  
(:функция возравщает разобранный в дерево лист Excel $sheet_name из файла $xlsx_fullname,
интерпретируя первую колонку таблицы как имя признака, а вторую колонку как его значение:)
declare function xlsx:fields ($xlsx_fullname as xs:string, $sheet_name as xs:string) as node()
  {
   <файл имя = "{$xlsx_fullname}">
        {for $row in xlsx:string ($xlsx_fullname, $sheet_name)//row[c[matches(@r, '[A]{1}')]]
        return <признак имя = "{$row/c[matches(@r, '[A]{1}')]}"> {$row/c[matches(@r, '[B]{1}')]//text()}</признак>}
   </файл>
  };
  