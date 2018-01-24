(:~ 
 : Модуль является частью проекта iro
 : содержит функции получения данных о конфигурации
 :
 : @author   iro/ssm
 : @see      https://github.com/kontur32/iro/blob/dev2/README.md
 : @version  0.1
 :)

module namespace config = 'config.iroio.ru';

declare variable $config:main := doc('config.xml');
declare variable $config:local := doc('config_local.xml');

declare function config:get-dic-path ($dic_name)
{
  if (
    $config:local//dictionary[name/text()=$dic_name]/location/text()
  ) 
  then (
    $config:local//dictionary[name/text()=$dic_name]/location/text()
  )
  else (
    iri-to-uri($config:main//dictionary[name/text()=$dic_name]/location/text())
  )
};