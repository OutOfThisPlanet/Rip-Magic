$DownloadPath = "C:\temp\"
$Json = Invoke-WebRequest -Uri "https://archive.scryfall.com/json/scryfall-default-cards.json"  
$ConvertedJson = ConvertFrom-Json -InputObject $Json 

$TheGathering = $ConvertedJson | 
    where {$_.name -ne $null -and $_.image_uris -ne $null -and $_.object -eq "card" -and $_.lang -eq "en"} | 
    Select-Object name, 
                    set_name, 
                    released_at, 
                    reserved, 
                    image_uris, 
                    rarity, 
                    mana_cost, #The mana cost for this card. This value will be any empty string "" if the cost is absent. Remember that per the game rules, a missing mana cost and a mana cost of {0} are different values. 
                    layout, 
                    colors, #This card’s colors, if the overall card has colors defined by the rules
                    color_identity, 
                    oracle_text, 
                    type_line, #The type line of this card.
                    loyalty, #This loyalty if any. Note that some cards have loyalties that are not numeric, such as X.
                    legalities, #Possible legalities are legal, not_legal, restricted, and banned.
                    cmc, #The card’s converted mana cost. Note that some funny cards have fractional mana costs.
                    edhrec_rank, #This card’s overall rank/popularity on EDHREC. Not all cards are ranked.
                    collector_number #This card’s collector number. Note that collector numbers can contain non-numeric characters, such as letters or ★.

$TotalCards = $TheGathering.count

$FailedDownloads = @{}

foreach ($Magic in $TheGathering)
{  
    $TotalCards = $TotalCards - 1

    if ($DownloadPath.EndsWith("\"))
    {
        $DownloadPath = $DownloadPath.TrimEnd("\")
    }
      
    if ($Magic.reserved -eq "True")
    {
        $Reserved = "-RESERVED"
    }
    else
    {
        $Reserved = ""
    }
  
    $Rarity = ((Get-Culture).TextInfo).ToTitleCase($Magic.rarity)
    $Year = ((($Magic.released_at) -split "-")[0])

    $Link = ($Magic | Select-Object -ExpandProperty image_uris | select large).large

    $FilenameFix = $Magic.name.Split([IO.Path]::GetInvalidFileNameChars()) -join ''
    $Filename = ($DownloadPath) + "\" + "$($FilenameFix)-$($Magic.set_name)-$($Year)-$($Rarity)$($Reserved).jpg"

    if (!(Test-Path $Filename))
    {
        Write-Host "$TotalCards " -ForegroundColor Gray -BackgroundColor Black -NoNewline
        Write-Host "Downloading " -ForegroundColor Green -BackgroundColor Black -NoNewline
        write-host $Magic.name "" -ForegroundColor Red -BackgroundColor Black -NoNewline
        Write-Host $Rarity "" -ForegroundColor Yellow -BackgroundColor Black -NoNewline
        Write-Host $Magic.set_name "" -ForegroundColor DarkMagenta -BackgroundColor Black -NoNewline
        Write-Host $Reserved -ForegroundColor Cyan -BackgroundColor Black
        
        try
        {
            (New-Object System.Net.WebClient).DownloadFile($Link, $FileName)
        }
        catch
        {
            try
            {
                Start-BitsTransfer -Source $Link -Destination $Filename
            }
            catch
            {
                Write-Host "Failed Download" -ForegroundColor Red -BackgroundColor Black 
                $FailedDownloads.Add($Link,$Filename)
            }
        }
    }
    else
    {
        Write-Host "$TotalCards " -ForegroundColor Gray -BackgroundColor Black -NoNewline
        Write-Host "Skipping " -ForegroundColor Green -BackgroundColor Black -NoNewline
        Write-Host $Magic.name ""  -ForegroundColor Red -BackgroundColor Black -NoNewline
        Write-Host $Rarity "" -ForegroundColor Yellow -BackgroundColor Black -NoNewline
        Write-Host $Magic.set_name "" -ForegroundColor DarkMagenta -BackgroundColor Black -NoNewline
        Write-Host $Reserved -ForegroundColor Cyan -BackgroundColor Black
    }
}
