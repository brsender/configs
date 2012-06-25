@echo off

rem ___________________________________________________________________________________________________________________________________
rem	This DOS Command File will set the environment for the 
rem     Automated Build Facility(ABF). You need to assign the
rem     appropriate values to the variables as described below
rem     in order for this command file to run properly.
rem
rem 	The command to enter in your DOS Shell is:   SetEnv
rem ___________________________________________________________________________________________________________________________________

rem ____________________________________
rem	WebSphere Build Environment
rem    Set this parameter to the WebSphere Environment that your application
rem    will be built for:
rem        Currently Supported Environments are:
rem                WebSphere 3.5; Set Parameter to "3.5"
rem                Websphere 4.0; Set Parameter to "4.0"
rem                Websphere 5.0; Set Parameter to "5.0"
rem
set ABFWASBuildEnv=7.0
rem ___________________________________

rem ____________________________________
rem	Path to where you are running the ABF on your local PC.  Typically your
rem    SetEnv.cmd, and ABF.INI will reside here
rem
set ABFBuildLoc=c:\ABF7\mptapp
rem ___________________________________

rem ___________________________________
rem  	ABFArchLocation should be your PVCS VM archive location where
rem     the ABF folder resides. Typically this would be the name of
rem     your Project under the Project Database\archives\ directory.
rem     For example,
rem
rem 	   "nyldao\archives\financialcontracts".
rem
rem     If the ABF folder is a project directly under your project
rem     database then the location would be the name of your project
rem     Database\archives. For example, 
rem
rem         "nyldao\archives"
rem
set ABFArchLoc=Agency\archives\mptapp
rem ___________________________________

rem ___________________________________
rem   	ABFFolder. The name of the ABF folder containing the ABF.INI
rem     and SetVer.cmd files. Typically the folder name will be ABF
rem
set ABFFolder=ABF
rem ___________________________________

rem ___________________________________
rem  	ABFConfig should be the PVCS VM configuration file for your designated Project Database 
rem	    where the ABF folder resides.
rem
set ABFConfig=\\\nyl-prod-cfp1\tools\PVCS-VM-PDB\PDB\Agency\access\ABFMSTRPROJ.cfg
rem ___________________________________
