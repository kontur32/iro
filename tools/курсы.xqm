module namespace курс = 'kurs.iroio.ru';

declare default element namespace "http://iro37.ru/schema/Kurs#";
declare namespace rdf = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';

declare function курс:мета ($каталог , $признак)
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

declare function курс:сводная($data, $row_name, $col_name)
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
            for $col in $cols_name
            return
              element 
                {QName('', 'ячейка')}
                {count($data/child::*[child::*[@имя=$col_name][text()=$col]])}
          }  
    }  
};