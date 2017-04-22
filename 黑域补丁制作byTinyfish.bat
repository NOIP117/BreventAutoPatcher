@echo off
setlocal EnableExtensions EnableDelayedExpansion
color 3f

cd /d "%~dp0"
set "path=%~dp0Binary;%~dp0jre\bin;!path!"

title ���򲹶��Զ����� 4.6 by Tinyfish
echo =================================================
echo   �˽ű�һ�����������ں˲��������ܰ�����
echo   * �Զ��ϴ������ֻ��е��ں��ļ���
echo   * ����Ҫ���ⰲװPython����ʾ����JRE�⡣
echo   * �Զ���װadb������
echo   * ���adb rootȨ�ޡ�
echo   * �������ִ���jar��odex�������
echo   * ֧��Android 4.x~7.x��
echo   * ��װ����app��
echo   * ������ʱ�ļ���
echo   * ֧���ֹ�����������
echo   * �Զ�����ˢ���������ͻָ�����

set "UseAdb=1"
if /i "%~1"=="NoAdb" (
	set "UseAdb=0"
	echo.
	echo =================================================
	echo   �ֹ���������ģʽ���룺
	echo.
	echo   * ����services.jar��framework\�£������д���frameworkĿ¼��
	echo.
	echo   * �������services.odex������/system/framework/�������ݵ�framework\Ŀ¼��
	echo.
	pause
)

echo.
echo =================================================
echo   ��黷��������
echo.

:CHECK_ENV

if "!UseAdb!"=="1" (
	for /f "tokens=*" %%t in ('adb get-state') do set "adbState=%%t"
	echo.
	echo   Adb״̬: !adbState!
	if not "!adbState!"=="device" (
		echo.
		echo   ���԰�װadb����������
		call "InstallUsbDriver.cmd"

		echo.
		echo   �������adb vendor id������
		call "AddAndroidVendorID.cmd"

		adb kill-server
		ping -n 2 127.0.0.1 >nul
		
		for /f "tokens=*" %%t in ('adb get-state') do set "adbState=%%t"
		echo.
		echo   Adb״̬: !adbState!
		if not "!adbState!"=="device" (
			echo.
			echo   �޷�����adb����ȷ����
			echo.
			echo   * ���ֻ�����USB��
			echo.
			echo   * �ֻ�����ADB���Ժ�root��http://www.shuame.com/faq/usb-connect/9-usb.html����
			echo.
			pause
			goto :CHECK_ENV
		)
	)

	for /f "tokens=1 delims=." %%t in ('adb shell getprop ro.build.version.release') do set "androidVersion=%%t"
) else (
	echo.
	echo �������ļ������İ�׿�汾��4/5/6/7����
	set /p androidVersion=
)

echo.
echo   Android�汾��!androidVersion!

echo.
echo =================================================
echo   �����ļ�������
echo.

FastCopy /cmd=delete /no_ui "apk" "services" "classes.dex" "services.jar"

if "!UseAdb!"=="1" (
	FastCopy /cmd=delete /no_ui "framework"
)

if "!UseAdb!"=="1" (
	echo.
	echo =================================================
	echo   ��ȡservices.jar������
	echo.

	adb shell ls -lR "/system/framework"|find "services.odex"
	if errorlevel 1 (
		if not exist "framework" md "framework"
		cd "framework"
		adb pull "/system/framework/services.jar"
		if errorlevel 1 echo   ����services.jarʧ�ܡ� & pause & exit /b
		cd "%~dp0"
	) else (
		adb pull "/system/framework"
		if errorlevel 1 echo   ����framework/ʧ�ܡ� & pause & exit /b
	)
)

if not exist "framework\services.jar" (
	echo.
	echo   �Ҳ���services.jar���޷�������
	echo.
	echo   �밴������˳�������
	pause >nul
	exit /b
)

echo.
echo =================================================
echo   ���services.odex������
echo.

if "!androidVersion!"=="4" echo   Android 4.x����Ҫ����services.odex�� & goto :SKIP_SERVICES_ODEX

cd "framework"
for /f "tokens=*" %%a in ('dir /b /s services.odex 2^>nul') do set "servicesOdexPath=%%a"
cd "%~dp0"
if not exist "!servicesOdexPath!" echo   ������services.odex & goto :SKIP_SERVICES_ODEX
for %%a in ("!servicesOdexPath!") do set "servicesOdexDir=%%~dpa"
set "servicesOdexDir=!servicesOdexDir:~0,-1!"

cd "framework"
for /f "tokens=*" %%a in ('dir /b /s boot.oat') do set "bootOatPath=%%a"
cd "%~dp0"
if not exist "!bootOatPath!" (
	echo.
	echo   ����services.odex�����Ҳ���boot.oat���޷�������
	echo.
	echo   �밴������˳�������
	pause >nul
	exit /b
)
for %%a in ("!bootOatPath!") do set "bootOatDir=%%~dpa"
set "bootOatDir=!bootOatDir:~0,-1!"

