Compare-FileHash-GUI ist ein grafisches PowerShell-Programm zur sicheren Überprüfung von Datei-Integrität mithilfe von kryptografischen Hashwerten.

Das Programm wurde entwickelt, um beispielsweise heruntergeladene ISO-Dateien, Backups oder andere große Dateien mit einem vom Hersteller
bereitgestellten Prüfsummenwert zu vergleichen. Es unterstützt die gängigen Hashverfahren MD5, SHA1, SHA256, SHA384 und SHA512.

Die Bedienung erfolgt komfortabel über eine grafische Oberfläche. Die zu überprüfende Datei kann per Drag & Drop in das Programm geladen werden.
Zusätzlich kann entweder eine passende Checksum-Datei (z. B. SHA256SUMS) eingelesen werden oder ein Hashwert manuell eingefügt werden.
Das Programm erkennt automatisch den benötigten Algorithmus aus der Checksum-Datei oder anhand der Hashlänge.

Bei einer Prüfung wird der tatsächliche Hashwert der Datei mit Get-FileHash berechnet und anschließend mit dem erwarteten Wert verglichen.
Das Ergebnis wird übersichtlich dargestellt:
Datei
verwendete Checksum-Datei oder manuell eingegebener Hashwert
verwendeter Algorithmus
berechneter Hashwert
erwarteter Hashwert
Ergebnis (TRUE/FALSE)

Während der Berechnung zeigt das Programm einen Status an, damit auch bei großen Dateien erkennbar bleibt, dass der Vorgang aktiv läuft.

Eine integrierte Reset-Funktion ermöglicht das schnelle Zurücksetzen aller Eingaben und die Durchführung weiterer Prüfungen ohne Neustart des Programms.

Zusätzlich wird jede Prüfung automatisch protokolliert. Die Logdatei enthält Datum und Uhrzeit, vollständigen Dateipfad, verwendeten Algorithmus,
berechneten Hashwert, erwarteten Hashwert und das Vergleichsergebnis. Dadurch können mehrere Prüfungen nachvollzogen und archiviert werden.


Compare-FileHash kombiniert damit eine einfache Bedienung mit einer transparenten und nachvollziehbaren Integritätsprüfung.
Es eignet sich besonders für Anwender, die heruntergeladene Dateien vor der Verwendung zuverlässig auf Manipulation oder Übertragungsfehler überprüfen möchten.
