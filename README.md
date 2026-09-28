# iQuiz Fragenpakete

Öffentlicher Paketkatalog für `IT-BW/iQuiz-Fragenkatalog`. Die App lädt nach Nutzerwahl geprüfte JSON-Pakete herunter und spielt sie anschließend offline ab.

Katalogadresse nach Aktivierung von GitHub Pages:

`https://it-bw.github.io/iQuiz-Fragenkatalog/catalog.json`

## Erstveröffentlichung

1. Ein öffentliches Repository `IT-BW/iQuiz-Fragenkatalog` anlegen (oder ein vorhandenes verwenden).
2. Den **Inhalt dieses Ordners** einschließlich `.github/workflows/pages.yml` in dessen Wurzelverzeichnis übernehmen. Nicht das gesamte App-Projekt hochladen.
3. In **Settings → Pages → Build and deployment → Source** die Option **GitHub Actions** auswählen.
4. Auf `main` veröffentlichen oder den Workflow „Validate and publish question packages“ manuell starten.
5. Nach erfolgreichem Workflow die Katalogadresse öffnen. In der App unter **Fragenpakete → Onlinekatalog aktualisieren** testen.

Der Workflow prüft auch Pull Requests, veröffentlicht aber nur bei Push auf `main` oder manuellem Start. Er lädt ausschließlich `catalog.json`, `index.html` und `packages/` hoch.

## Struktur

```text
catalog.json
packages/
  ot/1.0.0.json
  nt/1.0.0.json
  people/1.0.0.json
  places/1.0.0.json
  sda-history/1.0.0.json
  sda-pioneers/1.0.0.json
```

Der Katalog enthält Metadaten, Paketversion, relativen Downloadpfad, Dateigröße in Bytes und SHA-256 der tatsächlichen Download-Datei. Eine Paketdatei enthält `FormatVersion`, `Id`, `Version`, `Title`, `Description`, `Artwork` und `Questions`. `Artwork` verwendet vorerst einen der sechs mitgelieferten Bildausschnitte (0–5); externe Bilder werden nicht geladen.

Jede Frage hat eine eindeutige ID, die zum Paket passende `PackId`, `Difficulty` (`Anfänger`, `Bibelkundig`, `Experte`), vier Antworten, `CorrectIndex` (0–3), Erklärung und Quelle. Ein Paket darf eine, zwei oder alle drei Stufen enthalten, muss aber mindestens eine Frage haben. Die App bietet direkt beim Paket nur die vorhandenen Stufen zum Starten an. Ältere App-Versionen mit der bisherigen Pflicht zu drei Stufen benötigen dafür ein App-Update. `FormatVersion` ist aktuell 1; Paketversionen sind Zahlen im Muster `1.0.0`, ohne Vorabversions-Suffixe.

## Neue Pakete und Updates

Im App-Projekt die Fragen unter `Core/Data/Questions/` und die Paketbeschreibung in `Core/Data/packs.json` pflegen. Neue Pakete benötigen dort einen neuen Eintrag und eine passende Fragen-Datei. Bei Änderungen an bereits veröffentlichten Inhalten die Paketversion erhöhen, etwa von `1.0.0` auf `1.1.0`.

Im App-Projekt ausführen:

```powershell
./docs/export-package-catalog.ps1
```

Der Export erzeugt neue Versionsdateien und berechnet Katalog und Prüfsummen. Bereits vorhandene Versionsdateien dürfen nicht mit anderem Inhalt überschrieben werden. Alte Versionen behalten. Anschließend die Änderungen dieses Ordners in das öffentliche Repository übernehmen und auf `main` veröffentlichen. Dafür ist kein neues App-Release nötig.

Der Export des App-Projekts ist für dessen vollständigen Paketbestand gedacht. Werden Pakete ausschließlich hier redaktionell gepflegt, deren Katalogeinträge beim Übernehmen eines Exports zusätzlich beibehalten. Vor dem Commit prüfen:

```powershell
./validate.ps1
```

Wenn Paketdateien direkt bearbeitet werden, Version, Metadaten, Dateigröße und SHA-256 in `catalog.json` entsprechend aktualisieren. Der Workflow verweigert eine Veröffentlichung bei abweichenden Prüfsummen oder ungültigen Fragen.

Quellenhinweise stehen an jeder Frage. Der aktuelle Bestand umfasst 48 Beispielfragen und benötigt vor einer breiten Veröffentlichung eine fachliche Prüfung und Erweiterung, insbesondere für die Expertenstufe.

GitHub-Anleitung: https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site
