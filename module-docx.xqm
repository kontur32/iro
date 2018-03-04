module namespace docx = "docx.iroio.ru";
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
    modify insert node $tr after $c//w:tbl/w:tr[1]      
    return fn:serialize($c)
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
  
 (: --- обработка шаблонов --- :)
declare function docx:вставить-таблицу ($template, $data)
{  
  let $doc := parse-xml (archive:extract-text($template,  'word/document.xml')) 
  let $rows := for $row in $data/child::*
                return docx:row($row)
 let $table := docx:table-insert-rows ($doc, $rows)
  return  archive:update ($template, 'word/document.xml',  $table)
};