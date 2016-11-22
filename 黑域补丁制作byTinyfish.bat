@echo off
@setlocal EnableDelayedExpansion
@echo off

color 3f

title ���򲹶��Զ����� 2.8 by Tinyfish
echo =================================================
echo   �˽ű�һ�����������ں˲��������ܰ�����
echo   * �Զ��ϴ������ֻ��е��ں��ļ���
echo   * ��Ⲣ��ʾ��Ҫ��װ�Ļ����⡣
echo   * ���adb rootȨ�ޡ�
echo   * ���ִ���jar��odex�������
echo   * ֧��Android 4.x~7.x��
echo   * ��װ����app��
echo   * ������ʱ�ļ���
echo   * ֧���ֹ�����������

set UseAdb=1
if /i "%~1"=="NoAdb" (
	set UseAdb=0
	echo.
	echo =================================================
	echo   �ֹ���������ģʽ���룺
	echo.
	echo   * ����services.jar����ǰĿ¼��
	echo.
	echo   * �������services.odex������/system/framework/���ݵ�odexĿ¼��
	echo.
	pause
)

echo.
echo =================================================
echo   ��黷��������
echo.

:CHECK_ENV

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Python\PythonCore"
if not errorlevel 1 (
	for /f "tokens=*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Python\PythonCore"') do (
		set pythonVersionReg=%%a
		for /f "tokens=2*" %%a in ('reg query "!pythonVersionReg!\InstallPath" /ve 2^>nul') do (
			if exist "%%bpython.exe" set pythonPath=%%b
		)
	)
)

if "!pythonPath!"=="" (
	reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Python\PythonCore"
	if not errorlevel 1 (
		for /f "tokens=*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Python\PythonCore"') do (
			set pythonVersionReg=%%a
			for /f "tokens=2*" %%a in ('reg query "!pythonVersionReg!\InstallPath" /ve 2^>nul') do (
				if exist "%%bpython.exe" set pythonPath=%%b
			)
		)
	)
)

echo.
echo   Python·��: !pythonPath!
if exist "!pythonPath!python.exe" set path=!pythonPath!;!path!

where python
if errorlevel 1 (
	echo.
	echo   δ��װPython�����������ذ�װ��https://www.python.org/ftp/python/2.7.12/python-2.7.12.msi��
	echo.
	pause
	exit /b
)

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit"
if not errorlevel 1 (
	for /f "tokens=*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Development Kit"') do (
		set jdkVersionReg=%%a
		for /f "tokens=2*" %%a in ('reg query "!jdkVersionReg!" /v JavaHome 2^>nul') do (
			if exist "%%b\bin\jar.exe" set jdkPath=%%b
		)
	)
)

if "!jdkPath!"=="" (
	reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\JavaSoft\Java Development Kit"
	if not errorlevel 1 (
		for /f "tokens=*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\JavaSoft\Java Development Kit"') do (
			set jdkVersionReg=%%a
			for /f "tokens=2*" %%a in ('reg query "!jdkVersionReg!" /v JavaHome 2^>nul') do (
				if exist "%%b\bin\jar.exe" set jdkPath=%%b
			)
		)
	)
)

echo.
echo   JDK·����!jdkPath!
if exist "!jdkPath!\bin\jar.exe" set path=!jdkPath!\bin;!path!

where jar
if errorlevel 1 (
	echo.
	echo   δ��װJDK�����������ذ�װ��http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-windows-i586.exe��
	echo.
	pause
	exit /b
)

