module namespace docx = "docx.iroio.ru";
declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

(:возвращает содержимое документа Word в виде дерева:)
declare function docx:get-xml ($docx_name as xs:string) as node ()
  {
    fn:parse-xml(archive:extract-text(file:read-binary($docx_name),'word/document.xml'))
  };
  
(:функция возвращает строку таблицы Word, сформировнную из переданного узла:)
declare function docx:row ($row)
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