
Main

Sub Main
	Dim wshShell
	Dim wshProcessEnv
	Dim strArgEnv
	dim strCTDExecutable
	dim strCTDDefaultPath
	dim strLocPrefix
	
	dim strCTDAppsPath
    dim strRootDistribPath
	dim strDistribPath
	dim strDate
    dim strBuildType
		
	dim strCTDAppsPathDev
	dim strCTDAppsPathDev2
	dim strCTDAppsPathTest
	dim strCTDAppsPathTest2
	dim strCTDAppsPathDel
	dim strCTDAppsPathEmg
	dim strCTDAppsPathProd

	dim strCTDAppsPathRAFDev
	dim strCTDAppsPathRAFTest
	dim strCTDAppsPathRAFDel
	dim strCTDAppsPathRAFEmg
	dim strCTDAppsPathRAFProd
	
	Dim strComCfg
	Dim strAllPath
	Dim strOpenPath
	Dim strTempComCfg
	Dim strComCfgFileName

    Dim strJenkinsWorkspace
    
	Set wshShell = WScript.CreateObject("WScript.Shell")
	Set wshProcessEnv = wshShell.Environment("PROCESS")
    Set wshSystemEnv = wshShell.Environment("SYSTEM")

	Select Case MID(wshProcessEnv("LOGONSERVER"), 3, 2)
	   Case "ST"
		strLocPrefix = "E:\tfs\SPORT\appl"
	   Case else
		strLocPrefix = "E:\tfs\SPORT\appl"
	End Select

	if (Wscript.Arguments.Count > 0) then	    
        strProject = UCase(Wscript.Arguments(0))        
        strArgEnv = UCase(Wscript.Arguments(1)) 
        strBuildType = UCase(Wscript.Arguments(2))         	
	end if
    
    WScript.Echo "Start building " + strProject + " from branch " + strArgEnv   
    
    strJenkinsWorkspace = wshProcessEnv("WORKSPACE")
    WScript.Echo "Workspace:" + strJenkinsWorkspace

    ' add project spesific var
    if strProject = "BRIO" then                
		    wshProcessEnv("PATH") = strLocPrefix + "\Source\Support\Ctd52;" & wshProcessEnv("PATH")		    
            strCTDDefaultPath = strLocPrefix + "\Source\Support\Ctd52;" + strJenkinsWorkspace + "\Bitmap;" + "C:\Appl\Unify\TD52\Xsal2;C:\Appl\Unify\TD52\LIB;C:\Appl\Unify\TD52\Xsal2\52;C:\Appl\Unify\TD52;C:\Appl\Unify\TD52\Samples;C:\Appl\Unify\TD52\Samples\CDK\CDKSal"        
    elseif strProject = "RAF" then
        if strArgEnv = "MAIN" or strArgEnv = "DEV" Then		                
            wshProcessEnv("PATH") = strLocPrefix + "\Source\Support\Ctd52;" & wshProcessEnv("PATH")	                
            strCTDDefaultPath = strLocPrefix + "\Source\Support\Ctd52;" + strJenkinsWorkspace + "\Support\Pictures;" + strJenkinsWorkspace + "\Support\Lib;" + "C:\Appl\Unify\TD52\Xsal2;C:\Appl\Unify\TD52\LIB;C:\Appl\Unify\TD52\Xsal2\52;C:\Appl\Unify\TD52;C:\Appl\Unify\TD52\Samples;C:\Appl\Unify\TD52\Samples\CDK\CDKSal"            
	    end if	
    end if   

    WScript.Echo "strCTDDefaultPath: " + strCTDDefaultPath

    ' compile executable
	strCTDExecutable= """C:\Appl\Unify\TD52\cbi52.exe"""
    
    if strBuildType = "CI" then
        strRootDistribPath = "E:\tfs\SPORT\appl\Build52\CI"
    elseif strBuildType = "MAN" then 
        strRootDistribPath = "E:\tfs\SPORT\appl\Build52\MAN"
    end if


    if strProject = "BRIO"  then
        ' source dir SPORT
        strCTDAppsPath = strJenkinsWorkspace + "\Centura"     
        strOpenPath = strCTDAppsPath
		strAllPath = strCTDAppsPath   + ";" + strCTDDefaultPath
		strCTDAppsPath = strCTDAppsPath
        ' set distr var based on what we build
        strDistribPath = strRootDistribPath + "\Brio\" + strArgEnv        
    elseif strProject = "RAF" then
	    ' source dir RAF
        strCTDAppsPathRAF = strJenkinsWorkspace + "\source"            
        strAllPath = strCTDAppsPathRAF  + ";" + strCTDDefaultPath
		strCTDAppsPath = strCTDAppsPathRAF
        strDistribPath = strRootDistribPath + "\Raf\" + strArgEnv        
    end if    
        
    WScript.Echo "strAllPath: " + strAllPath
	wshShell.RegWrite "HKCU\Software\Unify\SQLWindows 5.2\Settings\IncludePath", strAllPath
	
    strDate = stringDate() 
	if strDate = "" Then 'Cancel
		WScript.Quit
    end if
    
    ' Build !!!
    WScript.Echo "Start building " + strProject + "(" + strDate + ") Branch("+ strArgEnv + ")..."
    WScript.Echo "Distribution path(" + strDistribPath + ") " + "strCTDAppsPath(" + strCTDAppsPath + ")..."
    if strProject = "BRIO" Then                		
        WScript.Echo "Start building SportOperataions" + strDate + ".EXE ...."        
        call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\SportOperations.apt " + strDistribPath + "\SportOperations" + strDate + ".EXE", 1, TRUE )        
		WScript.Echo "Start building SPMA" + strDate + ".EXE ...."
        call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\SPMA.apt " + strDistribPath + "\SPMA" + strDate + ".EXE", 1, TRUE )
		WScript.Echo "Start building SPAC" + strDate + ".EXE ...."
        call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\SPAC.apt " + strDistribPath + "\SPAC" + strDate + ".EXE", 1, TRUE )
		WScript.Echo "Start building SPKM" + strDate + ".EXE ...."
		call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\SPKM.apt " + strDistribPath + "\SPKM" + strDate + ".EXE", 1, TRUE )
		WScript.Echo "Start building SportLet" + strDate + ".EXE ...."
		call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\Sportlet.apt " + strDistribPath + "\Sportlet." + strDate + ".EXE", 1, TRUE )
		WScript.Echo "Start building SPTE" + strDate + ".EXE ...."  
		call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\SPTE.apt " + strDistribPath + "\SPTE" + strDate + ".EXE", 1, TRUE )
		WScript.Echo "Start building SPNF" + strDate + ".EXE ...."
		call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\SPNF.apt " + strDistribPath + "\SPNF" + strDate + ".EXE", 1, TRUE )		
        'WScript.Echo "Start building SPPO" + strDate + ".EXE ...."
		'call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\SPPO.apt " + strDistribPath + "\SPPO" + strDate + ".EXE", 1, TRUE )
		WScript.Echo "Start building SPSD" + strDate + ".EXE ...."
		call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\SPSD.apt " + strDistribPath + "\SPSD" + strDate + ".EXE", 1, TRUE )
		WScript.Echo "Start building SPUA" + strDate + ".EXE ...."
		call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\SPUA.apt " + strDistribPath + "\SPUA" + strDate + ".EXE", 1, TRUE )	
		WScript.Echo "Start building SPORT.EXE ...."
		call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\SPORT.apt " + strDistribPath + "\SPORT.EXE", 1, true)   		
		WScript.Echo "Start building SPDEMURRAGE" + strDate + ".EXE ...."
		call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\SPDEMURRAGE.apt " + strDistribPath + "\SPDEMURRAGE" + strDate + ".EXE", 1, TRUE )	
	elseif strProject = "RAF" Then        	    
		WScript.Echo "Start building SPRA" + strDate + ".EXE ...."        
		call wshShell.Run ( strCTDExecutable + " -b " + strCTDAppsPath + "\STARTAPP.apt " + strDistribPath + "\SPRA" + strDate + ".EXE", 1, TRUE )		        	    
	end if	    
    WScript.Echo "Check for compile errors..." 
    WScript.Quit
End Sub


Function stringDate

    Dim nYear, nMonth, nDay
    Dim strYear, strMonth, strDay

    strYear = CStr(Year(Date))

    nMonth = Month(Date)
    if nMonth < 10 Then
       strMonth = "0" + CStr(nMonth)
    else
       strMonth = CStr(nMonth)
    end if

    nDay = Day(Date)
    if nDay < 10 Then
        strDay = "0" + CStr(nDay)
    else
        strDay = CStr(nDay)
    end if
    
    stringDate = strYear + strMonth + strDay

End Function
