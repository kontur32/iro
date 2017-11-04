module namespace page = 'http://basex.org/modules/web-page';
import module namespace request = "http://exquery.org/ns/request";


(:import module namespace вывод = 'out.iroio.ru' at 'output.xqm';:)

declare
  %rest:path("iro/forms/{$module}/{$function}")
  %rest:query-param("path", "{$path}")
  %output:method("xml")
  %output:omit-xml-declaration("no")
    
  function page:forms($module, $function, $path) 
  
  {
    let $module_data := doc('config.xml')//module[name=$module]
    let $xquery := "import module namespace " || $module || "=" || $module_data/namespace/text() || " at " || $module_data/rel_path ||  "; declare variable $param external;" ||
                    $module || ":" || $function || "($param)"
    return xquery:eval($xquery, map{'param' : request:parameter('param')})
  };