(:~
 : This module contains some basic examples for RESTXQ annotations
 : @author BaseX Team
 :)
 
module namespace page = 'http://basex.org/modules/web-page';

import module namespace xlsx = 'xlsx.iroio.ru' at '../module-xlsx.xqm';
import module namespace импорт = 'order.iroio.ru' at '../import.xq';
import module namespace iro = 'db.iroio.ru' at 'dbhandle.xqm';

(:~
 : This function generates the welcome page.
 : @return HTML page
 :)
declare
  %rest:path("iro/{$db}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start($db)
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
      <p><h3>Открытые курсы:</h3></p>
      <ul>
          {for $a in iro:db-dir($db,'', 1)
          return <li><b><a href='iro/{$a}'>{ iro:get-data('iro', $a, 'Форма', 'курс')/child::признак[@имя='Название']/text()}</a></b>
                      <ul>
                        {for $b in iro:db-dir($db, $a, 2)
                         return <li>{$b}</li> }
                      </ul>
                 </li>}
      </ul>
    </body>
  </html>
};

declare
  %rest:path("iro/{$db}/{$kurs}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:kurs($db, $kurs)
  as element(Q{http://www.w3.org/1999/xhtml}html)
{
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>BaseX HTTP Services</title>
      <link rel="stylesheet" type="text/css" href="static/style.css"/>
    </head>
    <body>
      <div class="left"><img src="static/basex.svg" width="96"/></div>
      <h2>Это что-то новое на BaseX</h2>
      <p>
          <table>{for $a in iro:get-data('iro', $kurs, 'Форма', 'курс')/child::*
           return <tr><td>{$a/@имя/data()}</td> <td> : {$a/text()}</td></tr>
                
          }</table>
      </p>
      <p><a href='{$kurs}/list'>Список слушателей курса</a></p>
      <p><a href='{$kurs}/import'>Форма <b>Импорт</b></a></p>
    </body>
  </html>
};

declare
  %rest:path("iro/{$db}/{$kurs}/list")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:kurs-list($db, $kurs)
  as element()
{
  <html >
    <head>
      <title>BaseX HTTP Services</title>
      <link rel="stylesheet" type="text/css" href="static/style.css"/>
    </head>
    <body>
      <div class="left"><img src="static/basex.svg" width="96"/></div>
      <h2>Это что-то новое на BaseX</h2>
      <p>
            {let $data := iro:get-data($db, $kurs, 'Форма', 'анкета')
             return 
             <div> 
              <h3>Курс : {$data[признак[@имя='Форма']='курс']/признак[@имя='Название']/text()}</h3>
              {for $c in $data
              return
                <div>
                <h3>Слушатель: {string-join($c/child::*[@имя  = ('Фамилия',  'Имя', 'Отчество')]/text(),' ')}
                </h3>
                <table>
                    {for $a in $c/child::*[not (@имя  = ('Форма', 'Фамилия',  'Имя', 'Отчество')) and text()]
                    return <tr><td>{$a/@имя/data()}</td> <td> : {$a/text()}</td></tr>}
                 </table>  
                 </div>}
              </div>
           } 
           
      </p>
    </body>
  </html>
};

declare
  %rest:path("iro/{$db}/{$kurs}/import")
  %output:method("xml")
  %output:omit-xml-declaration("no")
    
  function page:kurs-import($db, $kurs) 
  
  {
    <слушатели>{импорт:слушатели2 ($db, $kurs)}</слушатели>
  };