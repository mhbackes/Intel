@echo on
tasm -l trabalho
if errorlevel 1 goto end
tlink trabalho
cls
trabalho
:end