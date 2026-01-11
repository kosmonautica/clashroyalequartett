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
- Kartennummer: Rechts oben
- Credits: Zentriert unten, zweizeilig ("Clash Royale Quartett / Version 0.2" und "von Jakob Wiegärtner")

### Attribute auf Karte
- Elixier
- Anzahl
- Tempo
- Reichweite
- Schaden
- Leben
- Seltenheit

## Neues Design (kartenerstellung_neues_Design.rb)

### Ausgabe-Modi
Das Script unterstützt zwei Modi (konfigurierbar via `OUTPUT_MODE`):
- `:pdf` - Alle Karten als PDF generieren
- `:png` - Einzelne Karte als PNG generieren (zum Testen des Layouts)

Bei PNG-Export wird `SINGLE_CARD_NAME` verwendet, um die zu generierende Karte auszuwählen.

### Layout-Datei
`layout_neues_design.yml` - Konfiguration für das neue Design

### Layout-Bereiche (in Pixel)

| Bereich | Position (x, y) | Größe (w × h) | Beschreibung |
|---------|-----------------|---------------|--------------|
| **cut** | 37.5, 37.5 | 750 × 1050 | Schnittlinie |
| **safe** | 75, 75 | 675 × 975 | Sichere Zone (16px Radius, gestrichelt) |
| **title** | 90, 90 | 635 × 50 | Kartenname (zentriert, 16pt) |
| **art_area** | 75, 170 | 675 × 350 | Bildbereich (Bilder werden zentriert) |
| **lower_right** | 650, 90 | 75 × 50 | Kartennummer oben rechts (6pt) |
| **credits** | 75, 995 | 675 × 55 | Copyright-Zeile (5pt, zentriert) |

### Charakterwert-Positionen (CHARAKTER_POSITIONEN)
Jeder Attributwert ist pixelgenau konfigurierbar mit: `x`, `y`, `font_size`, `align`, `label`

Aktuelle Positionen (x=190, y-Abstand=73px):

| Attribut | x | y |
|----------|---|---|
| Elixier | 190 | 560 |
| Anzahl | 190 | 633 |
| Tempo | 190 | 706 |
| Reichweite | 190 | 779 |
| Schaden | 190 | 852 |
| Leben | 190 | 925 |
| Seltenheit | 190 | 998 |

### Besonderheiten
- Hintergrundbild: `hintergrund2.png` (825 × 1125 px)
- Bilder werden in Originalgröße gerendert und horizontal+vertikal im art_area zentriert
- Debug-Rahmen (auskommentierbar): `art_border` (rot), `description_border` (schwarz)
- PNG-Output: `_output/test_card_.png`
- PDF-Output: `clash_royale_quartett.pdf` (mit 37.5px Trim)
- **PDF-Retry-Logik**: Bei gesperrter PDF-Datei werden automatisch gängige PDF-Reader geschlossen (Adobe Reader, Acrobat, Foxit, SumatraPDF) und das Speichern erneut versucht

### Bilderdownload (clashroyale_bilderdownload_und_konvertierung_neues_design.rb)

#### Konfiguration
- `TARGET_HEIGHT = 350` - Maximale Bildhöhe in Pixeln (passend zum art_area)
- `IMAGE_MODE` - Auswahl des Bild-Typs:
  - `:card` - Standard-Kartenbilder (`{Name}Card.png`, z.B. `BarbarianBarrelCard.png`)
  - `:card_render` - Render-Bilder (`{Name}_card_render.png`, z.B. `Barbarian_Barrel_card_render.png`)

#### URL-Schema
```
Wiki-Seite: https://clashroyale.fandom.com/wiki/{wiki_path}?file={image_filename}
```

Wobei:
- `wiki_path` = Name mit Unterstrichen statt Leerzeichen
- `image_filename` = je nach IMAGE_MODE:
  - `:card` → `{NameOhneLeerzeichen}Card.png`
  - `:card_render` → `{Name_mit_Unterstrichen}_card_render.png`

#### Prozess
1. Wiki-Seite laden und mit Nokogiri parsen
2. Bild-Tag finden via `data-image-name` oder `src*=` Attribut
3. Thumbnail-Parameter aus URL entfernen
4. Bild herunterladen
5. Falls Höhe > 350px: Skalierung auf 350px Höhe
6. Konvertierung zu PNG
7. Speicherung in `./bilder/{Name}.png`

#### Fehlerbehandlung
- Fehlgeschlagene Downloads werden gesammelt und am Ende mit URL ausgegeben
- Bei 404: `url_pfadname` in Excel korrigieren oder Bild manuell ablegen
