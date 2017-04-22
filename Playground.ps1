
function Write($text, $wait = $false){

    if ( $wait ){
        Read-Host -Prompt $text;
    }else{
        Write-Host $text;
    }
}

function HI {
    Write-Host "Hellohello"
}

function Get-FileName($initialDirectory = $PSScriptRoot){
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null

    try{
        Test-Path -Path $OpenFileDialog.FileName
    }catch{
        Write "Noo"
    }
    

    $OpenFileDialog.FileName
}

$Hostname = [system.environment]::MachineName

Try{
    $XML = [xml] (Get-Content "\\tsclient\D6\UberGADS.xml")
    $School = ($XML.Schools.School | where {$_.HostName -eq $Hostname}).Shortname
    $SyncCMD = ($XML.Schools.School | where {$_.ShortName -eq $School}).SyncCMD.EXE
    $Config = ($XML.Schools.School | where {$_.ShortName -eq $School}).GCDS.Config
    $Report = ($XML.Schools.School | where {$_.ShortName -eq $School}).GCDS.Report
    $Log = ($XML.Schools.School | where {$_.ShortName -eq $School}).GCDS.Log
    $User = ($XML.Schools.School | where {$_.ShortName -eq $School}).SyncCMD.User
}
Catch{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Error "Something failed parsing the XML-File\n" $ErrorMessage $FailedItem
}
function RequestPassword{

    $Password = Read-Host -AsSecureString -Prompt "Please enter the password for Account $User" | ConvertTo-SecureString -Force -AsPlainText
    $global:Cred = new-Object System.Management.Automation.PSCredential -ArgumentList $User , $Password

}

<#PSScriptInfo  
.DESCRIPTION  
    Simulates an Authentication Request in a Domain envrionment using a PSCredential Object. Returns $true if both Username and Password pair are valid.  
.VERSION  
    1.3 
.GUID  
    6a18515f-73d3-4fb4-884f-412395aa5054  
.AUTHOR  
    Thomas Malkewitz @dotps1  
.TAGS  
    PSCredential, Credential 
.RELEASENOTES  
    Updated $Domain default value to $Credential.GetNetworkCredential().Domain. 
    Added support for multipul credential objects to be passed into $Credential. 
.PROJECTURI 
    http://dotps1.github.io 
 #> 
 
Function Test-Credential { 
    [OutputType([Bool])] 
     
    Param ( 
        [Parameter( 
            Mandatory = $true, 
            ValueFromPipeLine = $true, 
            ValueFromPipelineByPropertyName = $true 
        )] 
        [Alias( 
            'PSCredential' 
        )] 
        [ValidateNotNull()] 
        [System.Management.Automation.PSCredential] 
        [System.Management.Automation.Credential()] 
        $Credential, 
 
        [Parameter()] 
        [String] 
        $Domain = $Credential.GetNetworkCredential().Domain 
    ) 
 
    Begin { 
        [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement") | 
            Out-Null 
 
        $principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext( 
            [System.DirectoryServices.AccountManagement.ContextType]::Domain, $Domain 
        ) 
    } 
 
    Process { 
        foreach ($item in $Credential) { 
            $networkCredential = $Credential.GetNetworkCredential() 
             
            Write-Output -InputObject $( 
                $principalContext.ValidateCredentials( 
                    $networkCredential.UserName, $networkCredential.Password 
                ) 
            ) 
        } 
    } 
 
    End { 
        $principalContext.Dispose() 
    } 
} 

#$pw = Read-Host -AsSecureString "Please enter the GCDS-User password"
#$pw = ConvertTo-SecureString -String "Cl0udm@st3r" -Force -AsPlainText 

#$pw = Read-Host -AsSecureString "Please enter the GCDS-User password"
#ConvertTo-SecureString -String $pw -Force -AsPlainText | ConvertFrom-SecureString

    $Password = Read-Host -AsSecureString -Prompt "Please enter the password for Account $User"
    $Cred = new-Object System.Management.Automation.PSCredential -ArgumentList $User , $Password

   Write ( Test-Credential $Cred)

exit 1

$cred = "foo"

RequestPassword $User

write $cred

$test = Test-Credential $cred "EPS"

write $cred.GetNetworkCredential().Password


write $test
exit 1
Start-Process $SyncCMD -Credential $cred -ArgumentList "-c $Config -r $Log"

