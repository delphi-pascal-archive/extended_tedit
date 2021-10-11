unit ThStd;

{ auteur : ThWilliam }

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Graphics, Windows, Messages,
  Dialogs, Math, Forms, Clipbrd;

type
  TBEOption = (eoEnterasTab, eoContextMenu, eoAllowPaste);
  TBEOptions = set of TBEOption;
  TBESetChar = set of Char;

  TBasicEdit = class(TCustomEdit)
  private
    FAlignment: TAlignment;
    FAlignmentStill: TAlignment;
    FColorOnEnter: TColor;
    FColorStill: TColor;
    FOptions: TBEOptions;
    procedure SetAlignment(AValue: TAlignment);
  protected
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property ColorOnEnter: TColor read FColorOnEnter write FColorOnEnter;
    property Options: TBEOptions read FOptions write FOptions;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BorderStyle;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Readonly;
    property ShowHint;
    property TabOrder;
    property Visible;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
	 property OnExit;
	 property OnKeyDown;
	 property OnKeyPress;
	 property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TEditStr = class(TBasicEdit)
  private
    FAllowedChars: TBESetChar;
  protected
    procedure KeyPress(var Key: Char); override;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
  public
    constructor Create(AOwner: TComponent); override;
    property AllowedChars: TBESetChar read FAllowedChars write FAllowedChars;
  published
    property CharCase;
    property MaxLength;
    property OEMConvert;
    property PassWordChar;
    property Text;
  end;

  TEditNum = class(TBasicEdit)
  private
    FNbDec: byte;
    FFormated: boolean;
    FNulVisible: boolean;
    FMaxValue: double;
    FMinValue: double;
    FError: integer;
    function GetValue: double;
    procedure SetValue(AValue: double);
    procedure SetTextValue(AValue: double);
    function IsMinMaxFixed: boolean;
    function Clean(S: string): string;
    function SetValueInRange(AValue: double): double;
    procedure SetFormated(AValue: boolean);
    procedure SetNbDec(AValue: byte);
    procedure SetNulVisible(AValue: boolean);
  protected
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
  public
    constructor Create(AOwner: TComponent); override;
    function IntValue: integer;
    function Int64Value: int64;
    property Error: integer read FError;
  published
    property Formated: boolean read FFormated write SetFormated default false;
    property MinValue: double read FMinValue write FMinValue;
    property MaxValue: double read FMaxValue write FMaxValue;
    property NbDec: byte read FNbDec write SetNbDec default 0;
    property NulVisible: boolean read FNulVisible write SetNulVisible default true;
    property Value: double read GetValue write SetValue;
    property MaxLength;

  end;

  TEditDate = class(TBasicEdit)
  private
    FDateFormat: string;
    FCanBeEmpty: boolean;
    FirstSeparator, SecondSeparator: integer;
    FError: integer;
    procedure PosSeparators;
    function GetPos: integer;
    procedure SetPos(P:integer);
    function GetValue: TDateTime;
    procedure SetValue(AValue: TDateTime);
    procedure SetTextValue(AValue: TDateTime);
  protected
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseUp(Button:TmouseButton;Shift:TShiftState;X,Y:Integer); override;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
  public
    constructor Create(AOwner: TComponent); override;
    property Value: TDateTime read GetValue write SetValue;
    property Error: integer read FError;
    function OkValue: boolean;
  published
    property CanBeEmpty: boolean read FCanBeEmpty write FCanBeEmpty default true;
  end;


procedure Register;


implementation

const
  ERR_NOERROR = 0;
  ERR_NUMERIC = 1;
  ERR_NUMOUTRANGE = 2;
  ERR_DATE = 3;
  DEFAULTDATE = -693593.0; // "01/01/0001"

procedure Register;
begin
  RegisterComponents('ThStandard', [TEditStr, TEditNum, TEditDate]);
end;

procedure ErrorMessage(Msg: string);
begin
  MessageBeep(1);
  MessageDlg(Msg, mtError, [mbOk], 0);
end;


{ ***********************************************************************
                               TBASICEDIT

   propriété Alignment : alignement horizontal du texte lorsque le Edit
                            n'est pas en mode édition.
   propriété ColorOnEnter : couleur du fond en entrée focus.

   propriété Options :
      eoEnterasTab : la touche Enter provoque le passage au compo suivant.
      eoContextMenu : rend accessible ou non le menu contextuel par défaut.
      eoAllowPaste : autorise ou non le 'coller'.

  *********************************************************************** }

