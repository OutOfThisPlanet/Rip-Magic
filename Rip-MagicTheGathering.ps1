Function Rip-MagicTheGathering
{
    param ([string]$DownloadPath, [string]$ImageSize)
    Remove-Variable * 
    cls

    Function Download-Magic
    {
        param ([Array]$TheGathering, [string]$DownloadPath, [string]$ImageSize)
        $TotalCards = $TheGathering.count

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

            if ($Magic.colors -eq "B")
            {
                $Colour = "Black"
            }
            elseif ($Magic.colors -eq "U")
            {
                $Colour = "Blue"
            }
            elseif ($Magic.colors -eq "R")
            {
                $Colour = "Red"
            }
            elseif ($Magic.colors -eq "W")
            {
                $Colour = "White"
            }
            elseif ($Magic.colors -eq "G")
            {
                $Colour = "Green"
            }

            if ($ImageSize -eq "small")
            {
                $ImageSize = "small"
            }
            elseif ($ImageSize -eq "large")
            {
                $ImageSize = "large"
            }
            elseif ($ImageSize -eq "normal")
            {
                $ImageSize = "normal"
            }
            elseif ($ImageSize -eq "png")
            {
                $ImageSize = "png"
            }
            else
            {
                $ImageSize = "large"
            }
           
            if ($Magic.edhrec_rank)
            {
                $EDHRECRank = $Magic.edhrec_rank
            }
            else
            {
                $EDHRECRank = "NoRank"
            }

            $Link = ($Magic | Select-Object -ExpandProperty image_uris | select $ImageSize).$ImageSize
            $FileNameFix = $Magic.name.Split([IO.Path]::GetInvalidFileNameChars()) -join ''
            $SetNameFix = $Magic.set_name.Split([IO.Path]::GetInvalidFileNameChars()) -join ''
            $PathStructure = "$($Year)\$($SetNameFix)\$($Colour)\$($Rarity)\$(($Reserved.Replace('-','')))\"

            if (!(Test-Path "$($DownloadPath)\$($PathStructure)"))
            {
                New-Item -Path "$($DownloadPath)\$($PathStructure)" -ItemType Directory | Out-Null
            }
            $FolderName = "\" + $PathStructure
            $Filename = ($DownloadPath) + $FolderName + "$($FileNameFix)-$($SetNameFix)-$($Year)-$($Rarity)-$($Magic.tcgplayer_id)-$($Colour)$($Reserved).jpg"

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
                    $Filename
                    Start-BitsTransfer -Source $Link -Destination $Filename -ErrorAction Stop

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
    }

    Write-Host "Download JSON file from Scryfall, this may take a while..." -ForegroundColor Red -BackgroundColor Black
    $Json = Invoke-WebRequest -Uri "https://archive.scryfall.com/json/scryfall-default-cards.json"  
    Write-Host "Converting JSON to PowerShell object, just a sec..." -ForegroundColor Red -BackgroundColor Black
    $ConvertedJson = ConvertFrom-Json -InputObject $Json 

    Write-Host "Parsing shizzle..." -ForegroundColor Red -BackgroundColor Black
    $TheGathering = $ConvertedJson | 
        where {$_.name -ne $null -and $_.image_uris -ne $null -and $_.object -eq "card" -and $_.lang -eq "en"} | 
        Select-Object `
            name, 
            set_name, 
            released_at, 
            reserved, 
            image_uris, 
            rarity,  
            colors, 
            type_line,
            collector_number,
            edhrec_rank,
            power,
            toughness,
            tcgplayer_id

    Write-Host "What image size do you want?" -ForegroundColor Red -BackgroundColor Black
    Write-Host "Choose" -ForegroundColor Red -BackgroundColor Black
    Write-Host ""
    Write-Host '"1 - Small"' -ForegroundColor Yellow -BackgroundColor Black
    Write-Host '"2 - Normal"' -ForegroundColor Yellow -BackgroundColor Black
    Write-Host '"3 - Large"' -ForegroundColor Yellow -BackgroundColor Black
    Write-Host '"4 - PNG"' -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ""

    $ImageOption = Read-Host "Pick an image size option"
    switch ($ImageOption)
    {
        1{$ImageChoice = "small"}
        2{$DownloadChoice = "normal"}
        3{$DownloadChoice = "large"}
        4{$DownloadChoice = "png"}
    }

    $ImageOption = $ImageChoice

    Write-Host "Choose" -ForegroundColor Red -BackgroundColor Black
    Write-Host ""
    Write-Host '"1 - Download Everything"' -ForegroundColor Yellow -BackgroundColor Black
    Write-Host '"2 - Download a Set"' -ForegroundColor Yellow -BackgroundColor Black 
    Write-Host '"3 - Download by Rarity"' -ForegroundColor Yellow -BackgroundColor Black
    Write-Host '"4 - Download by Year"' -ForegroundColor Yellow -BackgroundColor Black
    Write-Host '"5 - Download by Colour"' -ForegroundColor Yellow -BackgroundColor Black
    Write-Host '"6 - Download all Reserved List Cards"' -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ""

    $MainMenu = Read-Host "What do you want to download?"
    Switch ($MainMenu)
    {
    	1 {$MainChoice = "Everything"}
    	2 {$MainChoice = "Set"}
    	3 {$MainChoice = "Rarity"}
        4 {$MainChoice = "Year"}
        5 {$MainChoice = "Colour"}
        6 {$MainChoice = "Reserved"}
    }

    $MainMenu = $MainChoice

    if (!$MainMenu)
    {
        Write-Host "That was not a valid choice" 
        return;
    }

    Write-Host "Download Path not set" -ForegroundColor Red -BackgroundColor Black
    $DownloadPath = Read-Host "Please enter a download path"

    if ($MainChoice -eq "Everything")
    {
        Download-Magic -TheGathering $TheGathering -DownloadPath $DownloadPath -ImageSize $ImageSize
    }

    if ($MainChoice -eq "Set")
    {
        $Sets = ($TheGathering | select set_name).set_name | Sort-Object -Unique
        $NumberOfSets = $Sets.count
        $SetsMenu = @{}
        for ($i=1;$i -le $NumberOfSets; $i++) 
        {
            Write-Host "$i. $($Sets[$i-1])" -ForegroundColor Yellow -BackgroundColor Black
            $SetsMenu.Add($i,($Sets[$i-1]))
        }
        [int]$SetChoice = Read-Host 'Choose the number of a Magic the Gathering set you want to download'
        $ChosenSet = $SetsMenu.Item($SetChoice) 
 
        Download-Magic -TheGathering ($TheGathering | where {$_.set_name -eq $ChosenSet}) -DownloadPath $DownloadPath -ImageSize $ImageSize
    }

    if ($MainChoice -eq "Rarity")
    {
        Write-Host "Choose" -ForegroundColor Red -BackgroundColor Black
        Write-Host ""
        Write-Host '"1 - All Commons"' -ForegroundColor Yellow -BackgroundColor Black
        Write-Host '"2 - All Uncommons"' -ForegroundColor Yellow -BackgroundColor Black
        Write-Host '"3 - All Rares"' -ForegroundColor Yellow -BackgroundColor Black
        Write-Host '"4 - All Mythics"' -ForegroundColor Yellow -BackgroundColor Black
        Write-Host ""

        $RarityMenu = Read-Host "What do you want to download?"

        Switch ($RarityMenu)
        {
	    1 {$RarityChoice = "Common"}
	    2 {$RarityChoice = "Uncommon"}
	    3 {$RarityChoice = "Rare"}
            4 {$RarityChoice = "Mythic"}
        }

        $RarityMenu = $RarityChoice
        if (!$RarityMenu)
        {
            Write-Host "That was not a valid choice" 
            return;
        }

        Download-Magic -TheGathering ($TheGathering | where {$_.rarity -eq $RarityChoice}) -DownloadPath $DownloadPath -ImageSize $ImageSize
    }

    if ($MainChoice -eq "Year")
    {
        $ReleaseYears = New-Object System.Collections.Generic.List[System.Object]
        $ReleaseDates = (($TheGathering | select released_at).released_at) | Sort-Object -Unique
        foreach ($ReleaseDate in $ReleaseDates)
        {
            $ReleaseYear = $ReleaseDate.split("-")[0]
            $ReleaseYears.Add($ReleaseYear)
        }
        $ReleaseYears = $ReleaseYears | Sort-Object -Unique
        $NumberOfYears = $ReleaseYears.Count
        $YearsMenu = @{}
        for ($i=1;$i -le $NumberOfYears; $i++) 
        {
            Write-Host "$i. $($ReleaseYears[$i-1])" -ForegroundColor Yellow -BackgroundColor Black
            $YearsMenu.Add($i,($ReleaseYears[$i-1]))
        }
        [int]$YearChoice = Read-Host 'Choose the number of a Magic the Gathering release year you want to download'
        $ChosenYear = $YearsMenu.Item($YearChoice)

        Download-Magic -TheGathering ($TheGathering | where {$_.released_at -like "$ChosenYear*"}) -DownloadPath $DownloadPath -ImageSize $ImageSize
    }

    if ($MainChoice -eq "Colour")
    {
        ($TheGathering | select colors).colors | Sort-Object -Unique

        Write-Host "Choose" -ForegroundColor Red -BackgroundColor Black
        Write-Host ""
        Write-Host '"1 - White"' -ForegroundColor Yellow -BackgroundColor Black
        Write-Host '"2 - Blue"' -ForegroundColor Yellow -BackgroundColor Black
        Write-Host '"3 - Black"' -ForegroundColor Yellow -BackgroundColor Black
        Write-Host '"4 - Red"' -ForegroundColor Yellow -BackgroundColor Black
        Write-Host '"5 - Green"' -ForegroundColor Yellow -BackgroundColor Black
        Write-Host ""

        $ColourMenu = Read-Host "What colour cards do you want to download?"

        Switch ($ColourMenu)
        {
	    1 {$ColourChoice = "W"}
	    2 {$ColourChoice = "U"}
	    3 {$ColourChoice = "B"}
            4 {$ColourChoice = "R"}
            5 {$ColourChoice = "G"}
        }

        $ColourMenu = $ColourChoice
        if (!$ColourMenu)
        {
            Write-Host "That was not a valid choice" 
            return;
        }
        Download-Magic -TheGathering ($TheGathering | where {$_.color -eq $ColourChoice}) -DownloadPath $DownloadPath -ImageSize $ImageSize
    }

    if ($MainChoice -eq "Reserved")
    {
        Download-Magic -TheGathering ($TheGathering | where {$_.reserved -eq $true}) -DownloadPath $DownloadPath -ImageSize $ImageSize
    }
}

Rip-MagicTheGathering

