object MainDM: TMainDM
  OldCreateOrder = False
  Height = 150
  Width = 215
  object IBC: TIB_Connection
    SQLDialect = 3
    Params.Strings = (
      'SQL DIALECT=3'
      'PATH=d:\db\UDC.FDB'
      'USER NAME=SYSDBA'
      'FORCED WRITES=TRUE'
      'RESERVE PAGE SPACE=TRUE'
      'CHARACTER SET=WIN1251')
    Left = 24
    Top = 24
  end
  object DrugQ: TIB_Query
    DatabaseName = 'd:\db\UDC.FDB'
    IB_Connection = IBC
    SQL.Strings = (
      'SELECT *'
      'FROM URC$LS'
      'WHERE URC$LS.LSNAME = UPPER( :LSNAME ) ')
    DeleteSQL.Strings = (
      '')
    InsertSQL.Strings = (
      'INSERT INTO URC$LS('
      '   URC$LSID, /*PK*/'
      '   LSNAME,'
      '   LSLATINNAME,'
      '   RELEASEFORM,'
      '   DOZ,'
      '   RC$DOZID,'
      '   WHATFORM )'
      'VALUES ('
      '   NULL,'
      '   UPPER( :LSNAME ),'
      '   :LSLATINNAME,'
      '   '#39#39','
      '   '#39#39','
      '   0,'
      '   0 )')
    Left = 72
    Top = 24
    ParamValues = (
      'LSNAME=')
  end
end
