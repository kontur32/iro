(:модуль выгрузки документов по КПК:)
module namespace выгрузка = 'http://www.iroio.ru/выгрузка';

import module namespace docx = "docx.iroio.ru" at 'module-docx.xqm';
import module  namespace xlsx = 'xlsx.iroio.ru' at "module-xlsx.xqm"; 
import module  namespace кпк = 'http://www.iroio.ru/кпк' at 'кпк.xqm';

declare function выгрузка:зачисление ($path) as element()
{
  let $tpl := 'http://iro37.ru/res/tpl/%d0%bf%d1%80%d0%b8%d0%ba%d0%b0%d0%b7_%d0%b7%d0%b0%d1%87%d0%b8%d1%81%d0%bb%d0%b5%d0%bd%d0%b8%d0%b5.docx'
  let $template := fetch:binary($tpl) (:имя файла с шаблоном:)
  let $doc := parse-xml (archive:extract-text($template,  'word/document.xml')) 
  
  let $rows := for $row in кпк:зачисление($path)/child::*
                return docx:row($row)
  
  let $entry := docx:table-insert-rows ($doc, $rows)
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return  <p>Файл сохранен {$path?курс || 'приказ-зачисление.docx' }{file:write-binary($path?курс ||'приказ-зачисление.docx', $updated)}</p>
};

declare function выгрузка:импорт ($path)
{
  <p>Файл сохранен {$path?курс || 'импорт.xml' }{file:write($path?курс|| 'импорт.xml', кпк:импорт ($path), map{'omit-xml-declaration' : 'no'})}</p>
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

 return <p>Файл сохранен {$path?курс || 'сведения.docx' }{file:write-binary ($path?курс ||'сведения.docx', $updated)}</p>
};

declare function выгрузка:сведения1 ($path)
{
  <p>Файл сохранен {$path?курс || 'сведения.xml' }{file:write($path?курс|| 'сведения.xml', кпк:сведения ($path), map{'omit-xml-declaration' : 'no'})}</p>
};

declare function выгрузка:зачет ($path) as element()
{
  let $tpl := 'http://iro37.ru/res/tpl/%d0%97%d0%b0%d1%87%d0%b5%d1%82%d0%bd%d0%b0%d1%8f%20%d0%b2%d0%b5%d0%b4%d0%be%d0%bc%d0%be%d1%81%d1%82%d1%8c.docx'
  let $template := fetch:binary($tpl) (:имя файла с шаблоном:)
  let $doc := parse-xml (archive:extract-text($template,  'word/document.xml')) 
  
  let $rows := for $row in кпк:зачет($path)/child::*
                return docx:row($row)
  
  let $entry := docx:table-insert-rows ($doc, $rows)
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return  <p>Файл сохранен {$path?курс || 'зачет.docx' }{file:write-binary($path?курс ||'зачет.docx', $updated)}</p>
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
  
  return  <p>Файл сохранен {$path?курс || 'приказ-окончание.docx' }{file:write-binary($path?курс ||'приказ-окончание.docx', $updated)}</p>
};

declare function выгрузка:файлы ($path)
{
  <p>Файл сохранен {$path?курс || 'файлы.xml' }{file:write($path?курс|| 'файлы.xml', кпк:файлы ($path), map{'omit-xml-declaration' : 'no'})}</p>
};

declare function выгрузка:сводная ($path)
{
  let $file_name := $path?курс || 'сводная-' || $path?строки ||'-' || $path?столбцы ||'.xml'
  return 
  <p>Файл сохранен {$file_name}{file:write($file_name, кпк:сводная ($path), map{'omit-xml-declaration' : 'no'})}</p>
};

declare function выгрузка:сводная-итоги ($path)
{
  let $file_name := $path?курс || 'сводная-итоги-' || $path?строки ||'-' || $path?столбцы ||'.xml'
  return 
  <p>Файл сохранен {$file_name}{file:write($file_name, кпк:сводная-итоги ($path), map{'omit-xml-declaration' : 'no'})}</p>
};

declare function выгрузка:анкеты-по-шаблону($params)
{
  <p>Формы сохранены в {$params?курс || $params?папка} {
  let $данные := xlsx:fields-dir ($params?курс, '*.xlsx')//файл[признак[@имя='Фамилия']/text()]
  for $i in $данные
  let $имя-файла := string-join ($i//признак[@имя=('Фамилия', 'Имя', 'Отчество')]/text(), '_') ||  '.docx' 
   return 
       docx:обработать-шаблон($i, $params?шаблон, $params?курс || $params?папка, $params?префикс || $имя-файла )
  }</p>
};