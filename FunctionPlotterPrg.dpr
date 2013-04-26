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
  functionplotter;

type
  TMyEngine = class(TEVEngine)
    procedure Render; override;
  end;
  
var
  engine: TMyEngine;
  
procedure TMyEngine.Render;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); //Clears the buffers.

  glLoadIdentity;
  glTranslatef(0,0,-5);

  glBegin(GL_QUADS);
    glVertex3f(0,0,0);
    glVertex3f(0,99,0);
    glVertex3f(99,99,0);
    glVertex3f(99,0,0);
  glEnd;
  
  SDL_GL_SwapBuffers; //changes the buffers, so you can see sth. on the screen...
end;
  
begin
  engine := TMyEngine.Create(600,400,16,'Functionplotter',true{,false});
  try
    engine.MaxFPS := 24;  //frame-limit from 24 fps
    engine.StartMainLoop; //starts the main loop
  finally
    engine.SaveLog('log.txt'); //in the end it's saves the log...
    engine.Free;
  end;
end.