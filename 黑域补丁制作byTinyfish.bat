@setlocal EnableDelayedExpansion

@color 3f
@title ���򲹶��Զ����� 2.4 by Tinyfish
@echo =================================================
@echo   �˽ű�һ�����������ں˲��������ܰ�����
@echo   * �Զ��ϴ������ֻ��е��ں��ļ���
@echo   * ��Ⲣ��ʾ��Ҫ��װ�Ļ����⡣
@echo   * ���adb rootȨ�ޡ�
@echo   * ���ִ���jar��odex�������
@echo   * ֧��Android 4.x~7.x��
@echo   * ��װ����app��
@echo   * ������ʱ�ļ���

@echo.
@echo =================================================
@echo   ��黷��������
@echo.

:CHECK_ENV

@for /f "tokens=*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Python\PythonCore"') do @set pythonVersionReg=%%a
@for /f "tokens=2*" %%a in ('reg query "%pythonVersionReg%\InstallPath" /ve') do @set pythonPath=%%b
@echo Python·��: %pythonPath%
@if exist "%pythonPath%python.exe" set path=%pythonPath%;%path%

@where python >nul 2>nul
@if "%errorlevel%"=="1" (
	echo.
	echo   δ��װPython�����������ذ�װ��https://www.python.org/ftp/python/2.7.12/python-2.7.12.msi��
	echo.
	pause
	exit /b
)

@for /f "tokens=*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit"') do @set jdkVersionReg=%%a
@for /f "tokens=2*" %%a in ('reg query "%jdkVersionReg%" /v JavaHome') do @set jdkPath=%%b
@echo JDK·����%jdkPath%
@if exist "%jdkPath%\bin\jar.exe" set path=%jdkPath%\bin;%path%

@where jar >nul 2>nul
@if "%errorlevel%"=="1" (
	echo.
	echo   δ��װJDK�����������ذ�װ��http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-windows-i586.exe��
	echo.
	pause
	exit /b
)

@for /f "tokens=*" %%t in ('adb get-state') do @set adbState=%%t
@if not "%adbState%"=="device" (
	echo.
	echo   �޷�����adb����ȷ����
	echo.
	echo   * �����Ѱ�װadb������http://download.clockworkmod.com/test/UniversalAdbDriverSetup.msi����
	echo.
	echo   * �ֻ�����ADB���Ժ�root��http://www.shuame.com/faq/usb-connect/9-usb.html����
	echo.
	echo   * ���ֻ�����USB��
	echo.
	pause
	goto :CHECK_ENV
)

@for /f "tokens=1 delims=." %%t in ('adb shell getprop ro.build.version.release') do @set androidVersion=%%t
@echo.
@echo   Android�汾��%androidVersion%
@echo.

@echo.
@echo =================================================
@echo   �����ļ�������
@echo.

@if exist services rd /s/q services
@if exist odex rd /s/q odex
@if exist classes.dex del /q classes.dex
@if exist services.jar del /q services.jar

@echo.
@echo =================================================
@echo   ��ȡservices.jar������
@echo.

adb pull /system/framework/services.jar

@adb shell ls -lR /system/framework|find "services.odex">ls.tmp
@for /f "tokens=7" %%a in (ls.tmp) do set file=%%a
@del /q ls.tmp >nul
@if "%file%"=="services.odex" (
	if not exist odex md odex
	pushd .
	cd odex
	..\adb pull /system/framework
	popd
	
	for /f "tokens=*" %%a in ('dir /b /s services.odex') do set servicesOdexPath=%%a
	for %%a in ("!servicesOdexPath!") do set servicesOdexDir=%%~dpa
	
	for /f "tokens=*" %%a in ('dir /b /s boot.oat') do set bootOatPath=%%a
	if not exist "!bootOatPath!" (
		echo.
		echo   ����services.odex�����Ҳ���boot.oat���޷�������
		echo.
		pause
		exit /b
	)
	for %%a in ("!bootOatPath!") do set bootOatDir=%%~dpa
)

@if not exist bak md bak
@if exist services.jar copy /y services.jar bak\services.jar

