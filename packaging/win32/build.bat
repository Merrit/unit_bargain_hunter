@echo off

:: Run this script from project root

call flutter clean
call flutter pub get
call flutter build windows
move build\windows\runner\Release build\unit_bargain_hunter

set buildFolder=%cd%\build\unit_bargain_hunter

echo.
echo Copying Visual C++ Redistributable libraries to output directory
echo.
xcopy C:\Windows\System32\msvcp140.dll %buildFolder%
xcopy C:\Windows\System32\vcruntime140.dll %buildFolder%
xcopy C:\Windows\System32\vcruntime140_1.dll %buildFolder%

xcopy packaging\win32\inno-setup-script.iss .
iscc inno-setup-script.iss
del inno-setup-script.iss
