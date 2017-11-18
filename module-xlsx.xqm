(:модуль обработки файлов .xlsx:)

module  namespace xlsx = 'xlsx.iroio.ru';
import module namespace functx = "http://www.functx.com";

declare default element namespace "http://schemas.openxmlformats.org/spreadsheetml/2006/main";

(: функция возвращает содержимое компонента $xml_name из файла $xls_name :)
declare function xlsx:get-xml ($path as xs:string, $xml_name as xs:string) as node ()
  {
        fn:parse-xml(
            archive:extract-text(
              file:read-binary($path), $xml_name
            )
        )/child::*
  };
 
(: возращает лист Excel $sheet_data  в форме дерева, 
заменяя значения индексов текстовых полей на их значения из $string_sheet :)
 declare function xlsx:string ($path as xs:string, $sheet as xs:string) as node()
   {
      let $sheet_data := xlsx:get-xml($path, $sheet)
      let $strings := xlsx:get-xml($path, 'xl/sharedStrings.xml')//t
       
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
   functx:change-element-ns-deep(  
   <файл>
        <признак имя = 'Файл'>{$file_name}</признак>
        {for $row in $data_sheet//row[c[matches(@r, '[A]{1}')]]
        return <признак имя = "{$row/c[matches(@r, '[A]{1}')]}"> {$row/c[matches(@r, '[B]{1}')]//text()}</признак>}
   </файл>, '', '')
   
  };
 
(:возвращает дерево обработанных функцией xlsx:fields() файлы Excel из каталога $path,
соответствующих маске $mask :)
 declare function xlsx:fields-dir ($path as xs:string, $mask as xs:string) as node()
   {
     let $file_list := file:list($path, false(), $mask)
     return  
       functx:change-element-ns-deep( 
         <каталог путь = '{$path}'>
                {for $a in $file_list
                return 
                   xlsx:fields(xlsx:string($path||$a, 'xl/worksheets/sheet1.xml'), $a)
                }
         </каталог>, '', '')        
   };
   
declare function xlsx:data-from-col($data as node(), $path)as node()
{
  <subjects xmlns=''>{
  let $a := $data/child::*
  for $b in 2 to count($a[1]/child::*)
  return 
      <subject>
      <predicate name="Файл">{$path}</predicate>
      {
        for $c in $a/child::*[$b]
        return <predicate name="{$c/parent::*/child::*[1]}">{$c//text()}</predicate>
      }</subject>
  }</subjects>
};

declare function xlsx:data-from-row($data as node(), $path as xs:string ) as node()
{
  <subjects xmlns=''>{
  let $a := $data/child::*
  for $b in $a[position() >= 2]
  return 
      <subject>
      <predicate name="Файл">{$path}</predicate>
      {
        for $c in $b/child::*
        return
        <predicate name="{$a[1]/child::*[functx:index-of-node($c/parent::*/child::*, $c)]//text()}">{$c//text()}</predicate>
      }</subject>
  }</subjects>
};

 declare function xlsx:fields-dir2 ($path as xs:string, $mask as xs:string) as node()
   {
     let $file_list := file:list($path, false(), $mask)
     return
       functx:change-element-ns-deep(    
         <каталог путь = '{$path}'>
                {for $a in $file_list
                return 
                   xlsx:data-from-col(xlsx:string($path||$a, 'xl/worksheets/sheet1.xml')//sheetData, $a)/child::*
                }
         </каталог>, "", "")     
   };