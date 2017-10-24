declare   namespace сведения = 'sved.iroio.ru';
import module namespace импорт = 'order.iroio.ru' at 'import.xq';
 
(:
Функция создает набор данных для формы для бухгалтерии о слушателях, чьи анкеты находтятся в папке $path, используя данные о школах находящихся по адресу $school (например, 'C:\Users\пользователь\Downloads\schools-mo.xml' или 'http://iro.od37.ru/dic/schools-mo.xml')
:)
declare function сведения:форма($path, $schools)
{
let $memb := импорт:слушатели($path)/слушатель[фамилия/text()]
let $orgs := doc($schools)/школы/школа
return 
    <слушатели количество="{count($memb)}">
    {for $a in $memb
    let $org := $orgs[поле[@имя='короткое']/data()=$a/организация/text()]
    return <memb>
              <mo>{$org/поле[@имя="мо"]/data()}</mo>
              <org>{$org/поле[@имя="короткое"]/data()}</org>
              <dir>{$org/поле[@имя="руководитель"]/data()}</dir>
              <memb>{string-join(($a/фамилия/text(), $a/имя/text(), $a/отчество/text()), ' ')}</memb>
              <pos>{$a/должность/text()}</pos>
              <номер></номер>
              <дата></дата>
              <срок></срок>
              <info>{string-join(($org/поле[@имя="адрес"]/data(), $org/поле[@имя="ИНН"]/data(), $org/поле[@имя="КПП"]/data()), ", ")}</info>
           </memb>}
    </слушатели>
};

сведения:форма('C:\Users\пользователь\Downloads\ИРО\data\КПК\', 'http://iro.od37.ru/dic/schools-mo.xml')