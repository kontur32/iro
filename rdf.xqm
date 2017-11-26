module namespace rdfxml = "rdf.iroio.ru";

import module namespace xlsx = "xlsx.iroio.ru" at 'module-xlsx.xqm';
import module namespace functx = "http://www.functx.com";

declare namespace rdf = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';

declare function rdfxml:курс($params)
{
  let $sub :=  xlsx:fields-dir2($params?курс, '*.xlsx')/child::*[child::*[@name="Электронная почта"]/data()]
  let $schema := doc ('config_schemas.xml')/child::*/child::*[@name="анкета"]
  return 
       rdfxml:element($sub, $schema)
};

declare function rdfxml:element($data as node(), $schema as node()*)
{
    let $ID_field := doc('config_forms.xml')/child::*/child::*[@name = "анкета"]/@ID_field/data()
    let $xmlns := escape-html-uri($schema/parent::*/@about || '/схемы/' || $schema/@ID ||'#')
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
                  attribute {'xml:base'} {rdfxml:build-base($schema/parent::*/@about, $schema/@ID)},
                  element rdf:type { attribute rdf:Resource {$xmlns || 'Слушатель'} },
                  for $a in $b/child::*
                  return element {QName($xmlns, replace($a/@name, ' ', '-'))} {$a/text()}
                }
        }  
};

declare function rdfxml:build-id ($id as xs:string)
{
  'id-' || functx:replace-multi($id, ('@','\.'), ('_at_', '-dot-'))
};

declare function rdfxml:build-base ($about as xs:string, $id as xs:string)
{
  $about|| '/' ||$id
};

(: --- старые версии --- :)
declare function rdfxml:element1($data, $schema)
{
    let $ID_field := doc('config_forms.xml')/child::*/child::*[@name = "анкета"]/@ID_field/data()
    return 
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    {for $b in $data
    let $c :=
      <Cлушатель rdf:ID ="{escape-html-uri('id-' || functx:replace-multi($b/child::*[@name= $ID_field]/data(), ('@','\.'), ('_at_', '-dot-')))}" 
                 xml:base = "{escape-html-uri($schema/parent::*/@about|| '/' ||$schema/@ID/data())}">
        {
          for $a in $b/child::*
          return element {xs:QName(replace($a/@name, ' ', '-'))} {$a/text()}
        }
      </Cлушатель>
      return functx:change-element-ns-deep($c, escape-html-uri($schema/parent::*/@about || '/схемы/' || $schema/@ID ||'#'), '' )
    }
    </rdf:RDF>
};