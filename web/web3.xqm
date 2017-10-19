module namespace page = 'http://basex.org/modules/web-page';

import module namespace xlsx = 'xlsx.iroio.ru' at '../module-xlsx.xqm';
import module namespace импорт = 'order.iroio.ru' at '../import.xq';
import module namespace iro = 'db.iroio.ru' at 'dbhandle.xqm';

(:~
 : This function generates the welcome page.
 : @return HTML page
 :)
declare
  %rest:path("web2/{$db}")
  %rest:query-param("path", "{$path}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start($db, $path)
  as element()
{
  <html>
    <head>
      <title>BaseX HTTP Services</title>
      <link rel="stylesheet" type="text/css" href="static/style.css"/>
    </head>
    <body>
        <h2>{iro:meta-file($db, $path)/child::*[@имя='Название']/text()}</h2>
        <p>{let $b := for $a in db:list($db, $path || '/')
              return substring-before($a, '/')
          for $c in db:list($db, distinct-values($b))  
          return <h3><a href = "?path={substring-after($c, $path)}/"> {$c}</a></h3>}
        </p>
    </body>
  </html>
};