@if not "%servicesOdexPath%"=="" (
	if exist odex\services.odex copy /y "%servicesOdexPath%" bak\services.odex
	
	echo.
	echo =================================================
	echo   ���ڰ�services.odexת��smali������
	echo.
	if "%androidVersion%"=="5" (
		java -Xms1g -jar oat2dex.jar boot "%bootOatPath%"
		if errorlevel 1 echo ת��boot.oat����& pause & exit /b
		java -Xms1g -jar oat2dex.jar "%servicesOdexPath%" %bootOatDir%dex
		if errorlevel 1 echo ת��services.odex����& pause & exit /b
		java -Xms1g -jar baksmali-2.2b4.jar d "%servicesOdexDir%\services.dex" -o services		
		if errorlevel 1 echo ת��services.dex����& pause & exit /b
	) else (
		java -Xms1g -jar baksmali-2.2b4.jar x -d odex "%servicesOdexPath%" -o services
		if errorlevel 1 echo ת��odex����& pause & exit /b
	)
) else (
	echo.
	echo =================================================
	echo   ���ڰ�services.jarת��smali������
	echo.
	if exist services.jar (
		java -Xms1g -jar baksmali-2.2b4.jar d services.jar -o services
		if errorlevel 1 echo ת��services.jar����& pause & exit /b
	) else (
		echo.
		echo =================================================
		echo   �޷�����services.jar/odex�������ֻ��Ƿ��������ӡ�
		echo.
		pause
		exit /b
	)
)

@echo.
@echo =================================================
@echo   ���ڰ�apkת��smali������
@echo.
@if not exist apk java -Xms1g -jar baksmali-2.2b4.jar d Brevent.apk -o apk

@echo.
@echo =================================================
@echo   ���ڴ򲹶�������
@echo.
python patch.py -a apk -s services
@if errorlevel 1 echo �򲹶�����& pause & exit /b
@echo.
@echo   ��ȷ�ϴ򲹶��Ƿ�ɹ�������ɹ��밴����������������������ֱ�ӹرձ����ߡ�
@pause >nul

@echo.
@echo =================================================
@echo   ����������������services.jar������
@echo.
java -Xms1g -jar smali-2.2b4.jar a -o classes.dex services
@if errorlevel 1 echo ���classes.dex����& pause & exit /b
jar -cvf services.jar classes.dex
@if errorlevel 1 echo ���classes.dex����& pause & exit /b

@echo.
@echo =================================================
@echo   ������ʱ�ļ�������
@echo.

@if exist services rd /s/q services
@if exist odex rd /s/q odex
@if exist classes.dex del /q classes.dex

@echo.
@echo =================================================
@echo   �������Ƿ��Ѱ�װ������
@echo.

@adb shell pm list packages|find "me.piebridge.prevent"
@if "%errorlevel%"=="1" (
	echo   ��װ���򡣡���
	echo.
	adb install Brevent.apk
)

@echo.
@echo =================================================
@echo �ϴ����ɵ�services.jar��/system/framework�С�
@echo.

adb push services.jar /sdcard/

:CHECK_ROOT
@adb shell su -c "chmod 666 /data/data/com.android.providers.contacts/databases/contacts2.db"
@for /f "tokens=1" %%a in ('adb shell ls -l /data/data/com.android.providers.contacts/databases/contacts2.db') do @set mod=%%a
@adb shell su -c "chmod 660 /data/data/com.android.providers.contacts/databases/contacts2.db"
@if not "%mod%"=="-rw-rw-rw-" (
	echo.
	echo   adbû��rootȨ�ޣ���ȷ����
	echo.
	echo   * �ֻ��Ѿ�root��
	echo.
	echo   * adb�ѻ��rootȨ�ޡ��������ֻ���Ļ����ʾ��Ҫȷ�ϣ�CMϵͳ������Ҫ�ڿ�����ѡ��������adb root��
	echo.
	echo   ���adb�޷����rootȨ�ޣ���Ҳ�����ֹ�����services.jar��/system/framework/�С�
	echo.
	pause
	goto :CHECK_ROOT
)

adb shell su -c "mount -o rw,remount /system"
adb shell su -c "cp -f /sdcard/services.jar /system/framework/"
adb shell su -c "chmod 644 /system/framework/services.jar"

@echo.
@echo =================================================
@echo   ��ɣ��ǵ������ֻ���
@echo.
@pause

@endlocal
