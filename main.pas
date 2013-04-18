unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  TPlotterFunctionPart = record
    s: Boolean; //sign: + <=> 0; - <=> 1
    a: Integer;
    n: Cardinal;
  end;

  TPlotterFunction = array of TPlotterFunctionPart;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;


{
  The states of the transitiongraph
}
const
  start = 0;
  digit = 1;
  digit_exponent = 2;
  plusminus = 3;
  plusminus_exponent = 4;
  variable = 5;  
  three = 6;
  error = 7;
  error_exponent = 8;
  success = 9;
  
implementation
  
{
  Checks the Input like the transitiongraph describes.
}
function CheckInput(input: PChar): Boolean;
var
  state: Cardinal;
  b: Boolean;
  x: Integer;
begin
  Result := false;
  state := start;
  b := true;
  for x := 0 to Length(input) - 1 do
  begin
    case state of
      start:
        case input[x] of
          'x':                                     state := variable;
          ';','^': 				   state := error;
	  '+','-': 				   state := plusminus;
	  '0','1','2','3','4','5','6','7','8','9': state := digit;
  	end;
	  
      plusminus:
        case input[x] of
          ';','^','+','-': 			   state := error;
          'x':                                     state := variable;
	  '0','1','2','3','4','5','6','7','8','9': state := digit;
        end;

      plusminus_exponent:
        case input[x] of
          '+','-','^',';','x':                     state := error_exponent;
	  '0','1','2','3','4','5','6','7','8','9': state := digit_exponent;
        end;

      digit:
        case input[x] of
          ';':                                     state := success;
	  '^','+','-':                             state := error;
	  '0','1','2','3','4','5','6','7','8','9': state := digit;
	end;

      digit_exponent:
        case input[x] of
          '+','-':                                 state := digit;
          ';':                                     state := success;
          'x','^':                                 state := error_exponent;
	  '0','1','2','3','4','5','6','7','8','9': state := digit_exponent;
        end;

      variable:
	case input[x] of
	  ';': 				               state := success;
	  '^':				               state := three;
	  '+','-':				       state := plusminus;
	  '0','1','2','3','4','5','6','7','8','9','x': state := error_exponent;
	end;

      three:
        case input[x] of
          'x',';','^':                             state := error_exponent;
          '+','-':                                 state := plusminus_exponent;
	  '0','1','2','3','4','5','6','7','8','9': state := digit_exponent;
        end;
    end;
	
    if (state = error) or (state = error_exponent) then b := false;
    if not b then break;
    if (state = success) then break;
  end;
  Result := b;
end;

{Creates from the String the function}
function CreatePlotterFunction(input: PChar): TPlotterFunction;
var
  b: Boolean;
  x: Integer;

  function GetNumber: Integer;
  var
    d: Integer;
    b: Boolean;
  begin
    Result := StrToInt(input[x]);
    b := true;
    d := 1;
    while b do
    begin
      case input[x] of
        '0','1','2','3','4','5','6','7','8','9':
        begin
          Result := Result * d + StrToInt(input[x]);
          Inc(d);
          Inc(x);
      end;
      else
        b := false;
      end;
    end;
  end;

  function GetFunctionPart: TPlotterFunctionPart;
  var
    plotting: Boolean;
  begin
    plotting := true;
    while plotting do
      case input[x] of
        '^': Result.n := GetNumber;
        ';','+','-': plotting := false;
        '0','1','2','3','4','5','6','7','8','9': Result.a := GetNumber;
      end;
  end;

begin
  x := 0;
  b := true;
  SetLength(Result, 0);
  while b and (x < Length(input)) do
  begin
    case input[x] of
      '-','+':
      begin
        SetLength(Result, Length(Result) + 1);
        if input[x] = '-' then
          Result[High(Result)].s := true
        else
          Result[High(Result)].s := false;
        Result[High(Result)] := GetFunctionPart;
        Inc(x);
      end;
      '0','1','2','3','4','5','6','7','8','9':
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)].s := true;
        Result[High(Result)] := GetFunctionPart;
      end;
      ';': b := false;
    end;
  end;
end;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  f: TPlotterFunction;
begin
  if CheckInput(PChar(Edit1.Text)) then
  begin
    f := CreatePlotterFunction(PChar(Edit1.Text));
    Form1.Caption := '';
  end
  else
    Form1.Caption := 'fehler';
end;

{$R *.lfm}

end.