if "!UseAdb!"=="1" (
	for /f "tokens=*" %%t in ('adb get-state') do set adbState=%%t
	echo.
	echo   Adb״̬: !adbState!
	if not "!adbState!"=="device" (
		echo.
		echo   �������adb vendor id������
		call "%~dp0AddAndroidVendorID.cmd"
		adb kill-server
		ping -n 2 127.0.0.1 >nul
		
		for /f "tokens=*" %%t in ('adb get-state') do set adbState=%%t
		echo.
		echo   Adb״̬: !adbState!
		if not "!adbState!"=="device" (
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
	)

	for /f "tokens=1 delims=." %%t in ('adb shell getprop ro.build.version.release') do set androidVersion=%%t
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

if exist services rd /s/q services
if exist classes.dex del /q classes.dex

if "!UseAdb!"=="1" (
	if exist services.jar del /q services.jar
	if exist odex rd /s/q odex
)

if "!UseAdb!"=="1" (
	echo.
	echo =================================================
	echo   ��ȡservices.jar������
	echo.

	adb pull /system/framework/services.jar

	adb shell ls -lR /system/framework|find "services.odex">ls.tmp
	for /f "tokens=7" %%a in (ls.tmp) do set file=%%a
	del /q ls.tmp >nul
	if "!file!"=="services.odex" (
		if not exist odex md odex
		pushd .
		cd odex
		..\adb pull /system/framework
		popd
	)
)

if exist odex (
	for /f "tokens=*" %%a in ('dir /b /s services.odex') do set servicesOdexPath=%%a
	for %%a in ("!servicesOdexPath!") do set servicesOdexDir=%%~dpa
	set servicesOdexDir=!servicesOdexDir:~0,-1!
	
	for /f "tokens=*" %%a in ('dir /b /s boot.oat') do set bootOatPath=%%a
	if not exist "!bootOatPath!" (
		echo.
		echo   ����services.odex�����Ҳ���boot.oat���޷�������
		echo.
		pause
		exit /b
	)
	for %%a in ("!bootOatPath!") do set bootOatDir=%%~dpa
	set bootOatDir=!bootOatDir:~0,-1!
)

if not exist bak md bak
if exist services.jar copy /y services.jar bak\services.jar

if not "!servicesOdexPath!"=="" (
	if exist odex\services.odex copy /y "!servicesOdexPath!" bak\services.odex
	
	echo.
	echo =================================================
	echo   ���ڰ�services.odexת��smali������
	echo.
	if "!androidVersion!"=="5" (
		java -Xms1g -jar oat2dex.jar boot "!bootOatPath!"
		if errorlevel 1 echo ת��boot.oat����& pause & exit /b
		java -Xms1g -jar oat2dex.jar "!servicesOdexPath!" !bootOatDir!\dex
		if errorlevel 1 echo ת��services.odex����& pause & exit /b
		java -Xms1g -jar baksmali-2.2b4.jar d "!servicesOdexDir!\services.dex" -o services		
		if errorlevel 1 echo ת��services.dex����& pause & exit /b
	) else (
		java -Xms1g -jar baksmali-2.2b4.jar x -d "!bootOatDir!" "!servicesOdexPath!" -o services
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

echo.
echo =================================================
echo   ���ڰ�apkת��smali������
echo.
if not exist apk java -Xms1g -jar baksmali-2.2b4.jar d Brevent.apk -o apk

echo.
echo =================================================
echo   ���ڴ򲹶�������
echo.
python patch.py -a apk -s services
if errorlevel 1 echo �򲹶�����& pause & exit /b
echo.
echo   ��ȷ�ϴ򲹶��Ƿ�ɹ���
echo.
echo   * ע�⣡�����ٴ��˲������ܻᵼ���ֻ��޷�������������������û���⣬������ˢ����������ν������������Ͻǵ�Xֱ�ӹرձ����ߡ�
echo.
echo   * ����ɹ��밴�����������
pause >nul

echo.
echo =================================================
echo   ����������������services.jar������
echo.
java -Xms1g -jar smali-2.2b4.jar a -o classes.dex services
if errorlevel 1 echo ���classes.dex����& pause & exit /b
jar -cvf services.jar classes.dex
if errorlevel 1 echo ���classes.dex����& pause & exit /b

echo.
echo =================================================
echo   ������ʱ�ļ�������
echo.

if exist services rd /s/q services
if exist classes.dex del /q classes.dex

if "!UseAdb!"=="1" (
	if exist odex rd /s/q odex
)

if "!UseAdb!"=="1" (
	echo.
	echo =================================================
	echo   �������Ƿ��Ѱ�װ������
	echo.

	adb shell pm list packages|find "me.piebridge.prevent"
	if errorlevel 1 (
		echo   ��װ���򡣡���
		echo.
		adb install Brevent.apk
	)

	echo.
	echo =================================================
	echo �ϴ����ɵ�services.jar��/system/framework�С�
	echo.

	adb push services.jar /sdcard/

	:CHECK_ROOT
	adb shell su -c "chmod 666 /data/data/com.android.providers.contacts/databases/contacts2.db"
	for /f "tokens=1" %%a in ('adb shell su -c "ls -l /data/data/com.android.providers.contacts/databases/contacts2.db"') do set mod=%%a
	adb shell su -c "chmod 660 /data/data/com.android.providers.contacts/databases/contacts2.db"
	if not "!mod!"=="-rw-rw-rw-" (
		echo.
		echo   adbû��rootȨ�ޣ���ȷ����
		echo.
		echo   * �ֻ��Ѿ�root��
		echo.
		echo   * adb�ѻ��rootȨ�ޡ��������ֻ���Ļ����ʾ��Ҫȷ�ϣ�CMϵͳ������Ҫ�ڿ�����ѡ��������adb root��SuperSU������Ҫ�رա�������������ռ䡣
		echo.
		echo   ���adb�޷����rootȨ�ޣ���Ҳ�����ֹ�����services.jar��/system/framework/�С�
		echo.
		pause
		goto :CHECK_ROOT
	)

	adb shell su -c "mount -o rw,remount /system"
	adb shell su -c "cp -f /sdcard/services.jar /system/framework/"
	adb shell su -c "chmod 644 /system/framework/services.jar"

	echo.
	echo =================================================
	echo   ��ɣ��ǵ������ֻ���
	echo.
	pause
) else (
	echo.
	echo =================================================
	echo   ��ɣ�������ʳ��services.jar��
	echo.
	pause
)

endlocal
