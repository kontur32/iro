module namespace api = 'http://basex.org/modules/web-page';

import module namespace request = "http://exquery.org/ns/request";

declare
  %rest:path("иро/кпк/{$module}/{$function}")  
  %output:method("xml")
  %output:omit-xml-declaration("no")
    
  function api:forms( $module, $function) 
  
  {
    let $xquery := api:xquery($module, $function)
    let $params := map:merge
                    (
                      for $a in request:parameter-names()
                      return map{$a : request:parameter($a)}
                    )                
    
    return xquery:eval( $xquery, map {'param' :  $params} )
  };
  
  declare function api:xquery ($module, $function) as xs:string
{
  let $module_data := doc('config.xml')//module[name=$module]
  let $xquery := "import module namespace " || $module || "=" || $module_data/namespace/text() || " at " || $module_data/rel_path ||  "; declare variable $param external;" ||
                    $module || ":" || $function || "($param)"
  return $xquery                  
};