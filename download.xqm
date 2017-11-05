(:формирование приказа о зачислении:)
module namespace выгрузка = 'download.iroio.ru';

import module namespace functx = "http://www.functx.com";
import module namespace docx = "docx.iroio.ru" at 'module-docx.xqm';

declare function выгрузка:зачисление ($path as xs:string)
{
  let $tpl := 'http://iro.od37.ru/tpl/%D0%BF%D1%80%D0%B8%D0%BA%D0%B0%D0%B7_%D0%B7%D0%B0%D1%87%D0%B8%D1%81%D0%BB%D0%B5%D0%BD%D0%B8%D0%B5.docx'
  let $template := fetch:binary($tpl) (:имя файла с шаблоном:)
  let $request := functx:replace-multi(web:encode-url('http://localhost:8984/иро/кпк/вывод/приказ?курс=' || $path), ('%2F', '%3A', '%3D', '%3F', '%5C'), ('/', ':', '=', '?', '\\'))
  let $doc := fn:parse-xml (archive:extract-text($template,  'word/document.xml'))
  let $rows := for $row in doc($request)/child::*/child::*
                return docx:row($row)
  
  let $entry := docx:table-insert-rows ($doc, $rows)
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return  <p>Файл сохранен {$path || 'приказ-зачисление.docx' }{file:write-binary($path ||'приказ-зачисление.docx', $updated)}</p>
}; 

declare function выгрузка:вывод ($path as xs:string)
{
  <p>{выгрузка:зачисление ($path)}</p>
};