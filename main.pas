unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Panel1: TPanel;
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
  b := true;
  for x := 0 to Length(input) - 1 do
  begin
    case state of
      start:
        case input[x] of
	  ';','^': 				   state := error;
	  '+','-': 				   state := plusminus;
	  '0','1','2','3','4','5','6','7','8','9': state := digit;
  	end;
	  
	plusminus:
	case input[x] of
	  ';','^','+','-': 			   state := error;
	  'x': 					   state := variable;
	  '0','1','2','3','4','5','6','7','8','9': state := digit;
	end;

	digit:
	  case input[x] of
	    ';': state := success;
	    '^','+','-': state := error;
	  end;
	  
        variable:
	  case input[x] of
	    ';': 				     state := success;
	    '^':				     state := three;
	    '+','-':				     state := plusminus;
	    '0','1','2','3','4','5','6','7','8','9': state := error_exponent;
	  end;
	  
    end;
	
    if (state = error) or (state = error_exponent) then b := false;
    if not b then break;
    if (state = success) then break;
  end;
  Result := b;
end;

{$R *.lfm}

end.

