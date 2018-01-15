(:модуль генераци отчетов по группам КПК:)
(:для всех функций параметры передаются через $params as map{}:)

module  namespace кпк = 'http://www.iroio.ru/кпк';

import module namespace functx = "http://www.functx.com";
import module namespace xlsx = 'xlsx.iroio.ru' at 'module-xlsx.xqm';


declare variable $кпк:config := doc('config.xml'); (:пути к словарям и модулям:)

declare %output:method("xml") function кпк:импорт ($params) as element()
{

let $memb := xlsx:fields-dir ($params?курс, '*.xlsx')
let $result := 
    <слушатели>
        {for $b in $memb/child::*[признак[@имя = 'Фамилия']/text()] (: [признак[@имя = 'Форма']/text() = 'анкета'] :)
          return
              <слушатель>
                 <курс>{$memb/child::*[признак[@имя = 'Форма']/text() = 'курс']/признак[@имя='Название']/text()}</курс> 
                 <почта>{$b/признак[@имя = "Электронная почта"]/data()}</почта>
                 <пароль></пароль>
                 <фамилия>{$b/признак[@имя = "Фамилия"]/data()}</фамилия>
                 <имя>{$b/признак[@имя = "Имя"]/data()}</имя>
                 <отчество>{$b/признак[@имя = "Отчество"]/data()}</отчество>
                 <телефон>{$b/признак[@имя = "Телефон"]/data()}</телефон>
                 <организация>{$b/признак[@имя = "Организация"]/data()}</организация>
                 <должность>{$b/признак[@имя = "Должность"]/data()}</должность>
                 <дата_пк>{$b/признак[@имя = "Год предыдущего обучения на курсах"]/data()}</дата_пк>
              </слушатель>
        }
    </слушатели>
 return  $result
};


