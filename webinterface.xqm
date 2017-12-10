module namespace html='html.iroio.ru';
import module namespace config = 'config.iroio.ru' at 'config.xqm';
import module namespace functx = "http://www.functx.com";

declare variable $html:local := $config:local;
declare variable $html:main := $config:main;
declare variable $html:user_path := $html:local//root/text() || '\' || $html:local//localuser/@alias/data() || '\';
declare variable $html:base_url := $config:local//base_url;
declare variable $html:module_url := $config:local//web_url;

declare
  %rest:path("иро/web")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function html:главная()
  as element()
{
  let $config := $config:main
  let $user_exist := file:exists($html:user_path)
  return 
  <html>
  <p><i>{$html:local//moto/text()}</i></p>
  <table>
    <tr>
      <td>Пользователь:</td>
      <td><b>{$html:local//localuser/name/text()}</b></td>
    </tr>
    <tr>
      <td>Корень:</td>
      <td><b>{$html:local//root/text()}</b></td>
    </tr>
    <tr>
      <td>Папка пользвателя:</td>
      <td>{if ($user_exist) then (<b>{$html:local//localuser/@alias/data()} </b>) else ('не создана')}<a href = "{$html:module_url || '/админ/создать'}">  (проверить и создать)</a></td>
    </tr>
  </table>
  <p>Разделы:</p>
  {
    if ($user_exist)
    then
    (
    <ul>
      {
        for $a in file:list($html:local//root/text() || $html:local//localuser/@alias/data() || '\', false())[ends-with(., '\')]
          return 
            <li>
                {<a href = "{$html:module_url || '/' || $a}">{$a}</a>}
            </li>
       }
    </ul>
  )
  else (<p>разделы не созданы</p>)
  }
  </html>
};

declare
  %rest:path("иро/web/{$part}")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function html:раздел($part)
  as element()
{
  <html>
      <p><i>{$html:local//moto/text()}</i></p>
      <p>Пользователь: <a href = "{ $html:module_url}"> {$html:local//localuser/name/text()}</a></p>
      <p>Это данные раздела <b>{$part}</b></p>
      <p>Путь: {$html:local//root/text() || $html:local//localuser/@alias/data()|| '\' || $part || '\'}</p>
      <p>Данные:</p>
      <lu>
        {
        for $a in file:list($html:local//root/text()|| $html:local//localuser/@alias/data()|| '\' || $part || '\', false())[ends-with(., '\')]
        return 
            <li>
                {<a href = "{$a}">{$a}</a>}
            </li>
         }
       </lu> 
  </html>
};

declare
  %rest:path("иро/web/{$part}/{$data}")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function html:данные-раздела($part, $data)
  as element()
{
  <html>
      <p><i>{$html:local//moto/text()}</i></p>
      <table>
      <tr>
        <td>Пользователь:</td>
        <td><a href = "{ $html:module_url}"> {$html:local//localuser/name/text()}</a></td>
       </tr>
      <tr>
        <td>Раздел:</td>
        <td><a href = "{ $html:module_url || '/' || $part || '/'}"><b>{$part}</b></a></td>
       </tr>
      <tr>
        <td>Данные из:</td>
        <td><b>{$data}</b></td>
       </tr>
      <tr>
        <td>Путь:</td>
        <td><b>{$html:local//root/text() ||$html:local//localuser/@alias/data()|| '\' || $part || '\' || $data || '\'}</b></td>
      </tr>
      </table>
      <table>
          <tr>
            <th>Форма</th>
            <th>Ссылка</th>
          </tr>
      {
        for $a in $html:main//parts/part[@alias/data()=$part]
        return 
            for $b in $a//form
            return
              <tr> 
                <td>{functx:if-empty($b/alias/text(), $b/name/text())}</td>
                <td>
                    <a href = "{ $html:base_url || '/' || $part || '/' || $b/name/text() || '?курс=' || $html:local//root/text() || $html:local//localuser/@alias/data()|| '\' || $part || '\' || $data || '\' || $b/params/text()}">XML</a>
                    <a href = "{ $html:base_url || '/выгрузка/' || $b/name/text() || '?курс=' || $html:local//root/text() || $html:local//localuser/@alias/data()|| '\' || $part || '\' || $data || '\' || $b/params/text()}">Сохранить</a>
                </td>
              </tr>
      }
       </table>   
       
  </html>
};

declare
  %rest:path("иро/web/админ/создать")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function html:создать-пользователя()
  as element()
{
  <html>
  {
    for $a in $html:local//localuser/usertype/text()
    return
        for $b in $html:main//usertypes/usertype[@alias= $a]
        return 
            for $c in $b/part
            return 
                file:create-dir($html:user_path || $c/text())
  }  
    <p>Проверяем наличие необходимых папок пользователя {$html:local//localuser/name/text()} ...</p>
    <p>... и при необходимости создаем</p>
    <a href = "{ $html:module_url}">вернуться на главную ... </a>
  </html>
};
