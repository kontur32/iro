module namespace docx = "docx.iroio.ru";
import module namespace data = 'data.iroio.ru' at 'data.xqm';
declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
  
(:функция возвращает строку таблицы Word, сформировнную из переданного узла:)
declare function docx:row ($row as node())
  {
      <w:tr w:rsidR="00512FB0" w:rsidTr="00512FB0">
        {
          for $a in $row/child::*
          return 
                <w:tc>
                <w:tcPr>
                  <w:tcW />
                </w:tcPr>
                <w:p w:rsidR="00512FB0" w:rsidRDefault="00512FB0">
                  <w:r>
                    <w:t>{$a/data()}</w:t>
                  </w:r>
                </w:p>
              </w:tc>
        }
     </w:tr>    
  };

(:возвращает в виде сериализованной строки таблицу документе Word, в которую начиная со второй строки
вставлены строки $tr:)
declare function docx:table-insert-rows ($doc as node(), (:шаблон в виде дерева:)
                                        $tr  ) (:строки для вставки в таблицу:) as xs:string
  { 
    copy $c := $doc
    modify insert node $tr after $c//w:tbl/w:tr[ 1 ]      
    return serialize($c)
  };
  
declare function docx:table-insert-rows-last ($doc as node(), (:шаблон в виде дерева:)
                                        $tr  ) (:строки для вставки в таблицу:) as xs:string
  { 
    copy $c := $doc
    modify insert node $tr after $c//w:tbl/w:tr[ last() ]      
    return serialize($c)
  };  

declare function docx:prop ()
    {
     let $prop := <w:tblPr>
                    <w:tblStyle w:val="a3"/>
                    <w:tblpPr w:leftFromText="180" w:rightFromText="180" w:vertAnchor="text" w:horzAnchor="margin" w:tblpY="145"/>
                    <w:tblW w:w="0" w:type="auto"/>
                    <w:tblLook w:val="04A0"/>
                  </w:tblPr>
     
     return $prop  
    };
declare function docx:grid ()
  {
    let $grid :=  <w:tblGrid>
                      <w:gridCol w:w="3190"/>
                      <w:gridCol w:w="3190"/>
                      <w:gridCol w:w="3191"/>
                    </w:tblGrid>
    return $grid                        
  };
  
declare function docx:заполнить ($данные, $документ)
{
  let $новый := 
            copy $doc := $документ
            modify 
            for $p in $doc//w:p
              for $r in $p/w:r
                for $fld in $r/w:instrText
                return
                  replace node $fld with <w:t>{if ($данные/child::*[lower-case(@имя/data()) =lower-case($fld/text())])
                                               then ($данные/child::*[lower-case(@имя/data())=lower-case($fld/text())]/text())
                                               else ('{{ЗНАЧЕНИЕ ПОЛЯ НЕ НАЙДЕНО}}')}</w:t>
     
            return $doc update delete node .//w:r[w:fldChar]
  return $новый
};

declare function docx:обработать-шаблон($данные, $путь-шаблон)
  {
    let $шаблон :=   data:get-binary($путь-шаблон)
    let $документ := parse-xml (archive:extract-text($шаблон,  'word/document.xml')) 
    return 
          archive:update($шаблон, "word/document.xml", serialize( docx:заполнить($данные, $документ) ))
  };

declare function docx:шаблон-в-один($данные, $путь-шаблон)
  {
    let $шаблон :=   data:get-binary($путь-шаблон)
    let $документ := parse-xml (archive:extract-text($шаблон,  'word/document.xml'))
    let $поля := 
          for $i in $данные
          return 
              docx:заполнить($i, $документ)//w:p
    let $итог := $документ update insert node $поля before .//w:body/w:p[1] 
    return 
          archive:update($шаблон, "word/document.xml", serialize($итог))
  };