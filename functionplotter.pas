unit functionplotter;

interface

uses
  SysUtils,
  Math;  

type

  // s*a*x^n
  TPlotterFunctionPart = record
    s: Boolean; //sign: + => 0; - => 1
    a: Integer;
    n: Cardinal;
  end;

  TPlotterFunction = array of TPlotterFunctionPart;
  
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
function CheckInput(input: PChar): Integer;
var
  state: Cardinal;
  b: Boolean;
  x: Integer;
begin
  Result := 0;
  x := 0;
  //seek for invalids
  while x < Length(input) do
  begin
    case input[x] of
      'x',';','^','+','-','0','1','2','3','4','5','6','7','8','9': Inc(x);
    else
      Result := x;
      Exit;
    end;
  end;

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
          'x':                                     state := variable;
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
  if state = success then
    Result := -1
  else
    Result := x;
end;

function GetFunctionFromString(input: PChar): TPlotterFunction;
var
  x: Integer;
  sign: Boolean;

  function GetNumber: Integer;
  var
    d: Integer;
    b: Boolean;
  begin
    Result := StrToInt(input[x]);
    Inc(x);
    b := true;
    d := 2;
    while b and (x < Length(input)) do
    begin
      case input[x] of
        '0','1','2','3','4','5','6','7','8','9':
        begin
          Result := StrToInt(input[x]) + 10*Result;
          Inc(d);
          Inc(x);
        end;
      else
        b := false;
      end;
    end;
  end;

  function ReadFunction(s: Boolean): TPlotterFunctionPart;
  var
    b: Boolean;
  begin
    Result.s := s;
    Result.a := -1;
    Result.n := 0;
    b := true;
    while b do
      case input[x] of
        'x':
        begin
          if Result.a = -1 then
            Result.a := 1;
          Result.n := 1;
          Inc(x);
        end;
        '0','1','2','3','4','5','6','7','8','9':
          Result.a := GetNumber;
        '^':
        begin
          Inc(x);
          Result.n := GetNumber;
        end;
      else
        b := false;
      end;
  end;

begin
  x := 0;
  while x < Length(input) do
  begin
    case input[x] of
      '+','-':
      begin
        SetLength(Result, Length(Result) + 1);
        sign := input[x] = '-';
        Inc(x);
        Result[High(Result)] := ReadFunction(sign);
      end;
      'x','0','1','2','3','4','5','6','7','8','9':
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := ReadFunction(false);
      end;
    else
      Break;
    end;
  end;
end;

end.