declare function кпк:сведения ($params) as element ()
{
  let $org_path := iri-to-uri($кпк:config//dictionary[name/text()='oo']/location/text())
  let $orgs := fetch:xml($org_path)/child::*/child::*
  
  let $memb := xlsx:fields-dir ($params?курс, '*.xlsx')

  let $out:=
      for $a in $memb/child::*[признак[@имя = 'Фамилия']/text()]
      let $org := $orgs[inn = $a//признак[@имя='ИНН организации']/text()]
      return <слушатель>
                <номер>{functx:index-of-node($memb/child::*, $a) || "."}</номер>
                <муниципалитет>{$org/mo/text()}</муниципалитет>
                <организация>{$org/short__with__opf/text()}</организация>
                <руководитель>{$org/name/text()}</руководитель>
                <ФИО_слушателя>{string-join($a/признак[@имя=('Фамилия', 'Имя', 'Отчество')]/text(), ' ')}</ФИО_слушателя>
                <должность>{$a/признак[@имя='Должность']/text()}</должность>
                <номер></номер>
                <дата></дата>
                <стоимость></стоимость>
                <срок></срок>
                <адрес_организации>
                  {string-join(($org/postal__code/text(), $org/unrestricted__value/text(), 'ИНН ' || $org/inn/text() , 'КПП ' || $org/kpp/text()), ", ")}
                </адрес_организации>
             </слушатель>
           
  return <слушатели>{$out}</слушатели>
};

declare function кпк:зачисление ($params) 
 {
    let $mo_dic := $кпк:config//dictionary[name/text()='mo']/location/text()
    let $mo := doc($mo_dic)/mo
    let $memb := xlsx:fields-dir($params?курс, '*.xlsx')
    let $sort := for $i in $memb/child::*
                 order by $i//признак[@имя = "Фамилия"]/text()
                 where $i//признак[@имя = "Фамилия"]/text()
                 return $i
      
    let $rows :=  <строки>
         {for $a in $sort
         return <строка>
                    <номер>
                      {functx:index-of-node($sort, $a) || "."}
                    </номер>
                    <фио>
                      {$a//признак[@имя = "Фамилия"]/text() || " " }{$a//признак[@имя = "Имя"]/text() || " "}{$a//признак[@имя = "Отчество"]/text()}
                    </фио>
                    <должность>
                      {$mo/mo[@name_shot = $a//признак [@имя = "Муниципалитет"]/text()]/text() || ", " 
                       || $a//признак [@имя = "Школа" or @имя = "Организация"]/text() || ", " 
                       || $a//признак [@имя = "Должность"]/text() || " "
                       || $a//признак [@имя = "Предмет"]/text()}
                    </должность>
                 </строка>}
      </строки>
     return $rows
};

declare function кпк:файлы ($params) 
 {
     let $file_data := 
            for $a in xlsx:fields-dir ($params?курс, '*.xlsx')/файл[признак[@имя='Фамилия']/data()]
            order by $a/признак[@имя='Файл']
            return
              <файл>
                  {
                    for $b in $a/child::*
                    let $node := replace($b/@имя/data(), ' ', '-')
                    return parse-xml ('<'|| $node || '>' || $b/text() || '</'|| $node || '>')
                  }
              </файл>
return <папка>{$file_data}</папка>
};

declare function кпк:сводная ($param) 
 {
   let $rows_name := $param?строки
   let $cols_name := $param?столбцы
   
   let $data := xlsx:fields-dir ($param?курс , '*.xlsx')/файл[признак[@имя='Фамилия']/data()]
   let $students := copy $d := <a>{$data}</a>
                   modify 
                         for $b in $d//признак[not (text())]
                         return replace value of node $b with 'неуказан'
                   return $d/child::*
       
    let $rows := distinct-values(for $a in $students
                    order by $a/признак[@имя=$rows_name]
                    return $a/признак[@имя=$rows_name])
    
    let $col :=  distinct-values(for $a in $students
                    order by $a/признак[@имя=$cols_name]
                    return $a/признак[@имя=$cols_name])
                    
    return  
      <rows>
        {
          for $a in distinct-values($rows)
          return 
            <row>
              <название>{$a}</название>
              <итого>{count($students[признак[@имя=$rows_name]=$a])}</итого>
              {
                for $b in $col       
                return parse-xml('<'||  functx:replace-multi($b, ('(\d+)', ' '), ('a$1', '-'))|| '>'|| count($students[признак[@имя=$rows_name]=$a and признак[@имя=$cols_name]=$b]) || '</' ||  functx:replace-multi($b, ('(\d+)', ' '), ('a$1', '-')) || '>')
              }
            </row>
            
          }
          
      </rows>
 };
 
 declare function кпк:сводная-итоги ($params) 
 {
   let $data := кпк:сводная($params)
   let $dic_path := doc ('config_forms.xml')//field[@name/data()=$params?строки]//location/text()
   let $rows_dic := doc($dic_path)/child::*/child::*/@name_shot/data()   
   
  return
  <rows>
  { 
   for $a in $rows_dic
   return <row><название>{$a}</название>{$data/child::*[название/text()=$a]/child::*[not (name()='название') and matches(name(), ($params?поля)) ]}</row>
   }
   <row>
     <название>Всего</название>
       {
         for $a in distinct-values($data/child::*/child::*[not (name()='название') and matches(name(), ($params?поля))]/name())
         let $b := $data/child::*/child::*[name()=$a]
         let $c := <node>{sum($b)}</node>
         return functx:change-element-names-deep($c, xs:QName('node'), xs:QName($a))
       }
   </row>
   </rows>
 };
 
 (: ------- Старые версии ----------:)
 declare  function кпк:сведения-old01($params) as node()
{
  let $sch_dic := $кпк:config//dictionary[name/text()='schools']/location/text()
  let $sch := doc($sch_dic)/школы/школа
  
  let $memb := xlsx:fields-dir ($params?курс, '*.xlsx')

  let $out:=
      for $a in $memb/child::*
      let $index := string-join($a/child::*[@имя/data()= ('Муниципалитет', 'Организация')]/text(), '')
      let $org := $sch[child::*[@имя = ('мо_короткое')]/text() || child::*[@имя = ('короткое')]/text() = $index]
      return <слушатель>
                <муниципалитет>{$org/поле[@имя="мо"]/data()}</муниципалитет>
                <организация>{$org/поле[@имя="короткое"]/data()}</организация>
                <руководитель>{$org/поле[@имя="руководитель"]/data()}</руководитель>
                <ФИО_слушателя>{string-join($a/признак[@имя=('Фамилия', 'Имя', 'Отчество')]/text(), ' ')}</ФИО_слушателя>
                <должность>{$a/признак[@имя='Должность']/text()}</должность>
                <номер></номер>
                <дата></дата>
                <срок></срок>
                <адрес_организации>{string-join(($org/поле[@имя="адрес"]/data(), 'ИНН ' || $org/поле[@имя="ИНН"]/data(), 'КПП ' || $org/поле[@имя="КПП"]/data()), ", ")}</адрес_организации>
             </слушатель>
           
  return <слушатели>{$out}</слушатели>
};