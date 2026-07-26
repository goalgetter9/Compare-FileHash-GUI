<#
.SYNOPSIS
Compare-FileHash-GUI

.DESCRIPTION
Grafisches PowerShell-Tool zur Überprüfung der Datei-Integrität mittels kryptografischer Hashwerte.

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
- Buttonstatus automatisch
- Statusanzeige
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
"Compare-FileHash-GUI 2.2"


$form.Size =
New-Object System.Drawing.Size(800,820)


$form.StartPosition =
"CenterScreen"



############################################################
# Hilfsfunktion für Labels
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
# Drag & Drop TextBox erstellen
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
    New-Object System.Drawing.Size(740,50)


    $Box.Multiline =
    $true


    $Box.ReadOnly =
    $true


    $Box.AllowDrop =
    $true


    $Box.BackColor =
    [System.Drawing.Color]::White


    #
    # Kennzeichnung:
    # FILE oder CHECKSUM
    #

    $Box.Tag =
    $Type



    ########################################################
    # Drag Enter
    ########################################################

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



    ########################################################
    # Drag & Drop
    ########################################################

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



            Update-ButtonState

        }


    })



    $form.Controls.Add($Box)


    return $Box

}



############################################################
# Datei Auswahl
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
# Checksum-Datei Auswahl
############################################################

Add-Label `
"2. Checksum-Datei optional (Drag & Drop)" `
20 `
125


$checksumBox =
Add-DropBox `
20 `
150 `
"CHECKSUM"



############################################################
# Manueller Hash
############################################################

Add-Label `
"Manueller Hashwert (optional)" `
20 `
225


$hashBox =
New-Object System.Windows.Forms.TextBox


$hashBox.Location =
New-Object System.Drawing.Point(20,250)


$hashBox.Size =
New-Object System.Drawing.Size(740,25)


$form.Controls.Add($hashBox)



############################################################
# Algorithmus Auswahl
############################################################

Add-Label `
"Algorithmus" `
20 `
295


$algorithmBox =
New-Object System.Windows.Forms.ComboBox


$algorithmBox.Location =
New-Object System.Drawing.Point(20,320)


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
# Vergleich Button
############################################################

$button =
New-Object System.Windows.Forms.Button


$button.Text =
"Hash vergleichen"


$button.Location =
New-Object System.Drawing.Point(220,315)


$button.Size =
New-Object System.Drawing.Size(180,35)


$button.Enabled =
$false


$form.Controls.Add($button)



############################################################
# Reset Button
############################################################

$resetButton =
New-Object System.Windows.Forms.Button


$resetButton.Text =
"Zurücksetzen"


$resetButton.Location =
New-Object System.Drawing.Point(430,315)


$resetButton.Size =
New-Object System.Drawing.Size(150,35)


$form.Controls.Add($resetButton)



############################################################
# Statusanzeige
############################################################

$statusLabel =
New-Object System.Windows.Forms.Label


$statusLabel.Text =
"Bereit"


$statusLabel.Location =
New-Object System.Drawing.Point(20,375)


$statusLabel.AutoSize =
$true


$form.Controls.Add($statusLabel)



############################################################
# Ergebnisbereich
############################################################

$resultBox =
New-Object System.Windows.Forms.TextBox


$resultBox.Location =
New-Object System.Drawing.Point(20,410)


$resultBox.Size =
New-Object System.Drawing.Size(740,300)


$resultBox.Multiline =
$true


$resultBox.ReadOnly =
$true


$resultBox.ScrollBars =
"Both"


$resultBox.WordWrap =
$false


$form.Controls.Add($resultBox)




############################################################
# Button Status aktualisieren
############################################################

function Update-ButtonState
{

    $CanStart =
    $false



    #
    # Prüfen ob eine Datei vorhanden ist
    #

    if(
    -not(
    [string]::IsNullOrWhiteSpace(
    $script:SelectedFile
    )
    )
    )
    {

        if(
        Test-Path $script:SelectedFile
        )
        {

            #
            # Checksum-Datei vorhanden
            #

            if(
            -not(
            [string]::IsNullOrWhiteSpace(
            $script:ChecksumFile
            )
            )
            )
            {

                $CanStart =
                $true

            }



            #
            # Oder manueller Hash vorhanden
            #

            if(
            -not(
            [string]::IsNullOrWhiteSpace(
            $hashBox.Text
            )
            )
            )
            {

                $CanStart =
                $true

            }

        }

    }



    $button.Enabled =
    $CanStart

}



