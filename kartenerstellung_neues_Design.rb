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

  # Hintergrundbild über die gesamte Karte
  png file: 'hintergrund2.png', x: 0, y: 0, width: 825, height: 1125

  rect layout: 'cut'
  rect layout: 'safe'
  rect layout: 'art_border'  # Debug-Rahmen für Bildbereich
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

      # Zentriere vertikal im art-Bereich
      y_pos = art_y + ((art_h - img.height) / 2.0)

      # Rendere Bild in Original-Größe (keine Skalierung)
      png range: i, file: pfad, x: x_pos, y: y_pos, width: img.width, height: img.height
    end
  end
  
  character_werte = (0...daten['name'].size).map do |i|
    "Elixier: #{daten['elexier'][i]}\n" \
    "Anzahl: #{daten['anzahl'][i]}\n" \
    "Tempo: #{daten['tempo'][i]}\n" \
    "Reichweite: #{daten['reichweite'][i]}\n" \
    "Schaden: #{daten['schaden'][i]}\n" \
    "Leben: #{daten['leben'][i]}\n" \
    "Seltenheit: #{daten['seltenheit'][i]}"
  end
  
  # Rahmen um den description-Block
  rect layout: 'description_border'
  
  text str: character_werte, layout: 'description'
  text str: "Clash Royale Quartett / Version 0.2\nvon Jakob Wiegärtner", layout: 'credits'

  if OUTPUT_MODE == :png
    save_png dir: '_output', prefix: 'test_card_', count_format: ''
    puts "PNG gespeichert in: _output/test_card_.png"
  else
    save_pdf trim: 37.5, file: 'clash_royale_quartett.pdf'
    puts "PDF gespeichert: clash_royale_quartett.pdf"
  end

end
