REM This small bat file will clear temp browser files from the users profile.
REM This is useful if your browser is taking a while to load up. 
REM I also use this to remove tracking cookies which some time appear. 
cls
@Echo OFF
color F4
echo ***************************   DISCLAIMER  ********************************* 
echo Please note, Fir3net.com takes no responsibility to any damage, issues, 
echo errors or system malfunctions that may occur due to the result to taking/
echo preforming/actioning/running any of the steps, actions, guides, scripts, 
echo or registry changes held upon the fir3net.com site.
echo.
pause
color 07
echo.
echo Removing Temp Files ...... please wait 
echo.
echo ***** Removing Temp files *****
del "C:\Documents and Settings\%USERNAME%\Local settings\temp\*" /S /Q 2>NUL
del "C:\Documents and Settings\%USERNAME%\Local settings\temporary internet files\*" /S /Q 2>NUL
echo.
echo ***** Removing Firefox Temp files ******
del "C:\Documents and Settings\%USERNAME%\Local Settings\Application Data\Mozilla\Firefox\Profiles\*" /S /Q 2>NUL
echo.
echo ***** Removing Window Temp files *****
del "C:\windows\temp\*" /S /Q 2>NUL 
echo. 
echo.
echo Finished Cleaning all temp files...
ping -n 5 127.0.0.1 >NUL
