:: CC Packager Capture
:: Capture Adobe CC install packages
:: Author: muink

@echo off
::init
set path=%path%;%~dp0bin
rem 定义工作目录
dir /ad /b "%~1">nul 2>nul&&set "#WORKFOLDER#=%~1"||echo.输入非目录, 按任意键退出...&&pause>nul&&exit
if not defined #WORKFOLDER# (
   for /f "delims=" %%i in ("%temp%") do set "#WORKFOLDER#=%%~di\CCPKG"&md %%~di\CCPKG>nul 2>nul
) else set #NOLOCAL#=True
set #PName=
set #SCode=
set #PVer=

:menu
cls
echo.================================================================
echo.
if not defined #NOLOCAL# (
   echo.  [c] 在安装和更新时抓取 (抓取 json 文件和 aamdownload 包^)
   echo.  [o] 在切换至其他语言并安装时抓取 (仅抓取 aamdownload 包^)
)
echo.  [j] 整理 json 文件 (动作 [c] 完成后将自动强制执行)
echo.  [m] 整理 aamdownload 包 (动作 [c/o] 完成后后将自动强制执行)
echo.  [g] 生成产品包
echo.  [l] 列出可能的缺失文件 (无法正常安装时可能有用)
echo.  [p] 打开产品目录
echo.
echo.================================================================
echo.
set /p choose=选择: 
if not defined #NOLOCAL# (
   if "%choose%"=="c" goto :case_%choose%
   if "%choose%"=="o" goto :case_%choose%
)
if "%choose%"=="j" goto :case_%choose%
if "%choose%"=="m" goto :case_%choose%
if "%choose%"=="g" goto :case_%choose%
if "%choose%"=="l" goto :case_%choose%
if "%choose%"=="p" goto :case_%choose%
goto :menu

:case_c
cls
echo.
rd /q "%#WORKFOLDER#%">nul 2>nul||(
   echo.工作目录 %#WORKFOLDER#% 不为空, 请清理后重试...&pause>nul
   goto :menu
)
md "%#WORKFOLDER#%">nul 2>nul
call:[Config] "Application\.json$|(?i)\.zip\.aamdownload$"
cls
echo.
echo.请将安装语言切换至 English (North America)
echo.现在您可以从 Adobe CC Desktop 开始软件安装并等待安装完成
echo.注意: 如果不进行其他语言的补充抓取
echo.      则制作出的产品包必须在与抓取时相同的安装语言下成功安装
call:[Catch] on
echo.
set /p np=待安装完毕后 您可以按回车继续过程...
call:[Catch] off
call:[JsonArrange] "%#WORKFOLDER#%"
call:[AamdownloadArrange] "%#WORKFOLDER#%"
goto :menu

:case_j
cls
call:[JsonArrange] "%#WORKFOLDER#%"
goto :menu

:case_o
call:[Config] "(?i)\.zip\.aamdownload$"
cls
echo.
echo.现在您需要切换每种安装语言并安装所有语言类型
echo.这会是一个非常麻烦的过程, 但能获取到更完整的安装包
echo.如果您仅是为了方便自己进行安装包制作
echo.并且可以通过 Adobe CC Desktop 获取软件的更新升级
echo.则不建议您继续 是否继续? [y/n]
   echo.
   set ny=n
   set /p ny=选择: 
   if not "%ny%"=="y" goto :menu
call:[Catch] on
cls
echo.
echo.现在您需要切换每种安装语言并安装所有语言类型
echo.这会是一个非常麻烦的过程, 但能获取到更完整的安装包
echo.
set /p np=待所有语言安装完毕后 您可以按回车继续过程...
call:[Catch] off
call:[AamdownloadArrange] "%#WORKFOLDER#%"
goto :menu

:case_m
cls
call:[AamdownloadArrange] "%#WORKFOLDER#%"
goto :menu

:case_g
cls
call:[JsonFormat] "%#WORKFOLDER#%"
call:[MakeProducts] "%#WORKFOLDER#%"
goto :menu

:case_l
cls
call:[JsonFormat] "%#WORKFOLDER#%" l
goto :menu

:case_p
cls
start "" "%#WORKFOLDER#%"
goto :menu




:[AamdownloadArrange]
setlocal enabledelayedexpansion
cd /d %~1
for /f "delims=" %%i in ('dir /a:-d /b /s^|findstr /i .*\.aamdownload$') do ren "%%~i" *.>nul 2>nul
for /f "delims=" %%i in ('dir /a:-d /b /s^|findstr /i .*\.zip$') do move /y "%%~i" .\>nul 2>nul
for /f "delims=" %%i in ('dir /a:d /b') do rd /q "%%~i" 2>nul
endlocal
goto :eof

:[JsonArrange]
setlocal enabledelayedexpansion
cd /d %~1
for /f "delims=" %%a in ('dir /a:-d /b /s^|findstr /i Application\.json$') do (
   call:[JsonReadHead] "%%~a"
   ren "%%~dpa" !#SCode!
)
endlocal
goto :eof

