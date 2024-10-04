@echo off

set "scriptDir=%~dp0"
set "scriptDir=%scriptDir:~0,-1%"

REM set "wollokDirectory=C:\users\administrador\wollok\wollok.exe"
REM set "wollokDirectory=.\Wollok\wollok.exe"
set "wollokDirectory=wollok"

%wollokDirectory% run -g 'main.TetrisWollok' --skipValidations -p %scriptDir%

pause