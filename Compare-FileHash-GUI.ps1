<#
    Compare-FileHash 2.0

    Prüft Dateien gegen:
    - Checksum-Dateien
    - manuelle Hashwerte

    Unterstützt:
    - MD5
    - SHA1
    - SHA256
    - SHA384
    - SHA512

    Bedienung:
    - Datei per Drag & Drop
    - Checksum-Datei optional per Drag & Drop
	
	Funktionen:
    - manueller Hashvergleich
    - automatische Algorithmuserkennung
    - Checksum-Datei Parsing
    - Ergebnisanzeige
    - Logging
    - Reset-Funktion
#>


############################################################
# Bibliotheken laden
############################################################

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing



############################################################
# Globale Variablen
############################################################

$script:SelectedFile = $null

$script:ChecksumFile = $null


$script:LogFile =
Join-Path `
    (Split-Path `
    -Parent `
    $MyInvocation.MyCommand.Path) `
    "HashCheck.log"



############################################################
# Hauptfenster
############################################################

$form =
New-Object System.Windows.Forms.Form


$form.Text =
"Compare File Hash 2.1"


$form.Size =
New-Object System.Drawing.Size(780,780)


$form.StartPosition =
"CenterScreen"



############################################################
# Label-Hilfsfunktion
############################################################

function Add-Label
{
    param(
        [string]$Text,
        [int]$X,
        [int]$Y
    )


    $Label =
    New-Object System.Windows.Forms.Label


    $Label.Text =
    $Text


    $Label.Location =
    New-Object System.Drawing.Point($X,$Y)


    $Label.AutoSize =
    $true


    $form.Controls.Add($Label)

}



############################################################
# Drag & Drop TextBox
#
# funktionierende Version
# mit fester Referenz über param()
############################################################

function Add-DropBox
{
    param(
        [int]$X,
        [int]$Y,
        [string]$Type
    )


    $Box =
    New-Object System.Windows.Forms.TextBox


    $Box.Location =
    New-Object System.Drawing.Point($X,$Y)


    $Box.Size =
    New-Object System.Drawing.Size(720,50)


    $Box.Multiline =
    $true


    $Box.ReadOnly =
    $true


    $Box.AllowDrop =
    $true


    $Box.BackColor =
    [System.Drawing.Color]::White



    # Kennzeichnung:
    # FILE oder CHECKSUM

    $Box.Tag =
    $Type



    $Box.Add_DragEnter({

        if(
        $_.Data.GetDataPresent(
        [Windows.Forms.DataFormats]::FileDrop
        ))
        {

            $_.Effect =
            [Windows.Forms.DragDropEffects]::Copy

        }

    })



    $Box.Add_DragDrop({

        param($sender,$event)



        $Files =
        $event.Data.GetData(
        [Windows.Forms.DataFormats]::FileDrop
        )


        if(
        $Files.Count -gt 0
        )
        {

            $File =
            $Files[0]


            $sender.Text =
            $File



            if(
            $sender.Tag -eq "FILE"
            )
            {

                $script:SelectedFile =
                $File

            }



            if(
            $sender.Tag -eq "CHECKSUM"
            )
            {

                $script:ChecksumFile =
                $File

            }

        }

    })


    $form.Controls.Add($Box)


    return $Box

}



############################################################
# Prüfling
############################################################

Add-Label `
"1. Datei zum Prüfen (Drag & Drop)" `
20 `
20


$fileBox =
Add-DropBox `
20 `
45 `
"FILE"



############################################################
# Checksum-Datei
############################################################

Add-Label `
"2. Checksum-Datei optional (Drag & Drop)" `
20 `
120


$checksumBox =
Add-DropBox `
20 `
145 `
"CHECKSUM"



############################################################
# Manueller Hash
############################################################

Add-Label `
"Manueller Hashwert optional" `
20 `
220


$hashBox =
New-Object System.Windows.Forms.TextBox


$hashBox.Location =
New-Object System.Drawing.Point(20,245)


$hashBox.Size =
New-Object System.Drawing.Size(720,25)


$form.Controls.Add($hashBox)



############################################################
# Algorithmus Auswahl
############################################################

Add-Label `
"Algorithmus bei manueller Eingabe" `
20 `
290


$algorithmBox =
New-Object System.Windows.Forms.ComboBox


$algorithmBox.Location =
New-Object System.Drawing.Point(20,315)


$algorithmBox.Width =
150


$algorithmBox.Items.AddRange(
@(
"MD5",
"SHA1",
"SHA256",
"SHA384",
"SHA512"
))


$algorithmBox.SelectedItem =
"SHA256"


$form.Controls.Add($algorithmBox)



############################################################
# Prüfen Button
############################################################

$button =
New-Object System.Windows.Forms.Button


$button.Text =
"Hash vergleichen"


$button.Location =
New-Object System.Drawing.Point(220,310)


$button.Size =
New-Object System.Drawing.Size(180,35)


$form.Controls.Add($button)



############################################################
# Reset Button
############################################################

