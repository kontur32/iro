 module namespace update = "update.iroio.ru";

declare
  %rest:path("иро/web/update/check")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function update:check()
{

    let $base-dir := file:base-dir()
    let $pull := $base-dir || '../bat/git-pull.bat'
    let $rev-parse := $base-dir || '../bat/git-rev-parse.bat'
    
    return
        if (proc:execute($rev-parse, 'dev2')//output =  proc:execute($rev-parse, 'origin/dev2')//output)
        then (
          '1'
        )
        else (
          '0'
        )
};

declare
  %rest:path("иро/web/update/make")
  %output:method("html")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function update:make()
{
    let $base-dir := file:base-dir()
    let $pull := $base-dir || '../bat/git-pull.bat'
    return 
      proc:fork( $pull, ('--progress', '-v', '--no-rebase "origin"')), 
      <p>Обновление прошло успешно. <a href = "http://localhost:8984/иро/web/">Вернуться назад</a></p>
        
};