@echo off

	cd %~dp0 
	
	rem  origin/HEAD
	d: && cd .. && git.exe rev-parse %1