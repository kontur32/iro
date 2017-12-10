(:~ 
 : Модуль является частью проекта iro
 : содержит функции для обработки запроса API
 :
 : @author   iro/ssm
 : @see      https://github.com/kontur32/iro/blob/dev2/README.md
 : @version  0.1
 :)

module namespace api = 'http://www.iroio.ru/api';
import module namespace request = "http://exquery.org/ns/request";
declare variable $api:ns := "http://www.iroio.ru";

(:~
 : Функция выполняет запрос Xquery, сгенерированный на основе параметров
 : переданного GET-запроса
 :
 : @param $module - модуль
 : @param $function - функция из запрашиваемого модуля
 : @return возращает результат выполнения функции $function из $module c 
 : параметрами из параметров запроса
 : @author iro/ssm
 : @since 0.1
 : 
:)

declare
  %rest:path("иро/{$module}/{$function}")  
  %output:method("xml")
  %output:omit-xml-declaration("no")
    
  function api:main( $module, $function) 
  {
     let $xquery := "import module namespace " || 
      $module || "= '" || $api:ns || "/" ||  $module || "' at '" || $module|| ".xqm';"||  
      "declare variable $param external;" ||
       $module || ":" || $function || "($param)"
    
    let $params := map:merge
                    (
                      for $a in request:parameter-names()
                      return map{$a : request:parameter($a)}
                    )                
    
    return xquery:eval( $xquery, map {'param' :  $params} )
  };