import module  namespace dadata = 'https://dadata.ru/' at 'dadata.xqm';
 
 let $org_lists := ('http://dbx.iro37.ru/%D0%B8%D1%80%D0%BE/%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B5/%D0%BB%D0%B8%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D0%B8%20%D1%88%D0%BA%D0%BE%D0%BB%D1%8B%20%D0%B8%20%D0%B4%D1%80%D1%83%D0%B3%D0%B8%D0%B5',
'http://dbx.iro37.ru/%D0%B8%D1%80%D0%BE/%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B5/%D0%BB%D0%B8%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D0%B8%20%D0%B4%D0%BE%D1%83', 'http://iro37.ru/res/tmp/add-org.xml')

let $org_list2 := ('http://iro37.ru/res/tmp/schools-base.xml','http://iro37.ru/res/tmp/add-org.xml', 'http://dbx.iro37.ru/%D0%B8%D1%80%D0%BE/%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B5/%D0%BB%D0%B8%D1%86%D0%B5%D0%BD%D0%B7%D0%B8%D0%B8%20%D1%88%D0%BA%D0%BE%D0%BB%D1%8B%20%D0%B8%20%D0%B4%D1%80%D1%83%D0%B3%D0%B8%D0%B5')
 
 return
     <организации> 
       {dadata:order(dadata:merge-lists ($org_list2))}
     </организации>