unit uCatalogProcess;

interface

uses Classes;

type
  TCatalogProcess  = class( TThread )
    public
      type
        TWriteEvent = procedure ( Sender : TObject; Data : TStringList;
          var WriteCount : Integer ) of object;
        TLoggingEvent = procedure ( Sender : TObject; TotalCount : Integer;
          LatinCount : Integer; WriteCount : Integer ) of object;

      const
        RSLNET_URL = 'http://www.rlsnet.ru/';

    private
      Url_ : String;
      Data : TStringList;
      TotalCount_ : Integer;
      LatinCount_ : Integer;
      WriteCount_ : Integer;
      Tag_ : Integer;
      OnWrite_ : TWriteEvent;
      OnLogging_ : TLoggingEvent;

      procedure Write();
      procedure Logging();

    public
      constructor Create( Url : String );
      destructor Destroy(); override;

      procedure Execute(); override;

      property Tag : Integer read Tag_ write Tag_;
      property OnWrite : TWriteEvent read OnWrite_ write OnWrite_; 
      property OnLogging : TLoggingEvent read OnLogging_ write OnLogging_;

  end;

implementation

uses SysUtils, ActiveX, uLinksTable, uDownloader, uLatinName;

constructor TCatalogProcess.Create( Url : String );
begin
  if ( Url = '' ) then
    raise Exception.Create( 'Неверное значение параметра!' );
  inherited Create( true );
  Url_ := Url;
  Data := TStringList.Create();
end;

destructor TCatalogProcess.Destroy();
begin
  inherited Destroy();
  if Assigned( Data ) then
    Data.Free();
end;

procedure TCatalogProcess.Execute();
var
  SubCatalog : TLinksTable;
  Titles : TLinksTable;
  LatinName : String;

begin
  CoInitialize( NIL );
  SubCatalog := NIL;
  Titles := NIL;
  try
    SubCatalog :=  TLinksTable.Create( TDownloader.Get( Url_ ).body,
      'look_pods mini' );
    if ( SubCatalog.Count = 0 ) then
      raise Exception.Create(
        'Для подкаталога получены некорректные данные!' );
    repeat
      try
          if Terminated then
            Exit;
          Titles := TLinksTable.Create(
            TDownloader.Get( SubCatalog.Url[RSLNET_URL] ).body, 'rest_nest' );
          if ( Titles.Count = 0 ) then
            raise Exception.Create(
              'Для заголовков получены некорректные данные!' );
        repeat
          try
            if Terminated then
              Exit;
            Inc( TotalCount_ );
            LatinName := TLatinName.Get(
              TDownloader.Get( Titles.Url[RSLNET_URL] ).body );
            if ( LatinName <> '' ) then
            begin
              Inc( LatinCount_ );
              Data.Add( Titles.Text );
              Data.Add( LatinName );
            end;
          except
            if Assigned( OnWrite ) then
              Synchronize( Write );
            if Assigned( OnLogging ) then
              Synchronize( Logging );
            raise;
          end;
        until not Titles.Next();
      finally
        if Assigned( Titles ) then
          FreeAndNil( Titles );
      end;
      if Assigned( OnWrite ) then
        Synchronize( Write );
      if Assigned( OnLogging ) then
        Synchronize( Logging );
    until not SubCatalog.Next();
  finally
    if Assigned( SubCatalog ) then
      SubCatalog.Free();
  end;
end;

procedure TCatalogProcess.Write();
begin
  try
    OnWrite_( TObject( Self ), Data, WriteCount_ );
  finally
    Data.Clear();
  end;
end;

procedure TCatalogProcess.Logging();
begin
  try
    OnLogging_( TObject( Self ), TotalCount_, LatinCount_, WriteCount_ );
  finally
    TotalCount_ := 0;
    LatinCount_ := 0;
    WriteCount_ := 0;
  end;
end;

end.