:TRY_MOVE_FRAMEWORK
md "\BreventAutoPatchTemp"
move "framework" "\BreventAutoPatchTemp\\"
if errorlevel 1 echo   ��⵽frameworkĿ¼���������벻Ҫ��frameworkĿ¼�����е��ļ���& pause & goto :TRY_MOVE_FRAMEWORK

cd "/BreventAutoPatchTemp/framework"
for /f "tokens=*" %%a in ('dir /b /s services.odex 2^>nul') do set "servicesOdexFrameworkPath=%%a"
cd "%~dp0"

move "\BreventAutoPatchTemp\framework" ".\\"
rd "\BreventAutoPatchTemp"

set "servicesOdexFrameworkPath=!servicesOdexFrameworkPath:~24!"
set "servicesOdexFrameworkDir=!servicesOdexFrameworkPath:~0,-14!"

set "servicesOdexMobilePath=/system/!servicesOdexFrameworkPath!"
set "servicesOdexMobilePath=!servicesOdexMobilePath:\=/!"

echo.
echo   services.odex����·����!servicesOdexFrameworkPath!
echo   services.odex�ֻ�·����!servicesOdexMobilePath!
echo.

:SKIP_SERVICES_ODEX

echo.
echo =================================================
echo   ����ˢ���ָ���BreventRestore.zip������
echo.

copy /y "Package\Update.zip" "BreventRestoreRaw.zip"
FastCopy /cmd=delete /no_ui "system"
md "system\framework"

copy /y "framework\services.jar" "system\framework\\"
if exist "!servicesOdexPath!" (
	md "system\!servicesOdexFrameworkDir!" 2>nul
	copy /y "!servicesOdexPath!" "system\!servicesOdexFrameworkDir!\\"
)

zip -r "BreventRestoreRaw.zip" "system\\"
if errorlevel 1 echo   �޷�����ˢ���ָ�����& pause & exit /b
java -jar "%~dp0Binary\signapk.jar" "Binary\testkey.x509.pem" "Binary\testkey.pk8" "BreventRestoreRaw.zip" "BreventRestore.zip"
if errorlevel 1 echo   �޷�ǩ��ˢ����������& pause & exit /b

del /q "BreventRestoreRaw.zip"
FastCopy /cmd=delete /no_ui "system"

if exist "!servicesOdexPath!" (
	echo.
	echo =================================================
	echo   ���ڰ�services.odexת��smali������
	echo.
	if "!androidVersion!"=="5" (
		java -jar "%~dp0Binary\oat2dex.jar" boot "!bootOatPath!"
		if errorlevel 1 echo   ת��boot.oat����& pause & exit /b
		java -jar "%~dp0Binary\oat2dex.jar" "!servicesOdexPath!" "!bootOatDir!\dex"
		if errorlevel 1 echo   ת��services.odex����& pause & exit /b
		java -jar "%~dp0Binary\baksmali-2.2b4.jar" d "!servicesOdexDir!\services.dex" -o "services"
		if errorlevel 1 echo   ת��services.dex����& pause & exit /b
	) else (
		java -jar "%~dp0Binary\baksmali-2.2b4.jar" x -d "!bootOatDir!" "!servicesOdexPath!" -o "services"
		if errorlevel 1 echo   ת��odex����& pause & exit /b
	)
) else (
	echo.
	echo =================================================
	echo   ���ڰ�services.jarת��smali������
	echo.
	java -jar "%~dp0Binary\baksmali-2.2b4.jar" d "framework\services.jar" -o "services"
	if errorlevel 1 echo   ת��services.jar����& pause & exit /b
)

echo.
echo =================================================
echo   ���ڰ�apkת��smali������
echo.
java -jar "%~dp0Binary\baksmali-2.2b4.jar" d "Package\Brevent.apk" -o "apk"

echo.
echo =================================================
echo   ���ڴ򲹶�������
echo.
patch -a "apk" -s "services"
if errorlevel 1 (
	echo.
	echo   �򲹶�������ᵼ���ֻ��޷�������ɧ�꣬�����ټ����ˣ�Ҫ���µġ�
	echo.
	echo   �밴������˳�������
	pause >nul
	exit /b
)

echo.
echo =================================================
echo   ����������������services.jar������
echo.
java -jar "%~dp0Binary\smali-2.2b4.jar" a -o "classes.dex" "services"
if errorlevel 1 echo   ���classes.dex����& pause & exit /b
copy /y "framework\services.jar" ".\\"
zip "services.jar" "classes.dex"
if errorlevel 1 echo   ���classes.dex����& pause & exit /b

