module  namespace iro = 'db.iroio.ru';
import module namespace xlsx = 'xlsx.iroio.ru' at '../module-xlsx.xqm';

declare %updating function iro:store($inputpath,$dbpath )
{
for $a in file:list( $inputpath, true(), '*.xlsx')
return db:store('iro', $dbpath || $a, file:read-binary($inputpath || $a))
};

declare function iro:db-dir($db as xs:string, $path, $level as xs:integer)
{
  let $a := for $b in db:list($db, $path)
          return fn:tokenize ($b, '/')[$level]

  return fn:distinct-values($a)
};

declare function iro:get-data($db, $path, $field, $value)
{
  for $a in db:list($db, $path)
  let $raw := db:retrieve($db, $a)

  let $b := 
            xlsx:fields(
              xlsx:string( 
                    xlsx:get-xml($raw, 'xl/worksheets/sheet1.xml' ),
                    xlsx:get-xml($raw, 'xl/sharedStrings.xml')
                  )
              )[признак[@имя/data() = $field] = $value]
            
  return $b
};

declare function iro:dir-resource($db, $path)
{
  for $a in db:list($db, $path)
  return substring-after ($a, $path)[not (matches(., '/'))]
};

declare function iro:meta-file ($db, $path)
{
  for $a in iro:dir-resource($db, $path)
  return iro:get-data ($db, $path || $a , 'Тип', 'мета')
};
