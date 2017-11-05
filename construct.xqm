(::)
declare namespace конструктор = 'construct.iroio.ru';

declare function конструктор:запрос ($module, $function) as xs:string
{
  let $module_data := doc('config.xml')//module[name=$module]
  let $xquery := "import module namespace " || $module || "=" || $module_data/namespace/text() || " at " || $module_data/rel_path ||  "; declare variable $param external;" ||
                    $module || ":" || $function || "($param)"
  return $module_data                  
};

конструктор:запрос ('вывод', 'приказ')