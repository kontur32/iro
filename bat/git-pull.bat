@echo off

	
	rem set GITPath="C:\Users\Пользователь\Downloads\iro"
	
	rem --progress -v --no-rebase "origin"
	d: && cd .. && git.exe pull %1
	
	