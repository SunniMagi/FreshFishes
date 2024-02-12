#Nye brukere
$FreshFishes = Import-Csv -Path 'C:\Froya\Navn.csv'
#funksjon for å sjekke om brukeren finnes i ActiveDirectory
function CheckIfUserExists($username) 
{
    $user = Get-ADUser -Identity $username #denne lar seg ikke affektere av en -ErrorAction SilentlyContinue
    
    return $user -ne $null
}

#Funksjon for å legge til tall etter ikkeunike brukernavn
function AddSuffix($UserName, $suffix) 
{
    $evaluateName = $UserName
    if ($suffix -gt 0) {
        $evaluateName = $UserName + $suffix
    }
    if (CheckIfUserExists $evaluateName) {
        $suffix++
        return AddSuffix $UserName $suffix
    }
    Return $evaluateName
}
function MakeSafeNEW 
{
    param(
        [string]$inputString
    )
    [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($inputString))
}
#Her starter vi:
ForEach ($row in $FreshFishes) 
{
    #hent ut navn fra FreshFishes
    $firstName = $row.GivenName
    $lastName = $row.Surname
    #lag brukernavn av for- og etternavn
    $UserName = ($firstName.Substring(0, 2).ToLower()) + ($lastName.Substring(0, 3).ToLower())
    #Sjekk for spesialkarakterer
    $UserName = MakeSafeNEW $UserName
    #etabler brukernavn og sjekk at det er unikt
    $UserName = AddSuffix $UserName
    #legg til passordpolicy og legg til i AD
    $password = ConvertTo-SecureString -String "Passw0rd!" -AsPlainText -Force
    New-ADUser -Name $UserName -GivenName $firstName -SamAccountName $UserName -Surname $lastName -Enabled $true -Path "OU=Users, OU=Froya, DC=Fiske, DC=net" -AccountPassword $password -ChangePasswordAtLogon 1
    Write-Host $username
}
