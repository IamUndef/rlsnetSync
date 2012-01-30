unit uDownloader;

interface

uses MSHTML;

type
  TDownloader = class( TObject )
    private
      const
        MESSAGE_GET_ERROR = 'Не удалось получить данные!';

    private
      class function Download( Url : String ) : String;

    public
      class function Get( Url : String ) : IHTMLDocument2;

  end;

implementation

uses WinInet, Classes, SysUtils, ActiveX, Variants;

class function TDownloader.Get( Url : String ) : IHTMLDocument2;
var
  Context : OleVariant;
begin
  Result := NIL;
  Context := VarArrayCreate( [0, 0], varVariant );
  Context[0] := Download( Url );
  Result := CoHTMLDocument.Create() as IHTMLDocument2;
  Result.designMode := 'On';
  Result.write( PSafeArray( TVarData( Context ).VArray ) );
  Result.close();
  if not Assigned( Result.body ) then
    raise Exception.Create( MESSAGE_GET_ERROR )
end;

class function TDownloader.Download( Url : String ) : String;
const
  ATTEMPTS_COUNT = 10;
var
  Session : HINTERNET;
  OpenedUrl : HINTERNET;
  Stream : TMemoryStream;
  ReadBuf : array [1..4096] of Byte;
  BytesRead : Cardinal;

  Attempts : Integer;
begin
  Result := '';
  Attempts := 0;
  while true do
  try
    Session := NIL;
    OpenedUrl := NIL;
    Stream := NIL;
    try
      Session := InternetOpen( 'Unknown', INTERNET_OPEN_TYPE_PRECONFIG, NIL,
        NIL, 0 );
      if not Assigned( Session ) then
        raise Exception.Create( MESSAGE_GET_ERROR );
      OpenedUrl := InternetOpenUrl( Session, PAnsiChar( Url ), NIL, 0,
        INTERNET_FLAG_RELOAD, 0 );
      if not Assigned( OpenedUrl ) then
        raise Exception.Create( MESSAGE_GET_ERROR );
      Stream := TMemoryStream.Create();
      while ( InternetReadFile( OpenedUrl, @ReadBuf, SizeOf( ReadBuf ),
          BytesRead ) and ( BytesRead <> 0 ) ) do
        Stream.Write( ReadBuf, BytesRead );
      if ( Stream.Size = 0 ) then
        raise Exception.Create( MESSAGE_GET_ERROR )
      else
      begin
        Stream.Position := 0;
        SetString( Result, PChar( Stream.Memory ), Stream.Size );
      end;
      Break;
    except
      Inc( Attempts );
      if ( Attempts = ATTEMPTS_COUNT ) then
        raise;
    end;
  finally
    if Assigned( OpenedUrl ) then
      InternetCloseHandle( OpenedUrl );
    if Assigned( Session ) then
      InternetCloseHandle( Session );
    if Assigned( Stream ) then
      Stream.Free();
  end;
end;


end.
