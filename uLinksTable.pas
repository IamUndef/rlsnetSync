unit uLinksTable;

interface

uses Classes, MSHTML;

type
  TLinksTable = class( TObject )
    private
      Index_ : Integer;
      Links_ : TStringList;

      procedure Parse( HtmlBody : IHTMLElement; TableClass : String );
      function GetCount() : Integer;
      function GetText() : String;
      function GetTextOfIndex( Index : Integer ) : String;
      function GetUrl( Address : String ) : String;

    public
      constructor Create( HtmlBody : IHTMLElement; TableClass : String );
      destructor Destroy(); override;

      function Next() : Boolean;

      property Count : Integer read GetCount;
      property Index : Integer read Index_;
      property Text : String read GetText;
      property TextOfIndex[ Index : Integer ] : String read GetTextOfIndex;
      property Url[ Address : String ] : String read GetUrl;

  end;

implementation

uses SysUtils, StrUtils, Variants;

constructor TLinksTable.Create( HtmlBody: IHTMLElement; TableClass: String );
begin
  inherited Create();
  Index_ := 0;
  Links_ := TStringList.Create();
  Parse( HtmlBody, TableClass );
end;

destructor TLinksTable.Destroy();
begin
  if Assigned( Links_ ) then
    Links_.Free();
  inherited Destroy();
end;

procedure TLinksTable.Parse( HtmlBody : IHTMLElement; TableClass : String );
const
  TABLE_TAG = 'table';
  LINK_TAG = 'a';
  LINK_HREF = 'href';
var
  i, j : Integer;
  Tables : IHTMLElementCollection;
  Links : IHTMLElementCollection;
  Table : IHTMLElement;
  Link : IHTMLElement;
begin
  if not Assigned( HtmlBody ) then
    raise Exception.Create( 'Неверное значение параметра!' )
  else
  begin
    Tables := ( ( HtmlBody.all as IHTMLElementCollection ).tags( TABLE_TAG ) )
      as IHTMLElementCollection;
    for i := 0 to Tables.length - 1 do
    begin
      Table := Tables.item( i, NULL ) as IHTMLElement;
      if ( Table.className = TableClass ) then
      begin
        Links := ( ( Table.all as IHTMLElementCollection ).tags( LINK_TAG ) )
          as IHTMLElementCollection;
        if ( Links.length <> 0 ) then
        begin
          for j := 0 to Links.length - 1 do
          begin
            Link := Links.item( j, NULL ) as IHTMLElement;
            if ( ( Trim( Link.innerText ) <> '' ) and
                ( Trim( Link.getAttribute( LINK_HREF, 0 ) ) <> '' ) ) then
            begin
              Links_.Add( Link.innerText );
              Links_.Add( Link.getAttribute( LINK_HREF, 0 ) );
            end;
          end
        end;
        Break;
      end;
    end;
  end;
end;

function TLinksTable.Next() : Boolean;
begin
  Result := true;
  if ( ( Index_ + 1 ) < Count ) then
    Inc( Index_ )
  else
    Result := false;
end;

function TLinksTable.GetCount() : Integer;
begin
  Result := Links_.Count div 2;
end;

function TLinksTable.GetText() : String;
begin
  Result := Links_[2*Index_]
end;

function TLinksTable.GetTextOfIndex( Index: Integer ) : string;
begin
  if ( ( Index >= 0 ) and ( Index < Count ) ) then
    Result := Links_[2*Index]
  else
    raise Exception.Create( 'Неверное значение индекса!' );
end;

function TLinksTable.GetUrl( Address : String ) : String;
const
  ABOUT_STR = 'about:/';
begin
  Result := Links_[2*Index_ + 1];
  if ( Pos( ABOUT_STR, Result ) <> 0 ) then
    Result := ReplaceStr( Result, ABOUT_STR, Address );
end;

end.
