module namespace page = 'http://basex.org/modules/web-page';

import module namespace xlsx = 'xlsx.iroio.ru' at 'module-xlsx.xqm';
import module namespace импорт = 'order.iroio.ru' at 'import.xq';
import module namespace iro = 'db.iroio.ru' at 'web/dbhandle.xqm';

(:~
 : This function generates the welcome page.
 : @return HTML page
 :)
declare
  %rest:path("web/{$db}")
  %rest:query-param("path", "{$path}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:db($db, $path)
  as element()
{
  <html>
    <head>
      <title>BaseX HTTP Services</title>
      <link rel="stylesheet" type="text/css" href="static/style.css"/>
    </head>
    <body>
      <div class="left"><img src="static/basex.svg" width="96"/></div>
      <h2>Это что-то новое на BaseX</h2>
        <p>
            {iro:data-to-table(iro:get-meta($db, $path)/child::*[not (@имя='Тип')])}
        </p>
        <h3>Разделы:</h3>
        <ul>{for $a in iro:dir-list($db, $path)
          let $meta := iro:get-meta($db, $path || $a || '/')/child::*[@имя='Название']/text()
          return <li><a href='?path={$path}{$a}/'>{$meta}</a></li>}
        </ul>
        <h3>Файлы</h3>    
        <ul>
          {for $a in iro:file-list($db, $path)
              return <li>
                        <a href="http://localhost:8984/file/?db={$db}&amp;file={$path}{$a}">{$a}</a>
                     </li>}
        </ul>
        <h3>Формы вывода</h3>
        {for $a in iro:get-meta($db, $path)/child::признак[@имя='Вывод']/data()
          return 
            <p><a href="http://localhost:8984/web/forms/{$a}/?db={$db}&amp;path={$path}">Импорт</a>
            </p>}
        
    </body>
  </html>
};

declare
  %rest:path("file")
  %rest:query-param("db", "{$db}")
  %rest:query-param("file", "{$file}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:file($db, $file)
  as element()
{
  <html>
    <head>
      <title>BaseX HTTP Services</title>
      <link rel="stylesheet" type="text/css" href="static/style.css"/>
    </head>
    <body>
      <div class="left"><img src="static/basex.svg" width="96"/></div>
      <h2>Это что-то новое на BaseX</h2>
        {iro:data-to-table(iro:get-file($db, $file)/child::*)}
    </body>
  </html>
};

declare
  %rest:path("web/forms/import")
  %rest:query-param("db", "{$db}")
  %rest:query-param("path", "{$path}")
  %output:method("xml")
  %output:omit-xml-declaration("no")
    
  function page:kurs-import($db, $path) 
  
  {
    <слушатели>{импорт:слушатели2 ($db, $path)}</слушатели>
  };