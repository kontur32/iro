@echo off

	cd %~dp0 
	
	rem  HEAD
	d: && cd .. && git.exe ls-remote origin %1