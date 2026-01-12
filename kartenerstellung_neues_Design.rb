require 'squib'
require 'roo'
require 'mini_magick'

# =============================================================================
# Konfiguration
# =============================================================================

# Ausgabe-Modus: :pdf oder :png
# :pdf -> Alle Karten als PDF generieren
# :png -> Einzelne Karte als PNG generieren (zum Testen des Layouts)
OUTPUT_MODE = :pdf

# Name der Karte für PNG-Export (nur relevant wenn OUTPUT_MODE = :png)
# Muss exakt mit dem Wert in der Spalte "Name" übereinstimmen
SINGLE_CARD_NAME = 'Eisgolem'

# =============================================================================
# Charakterwert-Positionen (pixelgenau konfigurierbar)
# =============================================================================
# Jeder Wert hat: x, y, font_size, align
# Basierend auf description-Block: x=100, y=550, font_size=8

CHARAKTER_POSITIONEN = {
  elexier: {
    label: 'Elixier',
    x: 190,
    y: 526,
    font_size: 8,
    align: :left
  },
  anzahl: {
    label: 'Anzahl',
    x: 190,
    y: 599,
    font_size: 8,
    align: :left
  },
  tempo: {
    label: 'Tempo',
    x: 190,
    y: 672,
    font_size: 8,
    align: :left
  },
  reichweite: {
    label: 'Reichweite',
    x: 190,
    y: 745,
    font_size: 8,
    align: :left
  },
  schaden: {
    label: 'Schaden',
    x: 190,
    y: 818,
    font_size: 8,
    align: :left
  },
  leben: {
    label: 'Leben',
    x: 190,
    y: 891,
    font_size: 8,
    align: :left
  },
  seltenheit: {
    label: 'Seltenheit',
    x: 190,
    y: 964,
    font_size: 8,
    align: :left
  }
}

# =============================================================================

xlsx = Roo::Excelx.new('ClashRoyaleKartendaten.xlsx')
alle_daten = {
  'nummer' => xlsx.column(1).drop(1),
  'name' => xlsx.column(2).drop(1),
  'url_pfadname' => xlsx.column(3).drop(1),
  'elexier' => xlsx.column(4).drop(1),
  'anzahl' => xlsx.column(5).drop(1),
  'tempo' => xlsx.column(6).drop(1),
  'reichweite' => xlsx.column(7).drop(1),
  'schaden' => xlsx.column(8).drop(1),
  'leben' => xlsx.column(9).drop(1),
  'seltenheit' => xlsx.column(10).drop(1)
}

# Filtere Daten je nach Modus
if OUTPUT_MODE == :png
  # Finde Index der gewünschten Karte
  card_index = alle_daten['name'].index(SINGLE_CARD_NAME)
  if card_index.nil?
    puts "Fehler: Karte '#{SINGLE_CARD_NAME}' nicht gefunden!"
    puts "Verfügbare Karten: #{alle_daten['name'].compact.join(', ')}"
    exit
  end

  # Extrahiere nur die eine Karte
  daten = {}
  alle_daten.each do |key, values|
    daten[key] = [values[card_index]]
  end
  puts "Generiere Einzelkarte: #{SINGLE_CARD_NAME}"
else
  daten = alle_daten
  puts "Generiere alle #{daten['name'].size} Karten als PDF"
end

Squib::Deck.new cards: daten['name'].size, layout: 'layout_neues_design.yml' do

  background color: 'white'

  # Ebene 1: Seltenheits-Hintergrundbild (abhängig von der Seltenheit der Karte)
  seltenheits_bilder = daten['seltenheit'].map { |s| "#{s}.png" }
  png file: seltenheits_bilder, x: 0, y: 0, width: 825, height: 1125

  # Ebene 2: Hintergrundbild über die gesamte Karte
  png file: 'hintergrund2.png', x: 0, y: 0, width: 825, height: 1125

  rect layout: 'cut'
  rect layout: 'safe'
  # rect layout: 'art_border'  # Debug-Rahmen für Bildbereich
  text str: daten['name'], layout: 'title'
  text str: daten['nummer'], layout: 'lower_right'

  # Hole Layout-Werte
  art_y = layout['art']['y']
  art_h = layout['art']['height']
  area_x = layout['art_area']['x']
  area_w = layout['art_area']['width']
  center_x = area_x + (area_w / 2.0)

  # Rendere jedes Bild einzeln zentriert
  daten['url_pfadname'].each_with_index do |b, i|
    pfad = "bilder/#{b}.png"
    if File.exist?(pfad)
      # Lade Bild um Dimensionen zu ermitteln
      img = MiniMagick::Image.open(pfad)

      # Zentriere horizontal
      x_pos = center_x - (img.width / 2.0)

      # Ausrichtung unten im art-Bereich
      y_pos = art_y + (art_h - img.height)

      # Rendere Bild in Original-Größe (keine Skalierung)
      png range: i, file: pfad, x: x_pos, y: y_pos, width: img.width, height: img.height
    end
  end

  # Rahmen um den description-Block
  # rect layout: 'description_border'

  # Charakterwerte einzeln rendern (pixelgenau positionierbar)
  CHARAKTER_POSITIONEN.each do |key, pos|
    # Hole die Daten für diesen Charakterwert
    werte = daten[key.to_s].map { |v| "#{pos[:label]}: #{v}" }

    text str: werte,
         x: pos[:x],
         y: pos[:y],
         font_size: pos[:font_size],
         align: pos[:align]
  end
  # text str: "Clash Royale Quartett / Version 0.2\nvon Jakob Wiegärtner", layout: 'credits'

  if OUTPUT_MODE == :png
    save_png dir: '_output', prefix: 'test_card_', count_format: ''
    puts "PNG gespeichert in: _output/test_card_.png"
  else
    pdf_file = 'clash_royale_quartett.pdf'
    begin
      save_pdf trim: 37.5, file: pdf_file
      puts "PDF gespeichert: #{pdf_file}"
    rescue Errno::EACCES, IOError => e
      puts "Fehler: PDF ist geöffnet. Schließe und versuche erneut..."
      # Versuche PDF zu schließen (Windows-spezifisch)
      system("taskkill /F /IM AcroRd32.exe 2>nul")
      system("taskkill /F /IM Acrobat.exe 2>nul")
      system("taskkill /F /IM FoxitReader.exe 2>nul")
      system("taskkill /F /IM SumatraPDF.exe 2>nul")
      sleep 1
      begin
        save_pdf trim: 37.5, file: pdf_file
        puts "PDF gespeichert: #{pdf_file}"
      rescue => e2
        puts "Fehler beim Speichern: #{e2.message}"
        puts "Bitte schließe das PDF manuell und führe das Script erneut aus."
      end
    end
  end

end
