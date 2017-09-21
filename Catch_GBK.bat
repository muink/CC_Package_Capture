:: CC Packager Capture
:: Capture Adobe CC install packages
:: Author: muink

@echo off
::init
set path=%path%;%~dp0bin
rem ���幤��Ŀ¼
dir /ad /b "%~1">nul 2>nul&&set "#WORKFOLDER#=%~1"||echo.�����Ŀ¼, ��������˳�...&&pause>nul&&exit
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
   echo.  [c] �ڰ�װ�͸���ʱץȡ (ץȡ json �ļ��� aamdownload ��^)
   echo.  [o] ���л����������Բ���װʱץȡ (��ץȡ aamdownload ��^)
)
echo.  [j] ���� json �ļ� (���� [c] ��ɺ��Զ�ǿ��ִ��)
echo.  [m] ���� aamdownload �� (���� [c/o] ��ɺ���Զ�ǿ��ִ��)
echo.  [g] ���ɲ�Ʒ��
echo.  [l] �г����ܵ�ȱʧ�ļ� (�޷�������װʱ��������)
echo.  [p] �򿪲�ƷĿ¼
if defined #NOLOCAL# (
   echo.  [e] ������ú;ɰ汾�İ�
)
echo.
echo.================================================================
echo.
set /p choose=ѡ��: 
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
   echo.����Ŀ¼ %#WORKFOLDER#% ��Ϊ��, �����������...&pause>nul
   goto :menu
)
md "%#WORKFOLDER#%">nul 2>nul
call:[Config] "Application\.json$|(?i)\.zip\.aamdownload$"
cls
echo.
echo.�뽫��װ�����л��� English (North America)
echo.���������Դ� Adobe CC Desktop ��ʼ�����װ���ȴ���װ���
echo.ע��: ����������������ԵĲ���ץȡ
echo.      ���������Ĳ�Ʒ����������ץȡʱ��ͬ�İ�װ�����³ɹ���װ
call:[Catch] on
echo.
set /p np=����װ��Ϻ� �����԰��س���������...
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
echo.��������Ҫ�л�ÿ�ְ�װ���Բ���װ������������
echo.�����һ���ǳ��鷳�Ĺ���, ���ܻ�ȡ���������İ�װ��
echo.���������Ϊ�˷����Լ����а�װ������
echo.���ҿ���ͨ�� Adobe CC Desktop ��ȡ����ĸ�������
echo.�򲻽��������� �Ƿ����? [y/n]
   echo.
   set ny=n
   set /p ny=ѡ��: 
   if not "%ny%"=="y" goto :menu
call:[Catch] on
cls
echo.
echo.��������Ҫ�л�ÿ�ְ�װ���Բ���װ������������
echo.�����һ���ǳ��鷳�Ĺ���, ���ܻ�ȡ���������İ�װ��
echo.
set /p np=���������԰�װ��Ϻ� �����԰��س���������...
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
(echo.^<?xml version="1.0" encoding="utf-8"?^>
echo.^<DriverInfo^>
echo.^<ProductInfo^>)>0.head
(echo.^</ProductInfo^>
echo.^</DriverInfo^>)>0.end
for /f "delims=" %%a in ('dir /a:-d /b /s^|findstr /i Application\.json$') do (
   call:[JsonReadHead] "%%~a"
   echo.!#PName!|findstr /i /g:%~dp0config\list.txt>nul&&(
      echo.^<Name^>!#PName!^</Name^>
      echo.^<SAPCode^>!#SCode!^</SAPCode^>
      echo.^<CodexVersion^>!#PVer!^</CodexVersion^>
      echo.^<Platform^>win64^</Platform^>
      echo.^<EsdDirectory^>./!#SCode!^</EsdDirectory^>
   )>main||(
      set /a #JsonCom+=1>nul
      echo.^<Dependency^>
      echo.^<SAPCode^>!#SCode!^</SAPCode^>
      echo.^<BaseVersion^>!#PVer!^</BaseVersion^>
      echo.^<EsdDirectory^>./!#SCode!^</EsdDirectory^>
      echo.^</Dependency^>
   )>>misc
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