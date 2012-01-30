unit uMainDM;

interface

uses
  SysUtils, Classes, IB_Components, IB_Access;

type
  TMainDM = class(TDataModule)
    IBC: TIB_Connection;
    DrugQ: TIB_Query;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainDM: TMainDM;

implementation

{$R *.dfm}

end.
