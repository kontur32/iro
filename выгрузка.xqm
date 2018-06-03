(:модуль выгрузки документов по КПК:)
module namespace выгрузка = 'http://www.iroio.ru/выгрузка';

import module namespace docx = "docx.iroio.ru" at 'module-docx.xqm';
import module  namespace xlsx = 'xlsx.iroio.ru' at "module-xlsx.xqm"; 
import module  namespace кпк = 'http://www.iroio.ru/кпк' at 'кпк.xqm';

declare function выгрузка:зачисление ($path) as element()
{
  let $tpl := 'http://iro37.ru/res/tpl/%d0%bf%d1%80%d0%b8%d0%ba%d0%b0%d0%b7_%d0%b7%d0%b0%d1%87%d0%b8%d1%81%d0%bb%d0%b5%d0%bd%d0%b8%d0%b5.docx'
  let $template := fetch:binary($tpl)
  let $doc := parse-xml (archive:extract-text($template,  'word/document.xml')) 
  
  let $rows := for $row in кпк:зачисление($path)/child::*
                return docx:row($row)
  
  let $entry := docx:table-insert-rows ($doc, $rows)
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return  <p>Файл сохранен {$path?курс || 'формы\' || 'приказ-зачисление.docx' }{выгрузка:write-binary($updated, $path?курс || 'формы\', 'приказ-зачисление.docx')}</p>
};

declare function выгрузка:импорт ($path)
{
  <p>Файл сохранен {$path?курс || 'формы\' || 'импорт.xml' }{выгрузка:write-xml ( кпк:импорт ($path), $path?курс|| 'формы\' ,  'импорт.xml')}</p>
};

declare function выгрузка:сведения ($path) as element()
{
 let $tpl := 'http://iro37.ru/res/tpl/%d0%91%d0%bb%d0%b0%d0%bd%d0%ba%202%20%d0%b4%d0%bb%d1%8f%20%d0%b1%d1%83%d1%85%d0%b3%d0%b0%d0%bb%d1%82%d0%b5%d1%80%d0%b8%d0%b8.docx'
 let $template := fetch:binary($tpl) (:имя файла с шаблоном:)
 let $doc := parse-xml (archive:extract-text($template,  'word/document.xml'))

 let $rows := for $row in кпк:сведения($path)/child::*
              return docx:row($row)
               
 let $entry := docx:table-insert-rows ($doc, $rows)
 let $updated := archive:update ($template, 'word/document.xml', $entry)

 return <p>Файл сохранен {$path?курс  || 'формы\' || 'сведения.docx' }{выгрузка:write-binary ($updated, $path?курс || 'формы\', 'сведения.docx')}</p>
};

declare function выгрузка:файлы ($path)
{
  <p>Файл сохранен {$path?курс || 'формы\' || 'файлы.xml' }{выгрузка:write-xml( кпк:файлы ($path), $path?курс || 'формы\',  'файлы.xml')}</p>
};

declare function выгрузка:сводная ($path)
{
  let $имя-файла := 'сводная-' || $path?строки ||'-' || $path?столбцы ||'.xml'
  return 
  <p>Файл сохранен { $path?курс || 'формы\' || $имя-файла} {выгрузка:write-xml( кпк:сводная ($path), $path?курс || 'формы\' , $имя-файла )}</p>
};

declare function выгрузка:сводная-итоги ($path)
{
  let $имя-файла := 'сводная-' || $path?строки ||'-' || $path?столбцы ||'.xml'
  return 
  <p>Файл сохранен { $path?курс || 'формы\' || $имя-файла} {выгрузка:write-xml( кпк:сводная-итоги ($path), $path?курс || 'формы\' , $имя-файла )}</p>
};

declare function выгрузка:анкеты-по-шаблону($params)
{
  <p>Формы сохранены в {$params?курс || $params?папка} {
    let $данные := xlsx:fields-dir ($params?курс, '*.xlsx')//файл[признак[@имя='Фамилия']/text()]
    for $i in $данные
    let $имя-файла := string-join ($i//признак[@имя=('Фамилия', 'Имя', 'Отчество')]/text(), '_') ||  '.docx' 
    return 
       выгрузка:write-binary (docx:обработать-шаблон($i, $params?шаблон ), $params?курс || $params?папка, $params?префикс || $имя-файла )
  }</p>
};

declare function выгрузка:шаблон-в-файл($params)
{
  <p>Формы сохранены в {$params?курс || $params?папка || $params?префикс || 'персональные.docx'} {
    let $данные := xlsx:fields-dir ($params?курс, '*.xlsx')//файл[признак[@имя='Фамилия']/text()]
    
    return 
       выгрузка:write-binary (docx:шаблон-в-один ($данные, $params?шаблон ), $params?курс || $params?папка, $params?префикс || 'персональные.docx') }</p>
};

declare function выгрузка:write-binary ($файл, $путь-сохранение, $имя-файла)
{
   let $создать := if (file:is-dir( $путь-сохранение)) then() else (file:create-dir( $путь-сохранение))
   return
         file:write-binary ($путь-сохранение || $имя-файла,  $файл)
};

declare function выгрузка:write-xml ($файл, $путь-сохранение, $имя-файла)
{
   let $создать := if (file:is-dir( $путь-сохранение)) then() else (file:create-dir( $путь-сохранение))
   return
         file:write ($путь-сохранение || $имя-файла,  $файл, map{'omit-xml-declaration' : 'no'})
};

(: ---------------------- код А.К. Калинина --------------------------- :)

declare function выгрузка:зачет ($path) as element()
{
  let $tpl := 'http://iro37.ru/res/tpl/%d0%97%d0%b0%d1%87%d0%b5%d1%82%d0%bd%d0%b0%d1%8f%20%d0%b2%d0%b5%d0%b4%d0%be%d0%bc%d0%be%d1%81%d1%82%d1%8c.docx'
  let $template := fetch:binary($tpl) (:имя файла с шаблоном:)
  let $doc := parse-xml (archive:extract-text($template,  'word/document.xml')) 
  
  let $rows := for $row in кпк:зачет($path)/child::*
                return docx:row($row)
  
  let $entry := docx:table-insert-rows ($doc, $rows)
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return  
      <p>Файл сохранен {$path?курс || 'формы\' || 'зачет.docx' }{выгрузка:write-binary( $updated, $path?курс || 'формы\', 'зачет.docx' )}</p>
};

declare function выгрузка:отчисление ($path) as element()
{
  let $tpl := 'http://iro37.ru/res/tpl/%d0%9f%d1%80%d0%b8%d0%ba%d0%b0%d0%b7%20%d0%be%d0%b1%20%d0%be%d0%ba%d0%be%d0%bd%d1%87%d0%b0%d0%bd%d0%b8%d0%b8.docx'
  let $template := fetch:binary($tpl) (:имя файла с шаблоном:)
  let $doc := parse-xml (archive:extract-text($template,  'word/document.xml')) 
  
  let $rows := for $row in кпк:отчисление($path)/child::*
                return docx:row($row)
  
  let $entry := docx:table-insert-rows ($doc, $rows)
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return 
    <p>Файл сохранен {$path?курс || 'формы\' || 'приказ-окончание.docx' }{выгрузка:write-binary( $updated, $path?курс || 'формы\', 'приказ-окончание.docx' )}</p>
};

declare function выгрузка:лист ($path) as element()
{
  let $tpl := 'http://iro37.ru/res/tpl/%d0%a0%d0%b5%d0%b3%d0%b8%d1%81%d1%82%d1%80%d0%b0%d1%86%d0%b8%d0%be%d0%bd%d0%bd%d1%8b%d0%b9_%d0%bb%d0%b8%d1%81%d1%82_%d0%9a%d0%9f%d0%9a.docx'
  let $template := fetch:binary($tpl)
  let $doc := parse-xml (archive:extract-text($template,  'word/document.xml')) 
  
  let $rows := for $row in кпк:лист($path)/child::*
                return docx:row($row)
  
  let $entry := docx:table-insert-rows ($doc, $rows)
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return  
    <p>Файл сохранен {$path?курс || 'формы\' || 'регистрационный_лист.docx' }{выгрузка:write-binary( $updated, $path?курс || 'формы\', 'регистрационный_лист.docx' )}</p>
};