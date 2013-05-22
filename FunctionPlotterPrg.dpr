program FunctionPlotterPrg;

{$IFDEF FPC} //for FPC/Lazarus
  {$MODE DELPHI}
{$ENDIF}

{$IFDEF DEBUG}
  {$APPTYPE CONSOLE}
{$ENDIF}

uses
  Classes,
  dglOpenGL,
  SDL,
  EVEngine,
  EVMath,
  EVOpenGLStateCache,
  Math,
  functionplotter;

type
  TMyEngine = class(TEVEngine)  
    procedure OnMouseDown(_button: Byte; _x,_y: UInt16); override;
    procedure OnMouseMove(_x,_y: UInt16;_xrel,_yrel: SInt16); override;
    procedure OnMouseUp(_button: Byte;_x,_y: UInt16); override;
    procedure Render; override;
  end;

var
  engine: TMyEngine;
  fnc: TPlotterFunction;
  left_pressed: Boolean;
  a,b: Integer;
  xmove,
  ymove: Integer;
  step: Single;
  minx,
  maxx,
  miny,
  maxy: Single;

procedure TMyEngine.OnMouseDown(_button: Byte; _x,_y: UInt16);
begin
  case _button of
    1: left_pressed := true;
    4:
    begin
      minx := minx + 1;
      maxx := maxx - 1;
    end;
    5:
    begin
      minx := minx - 1;
      maxx := maxx + 1;
    end;
  end;
end;

procedure TMyEngine.OnMouseMove(_x,_y: UInt16; _xrel,_yrel: SInt16);
begin
  if left_pressed then
  begin
    xmove := xmove + _xrel;
    ymove := ymove - _yrel;
  end;
end;

procedure TMyEngine.OnMouseUp(_button: Byte; _x,_y: UInt16);
begin
  case _button of
    1: left_pressed := false;
  end;
end;

procedure TMyEngine.Render;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); //Clears the buffers.

  glLoadIdentity;

  glTranslatef(xmove,ymove,0);

  DrawPlotterFunction(fnc,engine.Width,engine.Height,xmove,ymove,step,minx,maxx,miny,maxy);

  SDL_GL_SwapBuffers; //changes the buffers, so you can see sth. on the screen...
end;

var
  str: TStringList;

begin
  left_pressed := false;
  xmove := 0;
  ymove := 0;
  step := 0.1;
  minx := -10;
  maxx := 10;
  miny := -10;
  maxy := 10;

  //get function
  str := TStringList.Create;
  str.LoadFromFile('function.txt');
  fnc := GetFunctionFromString(PAnsiChar(str.Text));

  //initialize Engine
  engine := TMyEngine.Create(800,600,16,'Functionplotter',true{,false});
  try
    engine.MaxFPS := 24;  //frame-limit from 24 fps
    engine.Perspective := false;
    engine.StartMainLoop; //starts the main loop
  finally
    engine.SaveLog('log.txt'); //in the end it's saves the log...
    engine.Free;
  end;
end.