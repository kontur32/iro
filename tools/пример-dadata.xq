import module  namespace dadata = 'https://dadata.ru/' at 'dadata.xqm';
 
 let $org_lists := ('http://dbx.iro37.ru/%D0%B8%D1%80%D0%BE/%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B5/%D0%BB%D0%B8%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D0%B8%20%D0%B4%D0%BE%D1%83')

 
 return
     <организации> 
       {dadata:order(dadata:merge-lists ($org_lists))}
     </организации>