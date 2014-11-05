set CompilerPath=E:\FlashDevelop\Tools\flexsdk\bin
set ProjectDir=%~dp0..\
set OutputDir=%ProjectDir%lib
set OutputName=GIFPlayer.swc
%CompilerPath%\compc.exe -o=%OutputDir%\%OutputName% -sp+=. -is+=com
echo output Swc success....
echo pass anykey
pause>nul