constructor TBasicEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColorOnEnter:= Color;
  FColorStill:= Color;
  FAlignment:= taLeftJustify;
  FAlignmentStill:= taLeftJustify;
  FOptions:= [eoContextMenu, eoAllowPaste];
end;

procedure TBasicEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  SetAlignment(FAlignmentstill);
  if Color <> FColorStill then Color:= FColorStill;
  inherited;
end;

procedure TBasicEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  FAlignmentStill := FAlignment;
  FColorStill:= Color;
  SetAlignment(taLeftJustify);
  if Color <> FColorOnEnter then Color:= FColorOnEnter;
  inherited;
end;

procedure TBasicEdit.WMChar(var Message: TWMChar);
begin
  if (Message.CharCode = VK_RETURN) and (eoEnterasTab in FOptions) then
  begin
    Message.CharCode:= 0;
    PostMessage(Parent.Handle, WM_NEXTDLGCTL, 0, 0);
  end
  else
    inherited;
end;

procedure TBasicEdit.WMContextMenu(var Message: TWMContextMenu);
begin
  if eoContextMenu in FOptions then inherited;
end;

procedure TBasicEdit.SetAlignment(AValue: TAlignment);
begin
  if AValue <> FAlignment then
  begin
    FAlignment:= AValue;
    Invalidate;
  end;
end;

procedure TBasicEdit.WMPaint(var Message: TWMPaint);
// Procédure adaptée de DBEdit
var
  R: TRect;
  PS: TPaintStruct;
  Canevas: TControlCanvas;
begin
  if FAlignment = taLeftJustify then
  begin
    inherited;
    Exit;
  end;
  {alignement centré ou à droite}
  Canevas := TControlCanvas.Create;
  try
    Canevas.Control := Self;
    if Message.DC = 0 then BeginPaint(Handle, PS);
    Canevas.Font := Font;
    with Canevas do
    begin
      R := ClientRect;
      if (BorderStyle = bssingle) and (not Ctl3D) then
      begin
        Brush.Color := clWindowFrame;
        FrameRect(R);
        InflateRect(R, -1, -1);
      end;
      Brush.Color := Color;
      Canevas.FillRect(R);
      case FAlignment of
        taCenter: DrawText(handle, PChar(Text), -1, R, DT_SINGLELINE or
                             DT_CENTER or DT_VCENTER);
        taRightJustify: begin
                          R.Right:= R.Right - 2;
                          DrawText(handle, PChar(Text), -1, R, DT_SINGLELINE or
                             DT_RIGHT or DT_VCENTER);
                        end;
      end;
    end;
  finally
    if Message.DC = 0 then EndPaint(Handle, PS);
    Canevas.Free;
  end;
end;


{ ***********************************************************************
                               TEDITSTR

  propriété AllowedChars = permet de définir un ensemble de caractères
     autorisés : ex : AllowedChars:= ['A'..'Z', 'a'..'z'];
     lors d'un coller, seuls les caractères autorisés sont repris.

  *********************************************************************** }

constructor TEditStr.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAllowedChars:= [];
end;

