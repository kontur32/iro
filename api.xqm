module namespace page = 'http://basex.org/modules/web-page';

import module namespace request = "http://exquery.org/ns/request";
import module namespace конструктор = 'construct.iroio.ru' at 'construct.xqm';

(:import module namespace вывод = 'out.iroio.ru' at 'output.xqm';:)

declare
  %rest:path("иро/кпк/{$module}/{$function}")
  
  %output:method("xml")
  %output:omit-xml-declaration("no")
    
  function page:forms($module, $function) 
  
  {
    let $module_data := doc('config.xml')//module[name=$module]
   
    let $xquery := конструктор:xquery($module, $function)                
    return xquery:eval($xquery, map{'param' : request:parameter('курс')})
  };