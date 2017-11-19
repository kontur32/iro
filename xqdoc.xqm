module namespace xqdoc = "xqdoc.iroio.ru";
import module namespace html = "http://www.28msec.com/xqdoc/lib/html";
(:import module namespace html = "http://www.zorba-xquery.com/modules/xqdoc/html" at 'C:\Users\Пользователь\Downloads\html.xqm';:)

declare
  %rest:path("иро/doc")  
  %output:method("xhtml")
 
    
  function xqdoc:doc() 
  
  {
     <html>
       <body>
         <h1>Модули проекта iro</h1>
         <ul>
         {
           for $a in file:list('C:\Program Files (x86)\BaseX\webapp\iro', false(), '*.xq*')
           order by $a
           return
               <li> 
                 <a href = "http://localhost:8984/%D0%B8%D1%80%D0%BE/doc/{$a}">{$a}</a>
               </li>
         }
         </ul>
       </body>
     </html>
     
  };


declare
  %rest:path("иро/doc/{$module}")  
  %output:method("xhtml")
 
    
  function xqdoc:module($module ) 
  
  {
     <html>
       <body>
         <p><i><a href = "/иро/doc">назад к списку модулей...</a></i></p>
         <p><b>МОДУЛЬ:</b></p>
         {html:convert(inspect:xqdoc ($module))}
       </body>
     </html>
  };


declare
  %rest:path("иро/xqdoc/{$module}")  
  %output:method("xml")
 
  function xqdoc:doc($module ) 
  
  {
    inspect:xqdoc ($module)   
  };