procedure TEditStr.KeyPress(var Key: Char);
begin
  if (Key > #31) and (not(FAllowedChars= []))
    and (not(Key in FAllowedChars)) then
  begin
    Key:= #0;
    MessageBeep(1);
  end;
  inherited;
end;

procedure TEditStr.WMPaste(var Message: TWMPaste);
var
  S: string;
  I: integer;
begin
  if (eoAllowPaste in FOptions) and (Clipboard.HasFormat(CF_TEXT)) then
  begin
     if FAllowedChars = [] then inherited
     else
     begin
        S:= ClipBoard.AsText;
        I:= 1;
        while I <= Length(S) do
        begin
           if not (S[I] in FAllowedChars) then
             Delete(S,I,1)
           else Inc(I);
        end;
        SelText:= S;
     end;
  end;
end;


{ ***********************************************************************
                               TEDITNUM

   Saisie de valeurs numériques entières ou réelles (double)

   propriété NbDec : nombre de décimales; la valeur sera arrondie en
                     fonction de ce nombre.
   propriétés MinValue et MaxValue : permet d'assigner une fourchette
      de valeurs admissibles. Laisser les 2 à zéro pour ne pas déterminer
      de fourchette.
   propriété Formated : true = affichage avec séparateurs de milliers et
      nombre de décimales, quand le composant n'est pas en mode édition.
   propriété NulVisible : true = la valeur 0 est affichée.

   propriété Value : permet de lire ou de fixer la valeur numérique. Eviter
      d'utiliser la propriété Text(non publiée).
      SetValue : assigne une valeur de type double avec contrôle de
                   fourchette éventuelle.
      GetValue : renvoie la conversion de Text en valeur double.
           Contrôle de validité valeur numérique : si Text ne représente
             pas un nombre correct, GetValue renvoie 0 ou la valeur
             minimale fixée dans MinValue.
           Contrôle de la fourchette : si la valeur est > MaxValue,
             GetValue renvoie MaxValue; si la valeur est < MinValue,
             GetValue renvoie MinValue;
           Aucune exception n'est déclenchée dans GetValue.
           Les messages d'erreur ne sont affichés qu'à l'Exit du
           composant.

   function IntValue : renvoie la valeur comme integer.
       Idem que de faire : X:= Round(Editnum.Value);
       Aucun contrôle n'est fait en cas de dépassement de limite.
   function Int64Value : renvoie la valeur comme int64.

   La touche flèche haut incrémente la valeur de 1 (si nbdec = 0), de 0,1
     (si nbdec = 1), de 0,01 si...
   La touche flèche bas décrémente la valeur de la même manière.

  *********************************************************************** }


constructor TEditNum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle:= ControlStyle - [csSetCaption];
  FNbDec:= 0;
  FFormated:= false;
  FNulVisible:= true;
  FMaxValue:= 0;
  FMinValue:= 0;
  Value:= 0;
  Ferror:= ERR_NOERROR;
end;

function TEditNum.GetValue: double;
var
  X, N: double;
begin
  FError:= ERR_NOERROR;
  try
    X:= 1/(Power(10, FNbDec+1)); // ceci permet d'arrondir plus exactement
    N:= RoundTo(StrToFloat(Clean(Text)) + X, - FNbDec);
    Result:= SetValueInRange(N);
    if Result <> N then FError:= ERR_NUMOUTRANGE;
  except
    Result:= SetValueInRange(0);
    FError:= ERR_NUMERIC;
  end;
end;

procedure TEditNum.SetValue(AValue: double);
begin
  SetTextValue(SetValueInRange(AValue));
end;

function TEditNum.Clean(S: string): string;
begin
  if S = '' then S:= '0'
  else
  while Pos(ThousandSeparator, S) > 0 do
    Delete(S, Pos(ThousandSeparator, S), 1);
  Result:= S;
end;

function TEditNum.IsMinMaxFixed: boolean;
begin
  Result:= ((FMinValue <> 0) or (FMaxValue <> 0));
end;

function TEditNum.SetValueInRange(AValue: double): double;
begin
  Result:= AValue;
  if IsMinMaxFixed and not(InRange(Result, FMinValue, FMaxValue)) then
  begin
    if Result < FMinValue then Result:= FMinValue
    else
    if Result > FMaxValue then Result:= FMaxValue;
  end;
end;

procedure TEditNum.SetTextValue(AValue: double);
var
  S: string;
begin
  if (AValue = 0) and (not FNulVisible) then
    S:= ''
  else
  if FFormated and (not Focused) then
    S:= FloatToStrF(AValue, ffNumber, 18, FNbDec)
  else
    S:= FloatToStr(AValue);
  if Text <> S then Text:= S;
end;

function TEditNum.IntValue: integer;
begin
   Result:= Round(GetValue);
end;

function TEditNum.Int64Value: int64;
begin
   Result:= Round(GetValue);
end;

procedure TEditNum.SetFormated(AValue: boolean);
begin
  if FFormated <> AValue then
  begin
    FFormated:= AValue;
    SetTextValue(GetValue);
  end;
end;

procedure TEditNum.SetNbDec(AValue: byte);
begin
  if FNbDec <> AValue then
  begin
    FNbDec:= AValue;
    SetTextValue(GetValue);
  end;
end;

procedure TEditNum.SetNulVisible(AValue: boolean);
begin
  if FNulVisible <> AValue then
  begin
    FNulVisible:= AValue;
    SetTextValue(GetValue);
  end;
end;

procedure TEditNum.WMPaste(var Message: TWMPaste);
begin
  if (eoAllowPaste in Options) and (Clipboard.HasFormat(CF_TEXT)) then
  try
    SetValue(StrToFloat(Clipboard.AsText));
  except
    MessageBeep(1);
  end;
end;

procedure TEditNum.DoEnter;
begin
   SetTextValue(GetValue);
   if AutoSelect then SelectAll;
end;

procedure TEditNum.DoExit;
var
  N: double;
begin
  N:= GetValue;
  if FError <> ERR_NOERROR then
  begin
    case Ferror of
      ERR_NUMERIC     : ErrorMessage('"' + Text +
                         '" n''est pas une valeur numérique correcte');
      ERR_NUMOUTRANGE : ErrorMessage('La valeur doit être comprise entre ' +
                         FloatToStr(FMinValue) + ' et ' + FloatToStr(FMaxValue));
    end;
    if CanFocus then SetFocus;
  end;
  SetTextValue(N);
end;

procedure TEditNum.KeyPress(var Key: Char);
begin
  case Key of
    '.', ',' : if (NbDec > 0)
                and ((Pos(DecimalSeparator, Text) = 0) or (Pos(DecimalSeparator, SelText) > 0)) then
                 Key:= DecimalSeparator
                else Key:= #0;
         '-' : if IsMinMaxFixed and (FMinValue >= 0) then
                 Key:= #0
               else
               if (SelStart > 0) or ((Pos('-', Text) > 0) and (Pos('-',SelText) = 0)) then
                 Key:= #0;
      else
      if Key > #31 then
         if not (Key in ['0'..'9']) then Key:=#0;
  end;
  inherited;
end;

procedure TEditNum.KeyDown(var Key: Word; Shift: TShiftState);
var
  N: double;
begin
  case Key of
      VK_UP : begin
                N:= GetValue + (1/(Power(10, FNbDec)));
                if ((not IsMinMaxFixed) or (N <= FMaxValue)) then
                begin
                  Text:= FloatToStr(N);
                  SelectAll;
                end;
                Key:= 0;
              end;
    VK_DOWN : begin
                N:= GetValue - (1/(Power(10, FNbDec)));
                if ((not IsMinMaxFixed) or (N >= FMinValue)) then
                begin
                  Text:= FloatToStr(N);
                  SelectAll;
                end;
                Key:= 0;
              end;
  end;
  inherited;
end;


{ ***********************************************************************
                               TEDITDATE

     propriété CanBeEmpty : true = l'edit peut rester vide.

     propriété Value : permet de lire ou de fixer la valeur date. Eviter
      d'utiliser la propriété Text(non publiée).
      GetValue : renvoie la conversion de Text en valeur TDateTime.
           Contrôle de validité valeur : si Text ne représente pas une
             date correcte, la valeur renvoyée est 01/01/0001.
           Aucune exception n'est déclenchée dans GetValue.
           Les messages d'erreur ne sont affichés qu'à l'Exit du
           composant.  

  *********************************************************************** }

constructor TEditDate.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle:= ControlStyle - [csSetCaption];
  FDateFormat:= 'dd/mm/yyyy';
  FCanBeEmpty:= true;
  AutoSelect:= false;
  MaxLength:= 10;
  Text:= '';
  Ferror:= ERR_NOERROR;
end;

function TEditDate.GetValue: TDateTime;
begin
  FError:= ERR_NOERROR;
  if FCanBeEmpty and (Text = '') then
    Result:= DEFAULTDATE
  else
    try
      Result:= StrToDate(Text);
    except
      Result:= DEFAULTDATE;
      FError:= ERR_DATE;
    end;
end;

procedure TEditDate.SetValue(AValue: TDateTime);
begin
  SetTextValue(AValue);
end;

procedure TEditDate.SetTextValue(AValue: TDateTime);
var
  S: string;
begin
  if AValue <= DEFAULTDATE then
    S:= ''
  else
    S:= FormatDateTime(FDateFormat, AValue);
  if Text <> S then Text:= S;
end;

function TEditDate.OkValue: boolean;
begin
  Result:= (GetValue > DEFAULTDATE);
end;

procedure TEditDate.DoEnter;
begin
  if AutoSelect = false then SetPos(1); // se place en zone jours
  inherited;
end;

procedure TEditDate.DoExit;
var
  D: TDateTime;
begin
     D:= GetValue;
     if FError <> ERR_NOERROR then
     begin
       ErrorMessage('"' + Text + '" n''est pas une date correcte');
       if CanFocus then SetFocus;
     end
     else
       SetTextValue(D);
  inherited;
end;

procedure TEditDate.KeyPress(var Key: Char);
var
  P: integer;
  D: TDateTime;
begin
  case Key of
    '0'..'9': begin
                 if (Text= '') or (SelLength = Length(Text)) then
                 begin
                    Text:= '  ' + DateSeparator + '  ' + DateSeparator + '  ';
                    P:= 1;
                    SetPos(1);
                 end
                 else
                    P:= GetPos;  // cherche la zone où se trouve le curseur
                 if (SelLength >= 1) and
                    (((P = 1) and (Key > '3')) or ((P = 2) and (Key > '1'))) then
                 begin
                    SelText:= '0' + Key;
                    SetPos(P+1);
                 end
                 else
                 begin
                    SelText:= Key;
                    P:= GetPos;  //on reactualise les separators
                    if (P = 1)    // on est en zone jours
                      and (FirstSeparator = 3) then SetPos(2) //on avance en zone mois
                    else if (P = 2)    // on est en zone mois
                      and ((SecondSeparator - FirstSeparator) = 3) then SetPos(3); //on avance en zone année
                 end;
              end;
    '+', '-': try   // augmente ou diminue la date de 1 jour
                 if Key = '+' then D:= StrToDate(Text) + 1
                       else D:= StrToDate(Text) - 1;
                 Text:= FormatDateTime(FDateFormat, D);
                 SelStart:= 0;
                 SelLength:= Length(Text);
              except
                 MessageBeep(1);
              end;
          #8: Key:= #0;
          ^X: Key:= #0;
        else if Key = DateSeparator then //on avance de zone
             SetPos(GetPos + 1);
  end;
  if Key > #31 then key:= #0;
  inherited;
end;

procedure TEditDate.KeyDown(var Key: Word; Shift: TShiftState);
var
  P,N: integer;
begin
  case Key of
    VK_DELETE : Text:= '';  // delete : efface tout
    VK_HOME : begin       // Home : on retourne en zone jour
                SetPos(1);
                Key:= 0;
              end;
    VK_END : begin      // End : on va en zone année
                SetPos(3);
                Key:= 0;
             end;
    VK_RIGHT : begin       // flèche droite: on avance de zone
                 SetPos(GetPos + 1);
                 Key:= 0;
               end;
    VK_BACK,VK_LEFT: begin      // flèche gauche ou backspace: recul de zone
                       SetPos(GetPos - 1);
                       Key:= 0;
                     end;
    VK_UP,VK_DOWN : //flèches haut et bas (augmente ou diminue la zone sélectionnée)
                    begin
                       P:= GetPos;
                       SetPos(P);
                       try
                          N:= StrToInt(SelText);
                       except
                          N:= 0;
                       end;
                       if Key = VK_UP then Inc(N) else Dec(N);
                       case P of
                          1: if N > 31 then N:= 1 else if N < 1 then N:= 31;
                          2: if N > 12 then N:= 1 else if N < 1 then N:= 12;
                          3: if N < 0 then N:= 0;
                       end;
                       if N <= 9 then SelText:= '0' + IntToStr(N)
                           else SelText:= IntToStr(N);
                       SetPos(P);
                       Key:= 0;
                    end;
  end;
  inherited;
end;

procedure TEditDate.MouseUp(Button:TmouseButton;Shift:TShiftState;X,Y:Integer);
begin
  if SelLength < Length(Text) then SetPos(GetPos);
  inherited;
end;

procedure TEditDate.PosSeparators; //cherche position des séparateurs
begin
  FirstSeparator:= Pos(DateSeparator,Text);
  SecondSeparator:= Pos(DateSeparator,Copy(Text,FirstSeparator + 1, 10))+ FirstSeparator;
end;

function TEditDate.GetPos: integer; //renvoie la zone dans laquelle se trouve le curseur
begin
  PosSeparators;
  if SelStart < FirstSeparator then
      Result:= 1  // zone jours
    else if SelStart < SecondSeparator then
      Result:= 2  // zone mois
    else
      Result:= 3;  // zone année
end;

procedure TEditDate.SetPos(P:integer); //change de zone
begin
  PosSeparators;
  if P < 1 then P:= 1
    else if P > 3 then P:= 3;
  case P of
    1: begin
           SelStart:= 0;
           SelLength:= FirstSeparator-1;
         end;
    2: begin
         SelStart:= FirstSeparator;
         SelLength:= SecondSeparator-FirstSeparator-1;
       end;
    3: begin
         SelStart:= SecondSeparator;
         SelLength:= Length(Text);
       end;
  end;
end;

procedure TEditDate.WMPaste(var Message: TWMPaste);
begin
  if (eoAllowPaste in Options) and (Clipboard.HasFormat(CF_TEXT)) then
  try
    Text:= FormatDateTime(FDateFormat, StrToDate(Clipboard.AsText));
    SetPos(1);
  except
    MessageBeep(1);
  end;
end;

end.
