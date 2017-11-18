(:~ 
 : Модуль является частью проекта iro
 : Модуль содержит функции для обработки запроса API
 :
 : @author   iro/ssm
 : @see      https://github.com/kontur32/iro/blob/dev2/README.md
 : @version  0.1
 :)

module namespace api = 'api.iroio.ru';
import module namespace request = "http://exquery.org/ns/request";

(:~
 : Функция выполняет запрос Xquery, сгенерированный на основе параметров
 : переданного GET-запроса
 :
 : @param $module - модуль
 : @param $function - функция из запрашиваемого модуля
 : @return возращает результат выполнения функции $function из $module c 
 : с параметрами из параметров запроса
 : @author iro/ssm
 : @since 0.1
 : 
:)

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
  
  
(:~
 : Функция генериует запрос Xquery, на основе параметров
 : переданного GET-запроса
 :
 : @param $module - модуль
 : @param $function - функция из запрашиваемого модуля
 : @return возращает в виде строки запрос Xquery для вызова функции $function  
 : из $module 
 : @author iro/ssm
 : @since 0.1
 : 
:)  
  
  declare function api:xquery ($module, $function) as xs:string
{
  let $module_data := doc('config.xml')//module[name=$module]
  let $xquery := "import module namespace " || $module || "=" || $module_data/namespace/text() || " at " || $module_data/rel_path ||  "; declare variable $param external;" ||
                    $module || ":" || $function || "($param)"
  return $xquery                  
};