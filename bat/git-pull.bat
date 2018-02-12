@echo off

	cd %~dp0 
	rem --progress -v --no-rebase "origin"
	d: && cd .. && git.exe pull %1
	
	
	
	
	
	