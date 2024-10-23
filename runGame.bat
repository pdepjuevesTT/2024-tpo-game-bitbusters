@echo off

set "scriptDir=%~dp0"

set "wollokDirectory= .\files\wollok.exe"

start http://localhost:3000

%wollokDirectory% run -g "main.TetrisWollok" --skipValidations -p %scriptDir%files\

pause