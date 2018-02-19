(:~ 
 : Модуль является частью проекта iro
 : содержит функции для обработки файлов xlsx
 :
 : @author   iro/ssm
 : @see      https://github.com/kontur32/iro/blob/dev2/README.md
 : @version  0.1
 :)
module  namespace xlsx = 'xlsx.iroio.ru';
import module namespace functx = "http://www.functx.com";

declare default element namespace "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
declare namespace r="http://schemas.openxmlformats.org/officeDocument/2006/relationships";

(: функция возвращает содержимое компонента $xml_name из файла $xls_name :)
declare function xlsx:get-xml ($file_path as xs:string, $sheet_name as xs:string)
  {
        fn:parse-xml(
            archive:extract-text(
              file:read-binary($file_path), $sheet_name
            )
        )/child::*
  };
 
(: возращает лист Excel $sheet_data  в форме дерева, 
заменяя значения индексов текстовых полей на их значения из $string_sheet :)
 declare function xlsx:string ($file_path as xs:string, $sheet_name as xs:string)
   {
      let $sheet_data := xlsx:get-xml($file_path, $sheet_name)
      let $strings := xlsx:get-xml($file_path, 'xl/sharedStrings.xml')//t
       
      let $new := 
          copy $c := $sheet_data 
          modify 
                for $i in $c//c[@t='s']
                return replace value of node $i/v with $strings[number($i/v/text())+1]/text()
          return $c
      return $new
   };
  
(:функция возравщает разобранный в дерево лист Excel $sheet_name из файла $xlsx_fullname,
интерпретируя первую колонку таблицы как имя признака, а вторую колонку как его значение:)
declare function xlsx:fields ($data_sheet as node(), $file_name as xs:string)
  {
   functx:change-element-ns-deep(  
   <файл>
        <признак имя = 'Файл'>{$file_name}</признак>
        {for $row in $data_sheet//row[c[matches(@r, '[A]{1}')]]
        return <признак имя = "{$row/c[matches(@r, '[A]{1}')]}"> {$row/c[matches(@r, '[B]{1}')]/v/text()}</признак>}
   </файл>, '', '')
   
  };
 
(:возвращает дерево обработанных функцией xlsx:fields() файлы Excel из каталога $path,
соответствующих маске $mask :)
 declare function xlsx:fields-dir ($path as xs:string, $mask as xs:string)
   {
     let $file_list := file:list($path, false(), $mask)
     return  
       functx:change-element-ns-deep( 
         <каталог путь = '{$path}'>
                {for $a in $file_list
                return 
                   for $b in ('xl/worksheets/sheet1.xml', 'xl/worksheets/sheet2.xml')
                   return
                       xlsx:fields(xlsx:string($path||$a, $b), $a)
                }
         </каталог>, '', '')        
   };

(:~
 : Функция извлекает данные из файла xlsx 
 : значения полей в колонках, первая колонка имена полей
 :
 : @param $data - дерево из листа xlsx
 : @param $path - имя файла xlsx, из которого извлекаются данные
 : @return возрващает нанные в виде дерева
 : 
 : @author iro/ssm
 : @since 0.1
 : 
:)   
declare function xlsx:data-from-col($data, $sheet_name) as element ()
{
  let $a := $data//sheetData/child::*
  return
  <table sheet_name= "{$sheet_name}">
  {
    for $b in 2 to count($a[1]/child::*)
    return 
      <row>
        {
          for $c in $a/child::*[$b]
          return <cell name="{$c/parent::*/child::*[1]}">{$c//text()}</cell>
        }
      </row>
  }
  </table>
};

declare function xlsx:data-from-row($data as node(), $sheet_name) as node()
{
 let $dn := $data//row[1]//v[text()]/text()

return
element {xs:QName( 'table')}
{
  attribute sheet_name {$sheet_name},
  for $r in $data//row[position()>1]
return
  element {xs:QName( 'row')}
      {
        for $c in 1 to count($dn)
        return 
            element {xs:QName( 'cell')}
            {
              attribute name {$dn[$c]},
              $r/c[number($c)-1]/v/text()
            }
      }
}
};

 declare function xlsx:fields-dir2 ($path as xs:string, $mask as xs:string) as node()
   {
     let $file_list := file:list($path, false(), $mask)
     return
       functx:change-element-ns-deep(    
         <subjects путь = '{$path}'>
                {for $a in $file_list
                return 
                   xlsx:data-from-col(xlsx:string($path||$a, 'xl/worksheets/sheet1.xml'), 'таблица')/child::*
                }
         </subjects>, "", "")     
   };
      
   
declare function xlsx:data-from-file ($file_path)
{
    let $sheets_list :=  archive:entries(file:read-binary($file_path))[contains (text(), 'xl/worksheets/sheet')]/text()
    let $meta_sheet := 
          for $a in $sheets_list
          return xlsx:string ($file_path, $a)[.//sheetData/row[1]/c[1]/v/text()='__мета']
          
    let $meta := xlsx:data-from-row($meta_sheet, 'мета')
    let $workbook := xlsx:get-xml ($file_path, 'xl/workbook.xml')
    let $wbrels := xlsx:get-xml ($file_path, 'xl/_rels/workbook.xml.rels')

return 
  element file     
    {
    attribute file_name {$file_path},  
      
    for $sheet in $sheets_list
    let $sheet_name := $workbook//sheet[@r:id/data()=$wbrels/child::*[@Target/data()= substring-after($sheet,'/')]/@Id/data()]/@name/data()
    
    let $sheet_direction := functx:if-empty($meta//row[cell[@name = 'лист']/text()=$sheet_name]/cell[@name='ориентация']/text(), 'строки')
    let $output := $meta/row[cell[@name='лист'] = $sheet_name]/cell[@name='вывод']/text()
    
    let $curr_sheet := xlsx:string($file_path, $sheet)
    
    return if ($output = 'да') then (if ($sheet_direction = 'строки') then (xlsx:data-from-row($curr_sheet, $sheet_name)) else (xlsx:data-from-col($curr_sheet, $sheet_name))) else ()
    }
};

declare function xlsx:data-from-dir ($path as xs:string, $mask as xs:string)
{
  let $file_list := file:list($path, false(), $mask)
  return
      element directory 
      {
        attribute path {$path},
        for $a in $file_list
        return xlsx:data-from-file($path || $a)
      }
};

(: --- возращает содержимое листа эксель в виде дереве - данные в строках  --- :)
declare function xlsx:xlsx-to-table-rows($data as element()) as element()
{
  let $heads := 
        for $b in $data//row[1]
        return $b//v/text()
  
  return 
  element {QName('','table')}
  {    
  for $b in $data//row[position()>1]
  return
    element {QName('','row')}
      { 
      for $c in $b/child::*
      return 
          element {QName('','cell')} 
            {
              attribute {'name'} {$heads[count($c/preceding-sibling::*)+1]}, 
              $c/v/text()
            }
      }
  }
};


(: --- старые версии --- :)
   declare function xlsx:fields-dir3 ($path as xs:string, $mask as xs:string) as node()
   {
     let $file_list := file:list($path, false(), $mask)
     return
       functx:change-element-ns-deep(    
         <subjects путь = '{$path}'>
                {for $a in $file_list
                return 
                   xlsx:data-from-row(xlsx:string($path||$a, 'xl/worksheets/sheet1.xml'), 'таблица')/child::*
                }
         </subjects>, "", "")     
   };