############################################################
# Status setzen
############################################################

function Set-Status
{
    param(
        [string]$Text,
        [System.Drawing.Color]$Color =
        [System.Drawing.Color]::Black
    )


    $statusLabel.Text =
    $Text


    $statusLabel.ForeColor =
    $Color


    $form.Refresh()

}



############################################################
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
# Dateiname bereinigen
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
# Dateiname vergleichen
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
        $ChecksumName -eq $TargetName
    )

}



############################################################
# Checksum-Datei auslesen
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



        #
        # Format:
        # SHA256 (Datei.iso) = HASH
        #

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



        #
        # GNU Format:
        # HASH *Datei.iso
        #

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



        #
        # Einfach:
        # HASH Datei.iso
        #

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
# Manuellen Hash verarbeiten
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
# Eingabefelder überwachen
############################################################

$hashBox.Add_TextChanged({

    Update-ButtonState

})


$fileBox.Add_TextChanged({

    $script:SelectedFile =
    $fileBox.Text

    Update-ButtonState

})


$checksumBox.Add_TextChanged({

    $script:ChecksumFile =
    $checksumBox.Text

    Update-ButtonState

})



############################################################
# Anfangszustand
############################################################

Update-ButtonState




############################################################
# Hashvergleich starten
############################################################

$button.Add_Click({

    try
    {

        ####################################################
        # Eingaben prüfen
        ####################################################

        if(
        [string]::IsNullOrWhiteSpace(
        $script:SelectedFile
        )
        )
        {
            throw "Keine Datei ausgewählt."
        }



        if(
        -not(Test-Path $script:SelectedFile)
        )
        {
            throw "Datei wurde nicht gefunden."
        }



        ####################################################
        # Erwarteten Hash ermitteln
        ####################################################

        $ExpectedInformation =
        $null


        $ChecksumDisplay =
        "Hashwert wurde kopiert"



        #
        # Variante 1:
        # Checksum-Datei
        #

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
                throw "
Kein passender Hash in der Checksum-Datei gefunden.
"
            }

        }


        #
        # Variante 2:
        # manueller Hash
        #

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
                throw "
Kein gültiger Hashwert vorhanden.
"
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
        # Status anzeigen
        ####################################################

        Set-Status `
        "Berechne $Algorithm Hash... Bitte warten." `
        ([System.Drawing.Color]::Blue)



        #
        # Oberfläche aktualisieren
        #

        [System.Windows.Forms.Application]::DoEvents()



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
        # Ergebnis anzeigen
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


            Set-Status `
            "Prüfung erfolgreich." `
            ([System.Drawing.Color]::Green)

        }

        else
        {

            $resultBox.ForeColor =
            [System.Drawing.Color]::Red


            Set-Status `
            "Hashwerte stimmen nicht überein." `
            ([System.Drawing.Color]::Red)

        }



        ####################################################
        # Log schreiben
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


        Set-Status `
        "Fehler." `
        ([System.Drawing.Color]::Red)

    }


})



############################################################
# Reset Button
############################################################

$resetButton.Add_Click({

    ########################################################
    # Variablen zurücksetzen
    ########################################################

    $script:SelectedFile =
    $null


    $script:ChecksumFile =
    $null



    ########################################################
    # Felder leeren
    ########################################################

    $fileBox.Clear()

    $checksumBox.Clear()

    $hashBox.Clear()


    $resultBox.Clear()



    ########################################################
    # Standardalgorithmus
    ########################################################

    $algorithmBox.SelectedItem =
    "SHA256"



    ########################################################
    # Status
    ########################################################

    Set-Status `
    "Bereit." `
    ([System.Drawing.Color]::Black)



    ########################################################
    # Button deaktivieren
    ########################################################

    Update-ButtonState


})



############################################################
# Anwendung starten
############################################################

[void]$form.ShowDialog()
