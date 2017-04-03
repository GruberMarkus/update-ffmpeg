@echo off
pushd "%~dp0"
isadmin.exe -q
if %errorlevel% neq 1 (
	echo Script needs admin rights, which were not provided.
	exit /b 1
)
cls

echo Preparations
echo ----------------------------------------
call :GetDVBVPath
echo Done.


echo.
echo.
echo Download, extract and copy
echo ----------------------------------------
echo Download
if exist "%temp%\ffmpeg-latest-win64-static.7z" del /f /q "%temp%\ffmpeg-latest-win64-static.7z"
COPY /B "%DVBVPath%\ffmpeg.exe"+NUL "%DVBVPath%\ffmpeg.exe" 2>nul >NUL || (
	echo "%DVBVPath%\ffmpeg.exe" is in use,
	echo new version can not be installed.
	goto :end
)
wget.exe -q --show-progress --progress=bar:force:noscroll https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-latest-win64-static.7z -P "%temp%"
if exist "%temp%\ffmpeg-latest-win64-static.7z" (
	COPY /B "%DVBVPath%\ffmpeg.exe"+NUL "%DVBVPath%\ffmpeg.exe" 2>nul >NUL || (
		echo "%DVBVPath%\ffmpeg.exe" is in use,
		echo new version can not be installed.
		goto :end
	)
	echo.
	echo Extract from archive and copy to "%DVBVPath%"
	7za.exe e "%temp%\ffmpeg-latest-win64-static.7z" -o"%DVBVPath%" ffmpeg.exe -r -y >nul
	if not %errorlevel%==0 (
		echo Error extracting ffmpeg.exe from file.
	) else (
		echo Done.
	)
)


:end
if exist "%temp%\ffmpeg-latest-win64-static.7z" del /f /q "%temp%\ffmpeg-latest-win64-static.7z"
set DVBVPath=
goto :eof


:GetDVBVPath
set DVBVPath=
FOR /F "tokens=5* delims=	 " %%A IN ('REG QUERY "HKLM\software\wow6432node\microsoft\windows\currentversion\uninstall\dvbviewer pro_is1" /v "inno setup: app path"') DO SET DVBVPath=%%B
if not defined DVBVPath (
	FOR /F "tokens=5* delims=	 " %%A IN ('REG QUERY "HKCU\software\wow6432node\microsoft\windows\currentversion\uninstall\dvbviewer pro_is1" /v "inno setup: app path"') DO SET DVBVPath=%%B
	if not defined DVBVPath (
		FOR /F "tokens=5* delims=	 " %%A IN ('REG QUERY "HKLM\software\microsoft\windows\currentversion\uninstall\dvbviewer pro_is1" /v "inno setup: app path"') DO SET DVBVPath=%%B
		if not defined DVBVPath (
				FOR /F "tokens=5* delims=	 " %%A IN ('REG QUERY "HKCU\software\microsoft\windows\currentversion\uninstall\dvbviewer pro_is1" /v "inno setup: app path"') DO SET DVBVPath=%%B
				if not defined DVBVPath (
						set DVBVPath="C:\Program Files (x86)\DVBViewer"
				)
		)
	)
)
goto :eof
