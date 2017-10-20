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

declare function iro:get-file($db, $path)
{
  
  let $raw := db:retrieve($db, $path)

  let $b := 
            xlsx:fields(
              xlsx:string( 
                    xlsx:get-xml($raw, 'xl/worksheets/sheet1.xml' ),
                    xlsx:get-xml($raw, 'xl/sharedStrings.xml')
                  )
              )
            
  return $b
};

declare function iro:file-list($db, $path)
{
  for $a in db:list($db, $path)
  return substring-after ($a, $path)[not (matches(., '/'))]
};

declare function iro:get-meta ($db, $path)
{
  for $a in iro:file-list($db, $path)
  return iro:get-data ($db, $path || $a , 'Тип', 'мета')
};

declare function iro:dir-list($db, $path)
{
  distinct-values(
  for $a in db:list($db, $path)
  return substring-before(substring-after($a, $path), '/'))[not (.='')]
};

declare function iro:data-to-table($data)
{
 
  let $out := for $a in $data
            return <tr>
                     <td>{$a/@имя/data()}</td>
                     <td> : {$a/text()}</td>
                   </tr>
  return 
         <table>
           {$out}
         </table>
};