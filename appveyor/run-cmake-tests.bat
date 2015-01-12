REM /appveyor/run-cmake-tests.bat
REM
REM Uses CTest to run CMake tests with the Debug configuration.
REM
REM See LICENCE.md for Copyright information.

pushd tests/build
ctest -C Debug --output-on-failure || goto :error
popd

goto :EOF

:error
echo "Failed with error #%errorlevel%".
exit /b %errorlevel%