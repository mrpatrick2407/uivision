###########################################################################
#Script to run RPA macros from within Powershell

#Make sure to install the native RPA app (XModules): https://ui.vision/rpa/x
###########################################################################


function PlayAndWait2 ([string]$macro, [string]$close)
{


$timeout_seconds = 60 #max time in seconds allowed for macro to complete (change this value if  your macros takes longer to run)
$path_downloaddir = "C:\Users\rtheophilus\Downloads\" #where the kantu log file is stored ("downloaded") *THIS MUST BE THE BROWSER DOWNLOAD FOLDER*, as specified in the browser settings
$path_autorun_html = "C:\Users\rtheophilus\Downloads\ui.vision.html"

#Optional: Kill Chrome instances (if any open)
#taskkill /F /IM chrome.exe /T 

#Create log file. Here the RPA software will store the result of the macro run
$log = "log_" + $(get-date -f MM-dd-yyyy_HH_mm_ss) + ".txt" 
$path_log = $path_downloaddir + $log 


#Build command line (1=CHROME, 2=FIREFOX, 3=EDGE)
$browser = 3
Switch ($browser) {
1 {$cmd = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"; break}
2 {$cmd = "${env:ProgramFiles}\Mozilla Firefox\firefox.exe"; break} #For FIREFOX
3 {$cmd = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"; break} #For EDGE 
}

$arg = """file:///"+ $path_autorun_html + "?macro="+ $macro + "&storage=xfile&direct=1&closeRPA="+$close+"&closeBrowser="+$close1+"&savelog="+$log+""""


Start-Process -FilePath $cmd -ArgumentList $arg #Launch the browser and run the macro

#############Wait for macro to complete => Wait for log file to appear in download folder
$status_runtime = 0
Write-Host  "Log file will show up at " + $path_log
while (!(Test-Path $path_log) -and ($status_runtime -lt $timeout_seconds)) 
{ 
    Write-Host  "Waiting for macro to finish, seconds=" $status_runtime
    Start-Sleep 1
    $status_runtime = $status_runtime + 1 
}


#Macro done - or timeout exceeded:
if ($status_runtime -lt $timeout_seconds)
{
    #Read FIRST line of log file, which contains the status of the last run
    $status_text = Get-Content $path_log -First 1


    #Check if macro completed OK or not
    $status_int = -1     
    If ($status_text -contains "Status=OK") {$status_int = 1}

}
else
{
    $status_text =  "Macro did not complete within the time given:" + $timeout_seconds
    $status_int = -2
    #Cleanup => Kill Chrome instance 
    #taskkill /F /IM chrome.exe /T   
}

remove-item $path_log #clean up
return $status_int, $status_text, $status_runtime
}


###########################################################################
#        Main program starts here
###########################################################################

$testreport = "C:\Users\rtheophilus\Downloads\testreport.txt"



$path1 = "robot\NewWindow\NewWindow.json" #C:\Users\a9\Desktop\uivision\macros = RPA home folder (as set in XModule tab)

$path2 = "robot\NewWindow\NewTab.json"


############
# Macro 1  #
############

$result = PlayAndWait2 $path1 0 #0=keep browser open, so next macro continues in same tab.
$errortext = $result[1] #Get error text or OK
$runtime = $result[2] #Get runtime
$report = "Macro1 runtime: ("+$runtime+" seconds), result: "+ $errortext
Write-Host $report
Add-content $testreport -value ($report)


$result = PlayAndWait2 $path2 0 #0=keep browser open, so next macro continues in same tab.
$errortext = $result[1] #Get error text or OK
$runtime = $result[2] #Get runtime
$report = "Macro2 runtime: ("+$runtime+" seconds), result: "+ $errortext
Write-Host $report
Add-content $testreport -value ($report)






