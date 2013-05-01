program FunctionPlotterPrg;

{$IFDEF FPC} //for FPC/Lazarus
  {$MODE DELPHI}
{$ENDIF}

{$IFDEF DEBUG}
  {$APPTYPE CONSOLE}
{$ENDIF}

uses
  dglOpenGL,
  SDL,
  EVEngine,
  EVMath,
  EVOpenGLStateCache,
  Math,
  functionplotter;

type
  TMyEngine = class(TEVEngine)
    procedure Render; override;
  end;

var
  engine: TMyEngine;
  fnc: TPlotterFunction;

procedure TMyEngine.Render;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); //Clears the buffers.

  glLoadIdentity;

  DrawPlotterFunction(fnc,engine.Width,engine.Height,0.1,-10,10,-10,10);
  
  SDL_GL_SwapBuffers; //changes the buffers, so you can see sth. on the screen...
end;

begin
  //calculate Function
  fnc := GetFunctionFromString('x^2;');

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