$resetButton =
New-Object System.Windows.Forms.Button


$resetButton.Text =
"Zurücksetzen"


$resetButton.Location =
New-Object System.Drawing.Point(420,310)


$resetButton.Size =
New-Object System.Drawing.Size(150,35)


$form.Controls.Add($resetButton)



############################################################
# Ergebnisanzeige
############################################################

$resultBox =
New-Object System.Windows.Forms.TextBox


$resultBox.Location =
New-Object System.Drawing.Point(20,380)


$resultBox.Size =
New-Object System.Drawing.Size(720,300)


$resultBox.Multiline =
$true


$resultBox.ReadOnly =
$true


# wichtig:
# lange Hashwerte und Pfade sichtbar machen

$resultBox.ScrollBars =
"Both"


$resultBox.WordWrap =
$false


$form.Controls.Add($resultBox)



############################################################
# Funktion:
# Bereinigt Dateinamen für Vergleiche
############################################################

function Normalize-FileName
{
    param(
        [string]$Name
    )


    if(
    [string]::IsNullOrWhiteSpace($Name)
    )
    {
        return ""
    }


    $Name =
    $Name.Trim()


    $Name =
    $Name.Trim("*")


    $Name =
    $Name.Trim()



    if(
    $Name.StartsWith("./")
    )
    {
        $Name =
        $Name.Substring(2)
    }



    return (
        Split-Path `
        $Name `
        -Leaf
    )

}



############################################################
# Funktion:
# Algorithmus anhand Hashlänge erkennen
############################################################

function Detect-AlgorithmFromHash
{
    param(
        [string]$Hash
    )


    switch(
    $Hash.Length
    )
    {

        32
        {
            return "MD5"
        }


        40
        {
            return "SHA1"
        }


        64
        {
            return "SHA256"
        }


        96
        {
            return "SHA384"
        }


        128
        {
            return "SHA512"
        }

    }


    return $null

}



############################################################
# Funktion:
# Vergleicht Dateinamen
############################################################

function Compare-ChecksumFileName
{
    param(
        [string]$ChecksumName,
        [string]$TargetFile
    )


    $ChecksumName =
    Normalize-FileName `
    $ChecksumName



    $TargetName =
    Normalize-FileName `
    (
        Split-Path `
        $TargetFile `
        -Leaf
    )


    return (
        $ChecksumName `
        -eq `
        $TargetName
    )

}



############################################################
# Funktion:
# Liest Hash aus Checksum-Datei
############################################################

function Get-ChecksumInformation
{
    param(
        [string]$ChecksumPath,
        [string]$TargetFile
    )


    if(
    -not(Test-Path $ChecksumPath)
    )
    {
        return $null
    }



    $Lines =
    Get-Content `
    -Path $ChecksumPath `
    -Encoding UTF8



    foreach(
    $Line in $Lines
    )
    {

        if(
        [string]::IsNullOrWhiteSpace($Line)
        )
        {
            continue
        }



        ####################################################
        # Format:
        #
        # SHA256 (Datei.iso) = HASH
        #
        ####################################################

        if(
        $Line -match
        "^(SHA\d+|MD5)\s+\((.+)\)\s*=\s*([A-Fa-f0-9]{32,128})"
        )
        {

            $Algorithm =
            $Matches[1].ToUpper()


            $FileName =
            $Matches[2]


            $Hash =
            $Matches[3].ToUpper()



            if(
            Compare-ChecksumFileName `
            $FileName `
            $TargetFile
            )
            {

                return @{
                    Hash =
                    $Hash

                    Algorithm =
                    $Algorithm
                }

            }

        }



        ####################################################
        # GNU Format:
        #
        # HASH *Datei.iso
        #
        ####################################################

        if(
        $Line -match
        "^([A-Fa-f0-9]{32,128})\s+\*?(.+)$"
        )
        {

            $Hash =
            $Matches[1].ToUpper()


            $FileName =
            $Matches[2]



            if(
            Compare-ChecksumFileName `
            $FileName `
            $TargetFile
            )
            {

                return @{
                    Hash =
                    $Hash

                    Algorithm =
                    Detect-AlgorithmFromHash `
                    $Hash
                }

            }

        }



        ####################################################
        # Einfaches Format:
        #
        # HASH Datei.iso
        #
        ####################################################

        if(
        $Line -match
        "^([A-Fa-f0-9]{32,128})\s+(.+)$"
        )
        {

            $Hash =
            $Matches[1].ToUpper()


            $FileName =
            $Matches[2]



            if(
            Compare-ChecksumFileName `
            $FileName `
            $TargetFile
            )
            {

                return @{
                    Hash =
                    $Hash

                    Algorithm =
                    Detect-AlgorithmFromHash `
                    $Hash
                }

            }

        }


    }


    return $null

}



############################################################
# Funktion:
# Manuellen Hashwert verarbeiten
############################################################

