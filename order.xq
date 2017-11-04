(:формирование приказа о зачислении:)
import module namespace functx = "http://www.functx.com";
import module namespace docx = "docx.iroio.ru" at 'module-docx.xqm';

declare namespace w="http://schemas.openxmlformats.org/wordprocessingml/2006/main";
declare namespace приказ = 'order.iroio.ru';

declare function приказ:записать ($tpl as xs:string,  (:имя файла с шаблоном:)
                                  $path as xs:string, (:папка с данными:)
                                  $output as xs:string) (:имя файла для записи:)
{
  let $template := fetch:binary($tpl)
  let $doc := fn:parse-xml (archive:extract-text($template,  'word/document.xml'))
  let $rows := for $row in doc($path)/child::*/child::*
                return docx:row($row)
  
  let $entry := docx:table-insert-rows ($doc, $rows)
  let $updated := archive:update ($template, 'word/document.xml', $entry)
  
  return  file:write-binary($output, $updated)
};

приказ:записать('http://iro.od37.ru/tpl/order1.docx',
              'http://localhost:8984/%D0%B8%D1%80%D0%BE/%D0%BA%D0%BF%D0%BA/%D0%B2%D1%8B%D0%B2%D0%BE%D0%B4/%D0%BF%D1%80%D0%B8%D0%BA%D0%B0%D0%B7?%D0%BA%D1%83%D1%80%D1%81=C:\Users\%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D0%B5%D0%BB%D1%8C\Downloads\%D0%98%D0%A0%D0%9E\data\%D0%9A%D0%9F%D0%9A\',
              'C:\Users\Пользователь\Downloads\ИРО\data\КПК\приказ_зачисление3.docx')