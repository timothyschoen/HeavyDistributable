:: Get daisy toolchain, containing the arm compiler and more utils
git clone --recursive https://github.com/electro-smith/DaisyToolchain

mkdir "Heavy"

:: Expand minGW environment, for command line utilities and compilation utilities
powershell -Command "Expand-Archive resources\minGW.zip -Force -DestinationPath .\Heavy"

copy resources\heavy-static.a Heavy\lib\heavy-static.a
copy resources\daisy_makefile Heavy\etc\daisy_makefile
xcopy /E /H /C /I resources\usb_driver Heavy\etc\usb_driver

:: Remove unnecessary target platforms from compiler
mkdir "Heavy\arm-none-eabi\lib\temp"
move "Heavy\arm-none-eabi\lib\thumb\v7e-m+dp" "Heavy\arm-none-eabi\lib\temp\v7e-m+dp"
rmdir /S /Q "Heavy\arm-none-eabi\lib\thumb"
rename "Heavy\arm-none-eabi\lib\temp" "thumb"

mkdir "Heavy\lib\gcc\arm-none-eabi\12.2.0\temp"
move "Heavy\lib\gcc\arm-none-eabi\12.2.0\thumb\v7e-m+dp" "Heavy\lib\gcc\arm-none-eabi\12.2.0\temp\v7e-m+dp"
rmdir /S /Q "Heavy\lib\gcc\arm-none-eabi\12.2.0\thumb"
rename "Heavy\lib\gcc\arm-none-eabi\12.2.0\temp" "thumb"

del /S /Q ".\Heavy\arm-none-eabi\lib\arm"

:: Pre-build libdaisy
cd libDaisy

echo ../Heavy/bin/make.exe GCC_PATH=../Heavy/bin> build.sh
..\Heavy\bin\sh.exe --login build.sh
cd ..

xcopy /E /H /C /I libDaisy Heavy\lib\libDaisy
xcopy /E /H /C /I DPF Heavy\lib\DPF

:: Package heavy using pyinstaller
python -m ensurepip
python -m pip install hvcc
python -m pip install pyinstaller

FOR /F "tokens=*" %%g IN ('python -m site --user-site') do (SET PYTHON_SITE=%%g)

python resources\run_pyinstaller.py -n Heavy --noconfirm  --windowed --paths %PYTHON_SITE% .\hvcc\hvcc\__init__.py --collect-data json2daisy --add-data=".\hvcc\hvcc\generators;.\generators" --add-data=".\hvcc\hvcc\core;.\hvcc\core" --add-data=".\hvcc\hvcc\generators;.\hvcc\generators" --add-data=".\hvcc\hvcc\interpreters;.\hvcc\interpreters"

copy .\dist\Heavy\json2daisy\resources\component_defs.json .\dist\Heavy\json2daisy\resources\seed.json
move .\dist\Heavy .\Heavy\bin\

del /s /q .\dist\*
del /s /q .\build\*
del /s /q .\__init__.spec

cp VERSION Heavy\VERSION