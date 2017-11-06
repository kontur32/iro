(:модуль обработки файлов xlsx:)

module  namespace xlsx = 'xlsx.iroio.ru';

(: функция возвращает содержимое компонента $xml_name из файла $xls_name :)
declare function xlsx:get-xml ($xls_bin as xs:base64Binary, $xml_name as xs:string) as node ()
  {
    fn:parse-xml(replace(archive:extract-text($xls_bin, $xml_name), "xmlns=", "a="))
  };
 
(: возращает лист Excel $data_sheet_name  в форме дерева, 
заменяя значения индексов текстовых полей на их значения из $string_sheet :)
 declare function xlsx:string ($data_sheet as node() , $string_sheet as node()) as node()
   {
      let $strings :=  $string_sheet/sst/si/t
      let $sheet_data :=  $data_sheet
      
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
declare function xlsx:fields ($data_sheet as node(), $file_name as xs:string) as node()
  {
   <файл>
        <признак имя = 'Файл'>{$file_name}</признак>
        {for $row in $data_sheet//row[c[matches(@r, '[A]{1}')]]
        return <признак имя = "{$row/c[matches(@r, '[A]{1}')]}"> {$row/c[matches(@r, '[B]{1}')]//text()}</признак>}
   </файл>
  };
 
(:возвращает дерево обработанных функцией xlsx:fields() файлы Excel из каталога $path,
соответствующих маске $mask :)
 declare function xlsx:fields-dir ($path as xs:string, $mask as xs:string) as node()
   {
     let $fl := file:list($path, false(), $mask)
     return  
         <каталог путь = '{$path}'>
                  {for $a in $fl
                  return 
                        xlsx:fields(
                              xlsx:string(
                                  xlsx:get-xml(file:read-binary($path||$a), 'xl/worksheets/sheet1.xml'),
                                  xlsx:get-xml(file:read-binary($path||$a), 'xl/sharedStrings.xml')
                              ), $a
                         )
                  }
             </каталог>
             
   };