:[JsonFormat]
setlocal enabledelayedexpansion
cd /d %~1
del /s /q *.loss.txt >nul 2>nul
for /f "delims=" %%a in ('dir /a:-d /b /s^|findstr /i Application\.json$') do (
   copy /b /y "%%~a" "%%~a.sed" /b >nul 2>nul
   sed -i "s/{/{\n/g" "%%~a.sed"
   sed -i "s/}/\n}/g" "%%~a.sed"
   sed -i "s/,\"/,\n\"/g" "%%~a.sed"
   for /f "delims=" %%i in ('findstr /i /c:\"Path\": "%%~a.sed"') do (
      for /f "usebackq tokens=2 delims=:," %%I in ('%%i') do (
         if not "%%~nxI" == "application.xml" (
            if "%~2" == "l" (
               dir /a-d /b /s "%%~nxI">nul 2>nul||(
                  set "#SPath=%%~dpa"
                  echo.%%~nxI>>"!#SPath:~0,-1!.loss.txt"
               )
            ) else move /y "%%~nxI" "%%~dpa">nul 2>nul
         )
      )
   )
   del /q "%%~a.sed" >nul 2>nul
)
endlocal
goto :eof

:[JsonReadHead]
for /f "tokens=1-3 delims=," %%i in ('type "%~1"') do (
   for /f "tokens=2 delims=:" %%I in ("%%i") do set #PName=%%~I
   for /f "tokens=2 delims=:" %%J in ("%%j") do set #SCode=%%~J
   for /f "tokens=2 delims=:" %%K in ("%%k") do set #PVer=%%~K
)
goto :eof

:[MakeProducts]
setlocal enabledelayedexpansion
pushd %~1
for /f "delims=" %%i in ('findstr /i /s /m /g:%~dp0config\list.txt Application.json') do (
   call:[JsonReadHead] "%cd%\%%~i"
   (echo.^<Name^>!#PName!^</Name^>
   echo.^<SAPCode^>!#SCode!^</SAPCode^>
   echo.^<CodexVersion^>!#PVer!^</CodexVersion^>
   echo.^<Platform^>win64^</Platform^>
   echo.^<EsdDirectory^>./!#SCode!^</EsdDirectory^>)>main
)
(echo.^<?xml version="1.0" encoding="utf-8"?^>
echo.^<DriverInfo^>
echo.^<ProductInfo^>)>0.head
(echo.^</ProductInfo^>
echo.^</DriverInfo^>)>0.end
for /f "delims=" %%i in ('findstr /i /s /v /m /g:%~dp0config\list.txt Application.json') do (
   set /a #JsonCom+=1
   call:[JsonReadHead] "%cd%\%%~i"
   (echo.^<Dependency^>
   echo.^<SAPCode^>!#SCode!^</SAPCode^>
   echo.^<BaseVersion^>!#PVer!^</BaseVersion^>
   echo.^<EsdDirectory^>./!#SCode!^</EsdDirectory^>
   echo.^</Dependency^>)>>misc
)
if defined #JsonCom (
   echo.^<Dependencies^>>misc.head
   echo.^</Dependencies^>>misc.end
)
copy /y /a 0.head+main+misc.head+misc+misc.end+0.end Driver.xml /a
sed -i -n "H;${g;s/\n//g;p;}" Driver.xml
del /q /s 0.head main misc.head misc misc.end 0.end
endlocal
goto :eof

:[Config]
rem md "%USERPROFILE%\AppData\Local\NodeSoft\FolderMonitor">nul 2>nul
(
echo.^<?xml version="1.0" encoding="utf-8"?^>
echo.^<FolderMonitor^>
echo.   ^<Settings VisibleNotificationType="NoVisibleNotification" SoundType="SoundTypeSystemSound" CustomSound="" StopScreensaver="True" StopScreensaverTime="0" /^>
echo.   ^<Monitors^>
echo.      ^<Monitor Path="%temp%" IncludeSubdirectories="True"^>
echo.         ^<Settings Created="True" Changed="False" Deleted="False" Renamed="False" Command="%~dp0bin\link.bat" Argument="&quot;{1}&quot; &quot;{5}&quot;" EventTimeout="0" RegExInclude="%~1" RegExExclude="" /^>
echo.      ^</Monitor^>
echo.   ^</Monitors^>
echo.^</FolderMonitor^>
)>config\FolderMonitor.xml
rem )>"%USERPROFILE%\AppData\Local\NodeSoft\FolderMonitor\FolderMonitor.xml"
goto :eof

:[Catch]
if "%~1"=="on" start /min /high FolderMonitor.exe /ConfigFile:.\config\FolderMonitor.xml
if "%~1"=="off" taskkill /t /f /im FolderMonitor.exe>nul
goto :eof