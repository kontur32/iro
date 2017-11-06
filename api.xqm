module namespace page = 'http://basex.org/modules/web-page';

import module namespace request = "http://exquery.org/ns/request";
import module namespace конструктор = 'construct.iroio.ru' at 'construct.xqm';

declare
  %rest:path("иро/кпк/{$module}/{$function}")  
  %output:method("xml")
  %output:omit-xml-declaration("no")
    
  function page:forms($module, $function) 
  
  {
    let $xquery := конструктор:xquery($module, $function)
    let $params := map:merge
                    (
                      for $a in request:parameter-names()
                      return map{$a : request:parameter($a)}
                    )                
    
    return xquery:eval( $xquery, map {'param' :  $params} )
  };