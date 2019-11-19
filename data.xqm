(:~ 
 : Модуль является частью проекта iro
 : содержит функции функции для доступа к данным
 :
 : @author   iro/ssm
 : @see      https://github.com/kontur32/iro/blob/dev2/README.md
 : @version  0.1
 :)

module namespace data = 'data.iroio.ru';
import module namespace config = 'config.iroio.ru' at 'config.xqm';

declare function data:get-xml ($res_path) {
  if ( try {file:exists($res_path)} catch * {} ) 
  then ( try {doc($res_path)} catch * {'локальный файл ' || $res_path || ' не доступен'}) 
  else ( try {fetch:xml(escape-html-uri($res_path))} catch * {'ресурс ' || $res_path  || ' с ошибкой'} )
};

declare function data:get-binary ($res_path) {
  if ( try {file:exists($res_path)} catch * {} ) 
  then ( try {file:read-binary($res_path)} catch * {'локальный файл ' || $res_path || ' не доступен'}) 
  else ( try {fetch:binary( escape-html-uri($res_path))} catch * {'ресурс ' || $res_path  || ' с ошибкой'} )
};