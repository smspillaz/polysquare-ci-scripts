REM /appveyor/install-cmake-3.1.bat
REM
REM Installs CMake 3.1 if it isn't available in the cache.
REM
REM See LICENCE.md for Copyright information.

if exist {cmake-inst} (
    echo "Fetched CMake 3.1 installer from cache"
) else (
    echo "Downloading CMake 3.1 Installer" 
    powershell -Command "(New-Object Net.WebClient).DownloadFile('http://www.cmake.org/files/v3.1/cmake-3.1.0-rc1-win32-x86.exe', 'cmake-inst')" || goto :error
)

echo "Installing CMake 3.1 from cmake-inst"
cmake-inst /S || goto :error

goto :EOF

:error
echo "Failed with error #%errorlevel%".
exit /b %errorlevel%