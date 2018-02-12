@echo off

	
	set GITPath="C:\Users\Пользователь\Documents\webapp\iro"
	
	rem --progress -v --no-rebase "origin"
	d: && cd %GITPath%\ && git.exe pull %1
	
	