function Get-ManualHashInformation
{
    param(
        [string]$Hash,
        [string]$Algorithm
    )


    if(
    [string]::IsNullOrWhiteSpace($Hash)
    )
    {
        return $null
    }



    $Hash =
    $Hash.Trim().ToUpper()



    if(
    [string]::IsNullOrWhiteSpace($Algorithm)
    )
    {
        $Algorithm =
        Detect-AlgorithmFromHash `
        $Hash
    }



    if(
    [string]::IsNullOrWhiteSpace($Algorithm)
    )
    {
        return $null
    }



    return @{
        Hash =
        $Hash

        Algorithm =
        $Algorithm
    }

}




############################################################
# Button:
# Hashvergleich starten
############################################################

$button.Add_Click({

    try
    {

        ####################################################
        # Prüfen ob Datei vorhanden ist
        ####################################################

        if(
        [string]::IsNullOrWhiteSpace(
        $script:SelectedFile
        )
        )
        {
            throw "Keine Datei zum Prüfen ausgewählt."
        }



        if(
        -not(Test-Path $script:SelectedFile)
        )
        {
            throw "Die Datei existiert nicht."
        }



        ####################################################
        # Erwarteten Hash ermitteln
        #
        # Priorität:
        #
        # 1. Checksum-Datei
        # 2. manueller Hash
        #
        ####################################################

        $ExpectedInformation =
        $null


        $ChecksumDisplay = "Hashwert wurde kopiert"


        if(
        -not(
        [string]::IsNullOrWhiteSpace(
        $script:ChecksumFile
        )
        )
        )
        {

            $ChecksumDisplay =
            $script:ChecksumFile



            $ExpectedInformation =
            Get-ChecksumInformation `
            -ChecksumPath `
            $script:ChecksumFile `
            -TargetFile `
            $script:SelectedFile



            if(
            $null -eq $ExpectedInformation
            )
            {
                throw "Kein passender Hash in der Checksum-Datei gefunden."
            }

        }
        else
        {

            $ExpectedInformation =
            Get-ManualHashInformation `
            -Hash `
            $hashBox.Text `
            -Algorithm `
            $algorithmBox.SelectedItem



            if(
            $null -eq $ExpectedInformation
            )
            {
                throw "Kein gültiger Hashwert vorhanden."
            }

        }



        ####################################################
        # Werte übernehmen
        ####################################################

        $ExpectedHash =
        $ExpectedInformation.Hash


        $Algorithm =
        $ExpectedInformation.Algorithm



        ####################################################
        # Hash berechnen
        ####################################################

        $CalculatedHash =
        (
            Get-FileHash `
            -Path `
            $script:SelectedFile `
            -Algorithm `
            $Algorithm
        ).Hash.ToUpper()



        ####################################################
        # Vergleich
        ####################################################

        $Result =
        (
            $CalculatedHash -eq $ExpectedHash
        )



        ####################################################
        # Ergebnisanzeige
        ####################################################

        $resultBox.Text =

@"
Datei:
$script:SelectedFile

Checksum-Datei:
$ChecksumDisplay

Algorithmus:
$Algorithm

Berechnet:
$CalculatedHash

Erwartet:
$ExpectedHash

Ergebnis:
$Result
"@



        if($Result)
        {
            $resultBox.ForeColor =
            [System.Drawing.Color]::Green
        }
        else
        {
            $resultBox.ForeColor =
            [System.Drawing.Color]::Red
        }



        ####################################################
        # Log schreiben
        #
        # Format:
        #
        # Datum: ...
        # Datei: ...
        # Algorithmus: ...
        # Hashwert (berechnet): ...
        # Hashwert (erwartet): ...
        # Ergebnis: ...
        #
        ####################################################

        $Timestamp =
        Get-Date `
        -Format `
        "yyyy-MM-dd HH:mm:ss"



        $LogLine =

"Datum: $Timestamp, " +
"Datei: $script:SelectedFile, " +
"Algorithmus: $Algorithm, " +
"Hashwert (berechnet): $CalculatedHash, " +
"Hashwert (erwartet): $ExpectedHash, " +
"Ergebnis: $Result"



        Add-Content `
        -Path `
        $script:LogFile `
        -Value `
        $LogLine `
        -Encoding UTF8


    }


    catch
    {

        $resultBox.Text =
        $_.Exception.Message


        $resultBox.ForeColor =
        [System.Drawing.Color]::Red

    }


})



############################################################
# Reset Button
############################################################

$resetButton.Add_Click({

    ########################################################
    # interne Werte löschen
    ########################################################

    $script:SelectedFile =
    $null


    $script:ChecksumFile =
    $null



    ########################################################
    # Eingabefelder leeren
    ########################################################

    $fileBox.Clear()
    $checksumBox.Clear()
    $hashBox.Clear()


    ########################################################
    # Standardwerte setzen
    ########################################################

    $algorithmBox.SelectedItem = "SHA256"


    ########################################################
    # Ergebnis löschen
    ########################################################

    $resultBox.Clear()

    $resultBox.ForeColor =
    [System.Drawing.Color]::Black
})



############################################################
# GUI starten
############################################################

[void]$form.ShowDialog()