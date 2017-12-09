module namespace rdfxml = "rdf.iroio.ru";

import module namespace xlsx = "xlsx.iroio.ru" at 'module-xlsx.xqm';
import module namespace functx = "http://www.functx.com";

(:~ 
 : Модуль является частью проекта iro
 : содержит функции для формирования данных в формате RDF/XML
 :
 : @author   iro/ssm
 : @see      https://github.com/kontur32/iro/blob/dev2/README.md
 : @version  0.1
 :)

declare namespace rdf = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';

(:~
 : Функция преобразует данные из .xlsx файлов в синтаксис RDF/XML
 :
 : @param $params - map{'курс':'значение пути'} передает путь к файлам 
 : @return возвращает данные из файлов .xlsx, расположенных в каталоге заданном
 : $params?курс в синтаксисе RDF/XML
 : 
 : @author iro/ssm
 : @since 0.1
 : 
:)
declare %public function rdfxml:курс($params) as node()
{
  let $sub :=  functx:change-element-ns-deep(xlsx:data-from-dir ($params?курс, '*.xlsx'), '', '')//table[row[1]/cell[1][not(@name='__мета')]]/child::*
  let $schema := doc ('config_schemas.xml')/child::*/child::*[@name="анкета"]
  return
    element {QName('http://www.w3.org/1999/02/22-rdf-syntax-ns#','rdf:RDF')}
              {for $a in $sub
              return
                   rdfxml:element($a, $schema)/child::*}
};

declare %private function rdfxml:element($data as node(), $schema as node()*) as element ()
{
    let $ID_field := doc('config_forms.xml')/child::*/child::*[@name = "анкета"]/@ID_field/data()
    let $xmlns := $schema/parent::*/@about/data() ||  '/' ||  $schema/@ID/data() ||'#'
    return 
        element {QName('http://www.w3.org/1999/02/22-rdf-syntax-ns#','rdf:RDF')}
        {
          for $b in $data
          return 
             element      
                rdf:Description
                {
                  namespace {''}{$xmlns},
                  attribute {'rdf:ID'} {rdfxml:build-id($b/child::*[@name= $ID_field]/data())},
                  attribute {'xml:base'} {$schema/@base},
                  element rdf:type { attribute rdf:Resource {$schema/@type} },
                  for $a in $b/child::*
                  return element {QName($xmlns, replace($a/@name, ' ', '-'))} {$a/text()}
                }
        }  
};

declare %private function rdfxml:build-id ($id as xs:string) as xs:string
{
  'id-' || functx:replace-multi($id, ('@','\.'), ('_at_', '-dot-'))
};