echo.
echo =================================================
echo   ����ˢ��������BreventPatch.zip������
echo.

copy /y "Package\Update.zip" "BreventPatchRaw.zip"
FastCopy /cmd=delete /no_ui "system"
md "system\framework"
copy /y "services.jar" "system\framework\\"

zip -r "BreventPatchRaw.zip" "system\\"
if errorlevel 1 echo   �޷�����ˢ����������& pause & exit /b
java -jar "%~dp0Binary\signapk.jar" "Binary\testkey.x509.pem" "Binary\testkey.pk8" "BreventPatchRaw.zip" "BreventPatch.zip"
if errorlevel 1 echo   �޷�ǩ��ˢ����������& pause & exit /b

del /q "BreventPatchRaw.zip"
FastCopy /cmd=delete /no_ui "system"

if "!UseAdb!"=="1" (
	echo.
	echo =================================================
	echo   �������Ƿ��Ѱ�װ������
	echo.

	adb shell pm list packages|find "me.piebridge.prevent"
	if errorlevel 1 (
		echo   ��װ���򡣡���
		echo.
		adb install "Package\Brevent.apk"
	)

	echo.
	echo =================================================
	echo �ϴ����ɵ�services.jar��/system/framework�С�
	echo.

	adb push "services.jar" "/sdcard/"
	if errorlevel 1 echo �ϴ�services.jar��/sdcard/ʧ�ܡ�& call :PushError

	adb push "BreventRestore.zip" "/sdcard/"
	if errorlevel 1 echo �ϴ�BreventRestore.zip��/sdcard/ʧ�ܡ�& call :PushError

	adb push "BreventPatch.zip" "/sdcard/"
	if errorlevel 1 echo �ϴ�BreventPatch.zip��/sdcard/ʧ�ܡ�& call :PushError

	:CHECK_ROOT
	adb shell su -c 'chmod 666 "/data/data/com.android.providers.contacts/databases/contacts2.db"'
	if errorlevel 1 (
		echo.
		echo   adbû��rootȨ�ޣ���ȷ����
		echo.
		echo   * �ֻ��Ѿ�root��
		echo.
		echo   * adb�ѻ��rootȨ�ޡ��������ֻ���Ļ����ʾ��Ҫȷ�ϣ�CMϵͳ������Ҫ�ڿ�����ѡ��������adb root��SuperSU������Ҫ�رա�������������ռ䡣
		echo.
		echo   ���adb�޷����rootȨ�ޣ���Ҳ�����ֹ�����services.jar��/system/framework/�У�����ʹ��ˢ����BrenventPatch.zip��
		echo.
		pause
		goto :CHECK_ROOT
	) else (
		adb shell su -c 'chmod 660 "/data/data/com.android.providers.contacts/databases/contacts2.db"'
	)

	adb shell su -c 'mount -o rw,remount "/system"'
	if errorlevel 1 echo   ����system����ʧ�ܡ�& call :PushError
	adb shell su -c 'cp -f "/sdcard/services.jar" "/system/framework/"'
	if errorlevel 1 echo   ����services.jarʧ�ܡ�& call :PushError
	adb shell su -c 'chmod 644 "/system/framework/services.jar"'
	if errorlevel 1 echo   �޸�services.jarȨ��ʧ�ܡ�& call :PushError

	if exist "!servicesOdexPath!" (
		adb shell su -c 'rm -f "!servicesOdexMobilePath!"'
		if errorlevel 1 echo   ɾ��services.odexʧ�ܡ�& call :PushError
	)
)

echo.
echo =================================================
echo   ������ʱ�ļ�������
echo.

FastCopy /cmd=delete /no_ui "apk" "services" "classes.dex"

if "!UseAdb!"=="1" (
	FastCopy /cmd=delete /no_ui "framework"
)

if "!UseAdb!"=="1" (
	echo.
	echo =================================================
	echo   ��ɣ��ǵ������ֻ���
	echo.
	echo   ����޷�������������ˢBreventRestore.zip�ָ���
	echo.
	pause
) else (
	echo.
	echo =================================================
	echo   ��ɣ�������ˢBreventPatch.zip�򿽱�services.jar�����ܻ���Ҫɾ��services.odex��
	echo.
	echo   ����޷�������������ˢBreventRestore.zip�ָ���
	echo.
	pause
)

goto :EOF
:PushError
setlocal
echo.
echo   ��Ϊrom�����ƣ��޷��Զ��ϴ�services.jar����ʹ��ˢ����BrenventPatch.zip�������ֶ�����services.jar��/system/framework/�����ܻ���Ҫɾ��services.odex��
echo.
pause
exit /b
(endlocal)
goto :EOF

endlocal
