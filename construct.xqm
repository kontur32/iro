module namespace конструктор = 'construct.iroio.ru';
import module namespace functx = "http://www.functx.com";

declare function конструктор:xquery ($module, $function) as xs:string
{
  let $module_data := doc('config.xml')//module[name=$module]
  let $xquery := "import module namespace " || $module || "=" || $module_data/namespace/text() || " at " || $module_data/rel_path ||  "; declare variable $param external;" ||
                    $module || ":" || $function || "($param)"
  return $xquery                  
};

declare function конструктор:url ($baseURL as xs:string, $pathURL as xs:string, $parameter)
{
   escape-html-uri( web:create-url($baseURL || $pathURL, $parameter))
};