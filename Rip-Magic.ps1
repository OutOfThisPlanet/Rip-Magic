$DownloadPath = "C:\temp\"
$Json = Invoke-WebRequest -Uri "https://archive.scryfall.com/json/scryfall-default-cards.json"  
$ConvertedJson = ConvertFrom-Json -InputObject $Json 

$TheGathering = $ConvertedJson | 
    where {$_.name -ne $null `
        -and $_.image_uris -ne $null `
        -and $_.object -eq "card" `
        -and $_.lang -eq "en"} | 
   Select-Object name, set_name, released_at, reserved, image_uris 

foreach ($Magic in $TheGathering)
{
    Write-Host "Downloading " -ForegroundColor Green -BackgroundColor Black -NoNewline
    write-host $Magic.name -ForegroundColor Red -BackgroundColor Black
    
    if ($DownloadPath.EndsWith("\"))
    {
        $DownloadPath = $DownloadPath.TrimEnd("\")
    }
    $Link = ($Magic | Select-Object -ExpandProperty image_uris | select large).large

    if ($Magic.rarity -eq "rare")
    {
        $Rarity = "Rare"
    }
    elseif($Magic.rarity -eq "uncommon")
    {
        $Rarity = "Uncommon"
    }
    elseif($Magic.rarity -eq "mythic")
    {
        $Rarity = "Mythic"
    }
    else
    {
        $Rarity = "Common"
    }
    if ($Magic.reserved -eq "True")
    {
        $Reserved = "-RESERVED"
    }
    else
    {
        $Reserved = ""
    }
    
    $Filename = ($DownloadPath) + "\" + "$(($Magic.name.replace("//","''")))-$($Magic.set_name)-$(((($Magic.released_at) -split "-")[0]))-$($Rarity)$($Reserved).jpg"

    try
    {
        (New-Object System.Net.WebClient).DownloadFile($Link, $FileName)
    }
    catch
    {
        try
        {
            Invoke-WebRequest -Uri $Link -OutFile $Filename
        }
        catch
        {
            Start-BitsTransfer -Source $Link -Destination $Filename
        }
    }
}





