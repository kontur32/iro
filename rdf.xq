module namespace rdfcons = "rdf.iroio.ru";

import module namespace xlsx = "xlsx.iroio.ru" at 'module-xlsx.xqm';
import module namespace functx = "http://www.functx.com";

declare function rdfcons:курс($params)
{
  let $sub :=  xlsx:fields-dir2($params?курс, '*.xlsx')/child::*
  let $schema := doc ('config_schemas.xml')/схемы/схема[@name="анкета"]
  return 
       rdfcons:element($sub, $schema)
};

declare function rdfcons:element($data, $schema)
{
    let $ID_field := doc('config_forms.xml')//form[@name = "анкета"]/@ID_field/data()
    return 
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    {for $b in $data
    let $c :=
      <Cлушатель rdf:about ="{ fn:escape-html-uri($schema/parent::*/@about|| $schema/@ID|| '#' || $b/child::*[@name=$ID_field]/data())}">
        {
          for $a in $b/child::*
          return element {xs:QName(replace($a/@name, ' ', '-'))} {$a/text()}
        }
      </Cлушатель>
      return functx:change-element-ns-deep($c,   fn:escape-html-uri($schema/parent::*/@about|| $schema/@ID || '#'), '' )
    }
    </rdf:RDF>
};


(:rdfcons:курс(map{'курс':'C:\Users\Пользователь\Downloads\ИРО\data\КПК2\'}):)