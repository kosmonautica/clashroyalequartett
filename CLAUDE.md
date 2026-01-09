# Clash Royale Quartett

Ruby/Squib-Projekt für Quartett-Kartenspiel.

## Tech Stack

### Sprache & Runtime
- **Ruby 2.7.3** (getestet mit 2.7+, kompatibel mit 3.x)

### Dependencies
- **squib** - Kartendesign-DSL und PDF-Generierung
- **roo** - Excel-Datei-Parsing (.xlsx)
- **mini_magick** - Bildbearbeitung (benötigt ImageMagick)
- **nokogiri** - HTML-Parsing für Web Scraping
- Standard-Library: `open-uri`, `fileutils`

### Externe Requirements
- **ImageMagick** muss installiert sein für mini_magick

### Installation
```bash
gem install squib roo mini_magick nokogiri
```

Oder mit Bundler (empfohlen):
```bash
bundle install
```

## Workflow
1. `ruby clashroyale_bilderdownload_und_konvertierung.rb` - Bilder vom Wiki laden
2. `ruby kartenerstellung.rb` - PDF generieren

## Dateien

### Input
- `ClashRoyaleKartendaten.xlsx` - Kartendaten mit Spalten:
  - Nummer, Name, url_pfadname
  - Elexier, Anzahl, Tempo, Reichweite, Schaden, Leben, Seltenheit
- `layout.yml` - Squib-Layout-Konfiguration (Positionen, Schriftgrößen, etc.)

### Output
- `bilder/` - Heruntergeladene und konvertierte Kartenbilder (330px Höhe, PNG)
- `clash_royale_quartett.pdf` - Finales Quartett-PDF

### Temporär/Generiert
- `bilder/*.png` - Dürfen überschrieben werden
- `clash_royale_quartett.pdf` - Wird immer neu generiert

## Regeln
- **WICHTIG: Keine Code-Änderungen ohne explizite Zustimmung des Users** - Immer zuerst fragen, bevor Dateien bearbeitet werden
- **Git-Commits: KEINE Hinweise auf Claude Code oder andere LLMs in den Commit-Messages**
- Excel-Datei darf bearbeitet werden (URLs korrigieren, neue Spalten hinzufügen)
- Leere `url_pfadname`-Zellen sind normal (Work in Progress)
- Bilder werden automatisch heruntergeladen und dürfen überschrieben werden
- PDF wird bei jedem Run überschrieben

## Bild-Download Details

### URL-Schema
```
https://clashroyale.fandom.com/wiki/{url_pfadname}?file={NameOhneLeerzeichen}Card.png
```

### Prozess
1. Wiki-Seite wird geladen und geparst
2. Echte Bild-URL wird aus HTML extrahiert
3. Bild wird heruntergeladen
4. Falls Höhe > 330px: Skalierung auf 330px Höhe (Seitenverhältnis bleibt erhalten)
5. Konvertierung zu PNG
6. Speicherung in `./bilder/{Name}.png`

### Fehlerbehebung bei 404
- `url_pfadname` in Excel korrigieren, oder
- Bild manuell in `./bilder/{Name}.png` ablegen

## Kartenerstellung Details

### Layout
- Kartengröße: 825x1125 Pixel (inkl. 37.5px Beschnitt)
- Sichere Zone: 675x975 Pixel (16px Radius)
- Bildbereich: Zentriert, 330px Höhe
- Titel: Zentriert oben
- Attribute: Linksbündig in Textbereich
- Kartennummer: Rechts unten
- Credits: Zentriert unten, zweizeilig ("Clash Royale Quartett / Version 0.2" und "von Jakob Wiegärtner")

### Attribute auf Karte
- Elixier
- Anzahl
- Tempo
- Reichweite
- Schaden
- Leben
- Seltenheit
