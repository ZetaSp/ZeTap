@echo off
if "test%1"=="test" echo Please load a script file.&pause&exit
vim -N -u NONE -n -S "zetap.vim" %1