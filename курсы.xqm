module namespace курсы = 'http://www.iroio.ru/курсы';

import module namespace xlsx = 'xlsx.iroio.ru' at 'module-xlsx.xqm';
import module namespace html='html.iroio.ru' at 'webinterface.xqm';

declare default element namespace "http://iro37.ru/schema/Kurs#";
declare namespace rdf = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';

declare function курсы:мета ($каталог , $признак)
{
  if (file:exists ($каталог || '.iro') )
  then 
  (
    let $мета-файл := file:read-text($каталог || '.iro')
    let $курсы := db:open('open', 'курсы.xml')
    let $метка := substring-after (substring-before($мета-файл, ';'), '=')
    return 
      $курсы//rdf:Description[slug/text()=$метка]/child::*[name()=$признак]/text()
  )
  else (false())
};

declare function курсы:сводная($data, $row_name, $col_name)
{
  let $rows_name := distinct-values($data/child::*/child::*[@имя=$row_name][text()])
  let $cols_name := distinct-values($data/child::*/child::*[@имя=$col_name][text()])
  
  return
    element {QName('', 'файл')}
    {
      element {QName('', 'строка')} 
      {
        element {QName('', 'ячейка')} {$row_name},
        element {QName('','ячейка')} {'итого'},
        for $column in $cols_name
        return 
            element {QName('', 'ячейка')} {$column}
      },
      for $row in $rows_name
      let $current_rows := $data/child::*[child::*[@имя=$row_name][text()=$row]]
      return
        element 
          {QName('', 'строка')}
          {
            element {QName('', 'ячейка')} {$row},
            element {QName('', 'ячейка')} {count($current_rows)},
            for $col in $cols_name
            return  
                element  
                  {QName('', 'ячейка')}
                  {count($current_rows/child::*[@имя=$col_name][text()=$col])}
           },
        element
          {QName ('', 'строка')}
          {
            element {QName('', 'ячейка')} {'всего'},
            element 
              {QName('', 'ячейка')} 
              {count($data/child::*/child::*[@имя=$col_name][text()])},
            for $col in $cols_name
            return
              element 
                {QName('', 'ячейка')}
                {count($data/child::*[child::*[@имя=$col_name][text()=$col]])}
          }  
    }  
};

declare 
  %output:method("xml") 
  function курсы:курс ($params) as element()
{
  let $путь_кпк := $params?курсы
  let $группировать_по := $params?группировать_по
  let $строки := $params?строки
  let $колонки := $params?колонки
  
  let $список_курсов := file:list ($путь_кпк)
  let $значения := 
                distinct-values( 
                  for $a in $список_курсов
                  return 
                    курсы:мета ($путь_кпк || $a, $группировать_по)
              )
  return
    <отчет>
    {
        for $значение in $значения
        return
           <раздел>  
            <строка>
              <ячейка>{$группировать_по}: {$значение}</ячейка>
             </строка>
            
            <строка>
                <ячейка>{$строки}</ячейка>
                <ячейка>итого</ячейка>
              {
                for $a in db:open('dic', lower-case($колонки || '.xml'))/child::*/child::*
                return 
                  <ячейка>{$a/text()}</ячейка>
              }
             </строка>
            
            {for $курс in $список_курсов
            where курсы:мета ($путь_кпк || $курс,'объем')=$значение
            return курсы:сводная(xlsx:fields-dir($путь_кпк || $курс, '*.xlsx'), $строки, $колонки)/child::*[position()>1]}
          </раздел>
  }
  </отчет>  
};