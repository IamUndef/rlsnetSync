unit uLatinName;

interface

uses MSHTML;

type
  TLatinName = class( TObject )
    public
      class function Get( HtmlBody : IHTMLElement ) : String ;
      
  end;

implementation

uses SysUtils, Variants;

class function TLatinName.Get( HtmlBody : IHTMLElement ) : String;
const
  SECTION_TAG = 'div';
  SECTION_CLASS = 'news_date full';
  SECTION_TEXT = 'Латинское название препарата';
var
  i : Integer;
  Sections : IHTMLElementCollection;
  Section : IHTMLElement;
begin
  Result := '';
  if not Assigned( HtmlBody ) then
    raise Exception.Create( 'Неверное значение параметра!' )
  else
  begin
    Sections := ( ( HtmlBody.all as IHTMLElementCollection ).tags( SECTION_TAG ) )
      as IHTMLElementCollection;
    for i := 0 to Sections.length - 1 do
    begin
      Section := Sections.item( i, NULL ) as IHTMLElement;
      if ( ( Section.className = SECTION_CLASS ) and
          ( Pos( SECTION_TEXT, Section.innerText ) <> 0 ) ) then
      begin
        Section := Sections.item( i + 1, NULL ) as IHTMLElement;
        if ( Assigned( Section ) and ( Trim( Section.innerText ) <> '' ) ) then
          Result := Section.innerText;
        Break;
      end;
    end;
  end;
end;

end.
