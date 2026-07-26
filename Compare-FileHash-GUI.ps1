<#
    Compare-FileHash-GUI

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
"Compare File Hash 2.2"


$form.Size =
New-Object System.Drawing.Size(780,820)


$form.StartPosition =
"CenterScreen"



############################################################
# Label Funktion
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
# Drag & Drop Box
#
# basiert auf funktionierender Version 2.1
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



            Update-ButtonState

        }


    })


    $form.Controls.Add($Box)


    return $Box

}



############################################################
# Prüflingsdatei
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
# Algorithmus
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


# neu:
# beim Start deaktiviert

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
New-Object System.Drawing.Point(420,310)


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
New-Object System.Drawing.Point(20,370)


$statusLabel.AutoSize =
$true


$form.Controls.Add($statusLabel)



############################################################
# Ergebnisanzeige
############################################################

$resultBox =
New-Object System.Windows.Forms.TextBox


$resultBox.Location =
New-Object System.Drawing.Point(20,410)


$resultBox.Size =
New-Object System.Drawing.Size(720,300)


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
# Funktion:
# Prüft, ob ein Vergleich möglich ist
#
# Regeln:
#
# Prüfen-Button aktiv wenn:
#
# 1. Prüflingsdatei vorhanden
#
# UND
#
# 2. entweder:
#    - Checksum-Datei vorhanden
#    - manueller Hash vorhanden
#
############################################################

function Update-ButtonState
{

    $CanStart =
    $false



    ########################################################
    # Prüflingsdatei vorhanden?
    ########################################################

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

            ################################################
            # Checksum-Datei vorhanden?
            ################################################

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



            ################################################
            # Oder manueller Hash vorhanden?
            ################################################

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
# Funktion:
# Setzt Statusmeldung
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


    # GUI sofort aktualisieren

    $form.Refresh()

}



############################################################
# Hash-Eingabe überwachen
#
# Wenn Benutzer manuell einen Hash einfügt,
# wird der Vergleichsbutton aktualisiert.
#
############################################################

$hashBox.Add_TextChanged({

    Update-ButtonState

})



############################################################
# Checksum-Datei ändern
#
# falls das Feld später programmgesteuert
# verändert wird
############################################################

$checksumBox.Add_TextChanged({

    if(
    -not(
    [string]::IsNullOrWhiteSpace(
    $checksumBox.Text
    )
    )
    )
    {

        $script:ChecksumFile =
        $checksumBox.Text

    }


    Update-ButtonState

})



############################################################
# Prüflingsdatei ändern
############################################################

$fileBox.Add_TextChanged({

    if(
    -not(
    [string]::IsNullOrWhiteSpace(
    $fileBox.Text
    )
    )
    )
    {

        $script:SelectedFile =
        $fileBox.Text

    }


    Update-ButtonState

})



############################################################
# Initialer Zustand
############################################################

Update-ButtonState




############################################################
# Button:
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
            throw "Keine Datei zum Prüfen ausgewählt."
        }



        if(
        -not(Test-Path $script:SelectedFile)
        )
        {
            throw "Die ausgewählte Datei existiert nicht."
        }



        ####################################################
        # Vergleichswert bestimmen
        ####################################################

        $ExpectedInformation =
        $null


        $ChecksumDisplay =
        "Hashwert wurde kopiert"



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
Kein gültiger Hashwert angegeben.
"
            }

        }



        ####################################################
        # Algorithmus übernehmen
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



        ####################################################
        # GUI aktualisieren
        #
        # wichtig bei großen ISO-Dateien
        ####################################################

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
            "Vergleich erfolgreich." `
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

        Set-Status `
        "Fehler aufgetreten." `
        ([System.Drawing.Color]::Red)



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
    # Algorithmus zurücksetzen
    ########################################################

    $algorithmBox.SelectedItem =
    "SHA256"



    ########################################################
    # Ergebnis löschen
    ########################################################

    $resultBox.Clear()



    ########################################################
    # Status zurücksetzen
    ########################################################

    Set-Status `
    "Bereit." `
    ([System.Drawing.Color]::Black)



    ########################################################
    # Button wieder deaktivieren
    ########################################################

    Update-ButtonState


})



############################################################
# GUI starten
############################################################

[void]$form.ShowDialog()
