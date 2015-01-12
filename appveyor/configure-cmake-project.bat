REM /appveyor/configure-cmake-tests.bat
REM
REM Sets up Visual Studio variables for current project and configures
REM it using CMake.
REM
REM See LICENCE.md for Copyright information.

set PATH=C:\Program Files (x86)\CMake\bin;%PATH%
call "C:/Program Files (x86)/Microsoft Visual Studio %VS_VERSION%/Common7/Tools/vsvars32.bat"
cmake --version
pushd tests
mkdir build
pushd build
cmake .. -Wdev --warn-uninitialized -G"%GENERATOR%" || goto :error
cmake --build . || goto :error
popd
popd

goto :EOF

:error
echo "Failed with error #%errorlevel%".
exit /b %errorlevel%