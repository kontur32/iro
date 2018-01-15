module namespace dadata = 'https://dadata.ru/';

import module namespace xlsx = 'xlsx.iroio.ru' at '../module-xlsx.xqm';
import module namespace functx = "http://www.functx.com";

declare function dadata:get-from-dadata($org)
{
let $data :=
    <организации>
          {for $a in $org
          let $query := '{"query":"' ||$a|| '"}'
          let $binary :=  http:send-request(
            <http:request method='post' href='http://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/party'>
              <http:header name="Content-Type" value="application/json"/>
              <http:header name="Accept" value="application/json"/>
              <http:header name = "Authorization" value= "Token 2a3c28f9fcbe4ef80ff468607c3ac9c4be26a6e4" />
              <http:body media-type="application/json">{$query}</http:body>
            </http:request>
          )[2]/json/suggestions/_[data/type/text()="LEGAL" and not (starts-with(data/opf/code/text(), '3'))]
          return 
          <организация>{
                              
                              $binary//short__with__opf, 
                              $binary//full__with__opf,
                              $binary//inn,
                              $binary//kpp,
                              $binary//ogrn,
                              $binary//management/name,
                              $binary//management/post,
                              <mo>{if (substring ($binary//address/data/oktmo, 1, 3) = '246') 
                                  then ($binary//area/text())
                                  else ($binary//city/text())}
                              </mo>,
                              $binary//area,
                              $binary//city,
                              $binary//address/unrestricted__value,
                              $binary//address/data/postal__code,
                              $binary//address/data/kladr__id,
                              $binary//address/data/area__type__full,
                              $binary//address/data/city__type__full,
                              $binary//address/data/okato,
                              $binary//address/data/oktmo,
                              $binary/data/state/status
                            }
               </организация>
                 update delete node .//@type 
               }
  </организации>
  
  return $data
};
 
declare function dadata:add-orgtype ($org_egrul as element()*, $org_type as element()*)
{
  for $c in $org_egrul
  let $type := $org_type//row[cell[@name="ИНН"]/text() = $c/inn/text()]/cell[@name="Тип_учреждения"]/text()
  return 
      $c update insert node <org_type>{functx:if-empty($type, 'школа')}</org_type> into .
};

declare function dadata:merge-lists ($org_lists)
{
         for $a in $org_lists
         let $org := fetch:xml($a)/child::*
         return 
              dadata:add-orgtype (dadata:get-from-dadata($org/child::*/child::*[@name="ИНН" or @имя="ИНН"  ]/text())//организация, $org)
        
};
 
declare function dadata:order ($org)
{
  for $a in $org
  order by   substring ($a/oktmo, 1, 3) descending, $a/mo/text() 
  return $a 
};