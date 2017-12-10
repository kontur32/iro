(:модуль выгрузки документов по КПК:)
module namespace выгрузка = 'http://www.iroio.ru/выгрузка';

import module namespace docx = "docx.iroio.ru" at 'module-docx.xqm';
import module  namespace вывод = 'out.iroio.ru' at 'output.xqm';

declare function выгрузка:зачисление ($path) as element()
{
  let $tpl := 'http://iro.od37.ru/tpl/%D0%BF%D1%80%D0%B8%D0%BA%D0%B0%D0%B7_%D0%B7%D0%B0%D1%87%D0%B8%D1%81%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5.docx'
  let $template := fetch:binary($tpl) (:имя файла с шаблоном:)
  let $doc := parse-xml (archive:extract-text($template,  'word/document.xml')) 
  
  let $rows := for $row in вывод:зачисление($path)/child::*
                return docx:row($row)
  
  let $entry := docx:table-insert-rows ($doc, $rows)
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return  <p>Файл сохранен {$path?курс || 'приказ-зачисление.docx' }{file:write-binary($path?курс ||'приказ-зачисление.docx', $updated)}</p>
};

declare function выгрузка:импорт ($path)
{
  <p>Файл сохранен {$path?курс || 'импорт.xml' }{file:write($path?курс|| 'импорт.xml', вывод:импорт ($path), map{'omit-xml-declaration' : 'no'})}</p>
};

declare function выгрузка:сведения ($path)
{
  <p>Файл сохранен {$path?курс || 'сведения.xml' }{file:write($path?курс|| 'сведения.xml', вывод:сведения ($path), map{'omit-xml-declaration' : 'no'})}</p>
};

declare function выгрузка:файлы ($path)
{
  <p>Файл сохранен {$path?курс || 'файлы.xml' }{file:write($path?курс|| 'файлы.xml', вывод:файлы ($path), map{'omit-xml-declaration' : 'no'})}</p>
};

declare function выгрузка:сводная ($path)
{
  let $file_name := $path?курс || 'сводная-' || $path?строки ||'-' || $path?столбцы ||'.xml'
  return 
  <p>Файл сохранен {$file_name}{file:write($file_name, вывод:сводная ($path), map{'omit-xml-declaration' : 'no'})}</p>
};

declare function выгрузка:сводная-итоги ($path)
{
  let $file_name := $path?курс || 'сводная-итоги-' || $path?строки ||'-' || $path?столбцы ||'.xml'
  return 
  <p>Файл сохранен {$file_name}{file:write($file_name, вывод:сводная-итоги ($path), map{'omit-xml-declaration' : 'no'})}</p>
};
