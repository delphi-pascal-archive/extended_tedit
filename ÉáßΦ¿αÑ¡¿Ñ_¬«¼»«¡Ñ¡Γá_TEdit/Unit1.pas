unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ThStd;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    GroupBox1: TGroupBox;
    CBFormated: TCheckBox;
    CBNulvisible: TCheckBox;
    Button1: TButton;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;
  EditStr1: TEditStr;
  EditNum1: TEditNum;
  EditDate1: TEditDate;
  EditMax: TEditNum;
  EditMin: TEditNum;
  EditNbDec: TEditNum;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  with EditNum1 do
  begin
    MinValue:= EditMin.Value;
    MaxValue:= EditMax.Value;
    NbDec:= EditNbDec.IntValue;
    NulVisible:= CBNulVisible.Checked;
    Formated:= CBFormated.Checked;
    Value:= Value;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  EditStr1:= TEditStr.Create(Self);
  with EditStr1 do
  begin
    Parent:= Form1;
    Left:= 80;
    Top:= 8;
    Width:= 145;
    Text:= '';
    AllowedChars:= ['A'..'Z', 'a'..'z'];
    ColorOnEnter:= $00D5FFFF;
  end;
  EditNum1:= TEditNum.Create(Self);
  with EditNum1 do
  begin
    Parent:= Form1;
    Left:= 80;
    Top:= 40;
    Width:= 145;
    Alignment:= taRightJustify;
    ColorOnEnter:= $00D5FFFF;
  end;
  EditDate1:= TEditDate.Create(Self);
  with EditDate1 do
  begin
    Parent:= Form1;
    Left:= 80;
    Top:= 72;
    Width:= 145;
    Alignment:= taCenter;
    ColorOnEnter:= $00D5FFFF;
  end;
  EditNbDec:= TEditNum.Create(Self);
  with EditNbDec do
  begin
    Parent:= GroupBox1;
    Left:= 88;
    Top:= 80;
    Width:= 97;
    MaxValue:= 16;
  end;
  EditMax:= TEditNum.Create(Self);
  with EditMax do
  begin
    Parent:= GroupBox1;
    Left:= 80;
    Top:= 112;
    Width:= 105;
    NbDec:= 2;
  end;
  EditMin:= TEditNum.Create(Self);
  with EditMin do
  begin
    Parent:= GroupBox1;
    Left:= 72;
    Top:= 144;
    Width:= 113;
    NbDec:= 2;
  end;
end;

end.
