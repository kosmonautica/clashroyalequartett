require 'squib'
require 'roo'
require 'mini_magick'

xlsx = Roo::Excelx.new('ClashRoyaleKartendaten.xlsx')
daten = {
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

Squib::Deck.new cards: daten['name'].size, layout: 'layout.yml' do

  background color: 'white'
  rect layout: 'cut'
  rect layout: 'safe'
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
      # Lade Bild mit MiniMagick um Dimensionen zu ermitteln
      img = MiniMagick::Image.open(pfad)
      original_width = img.width
      original_height = img.height
      
      # Berechne skalierte Breite bei Höhe 400
      scale_factor = art_h.to_f / original_height
      scaled_width = (original_width * scale_factor).round
      
      # Berechne x so, dass Bild zentriert ist (linke Kante)
      x_pos = center_x - (scaled_width / 2.0)
      
      # Rendere Bild
      png range: i, file: pfad, x: x_pos, y: art_y, height: art_h
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
  
  text str: character_werte, layout: 'description'
  text str: 'von Jakob Wiegärtner / Version 0.1', layout: 'credits'
  save_pdf trim: 37.5, file: 'clash_royale_quartett.pdf'
  
end