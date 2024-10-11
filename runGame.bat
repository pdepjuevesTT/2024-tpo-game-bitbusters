@echo off

set "scriptDir=%~dp0"

set "wollokDirectory= .\wollok.exe"

start http://localhost:3000

%wollokDirectory% run -g "main.TetrisWollok" --skipValidations -p %scriptDir%

pause