require 'squib'
require 'roo'

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
  
  png_files = daten['url_pfadname'].map do |b|
    pfad = "bilder/#{b}.png"
    File.exist?(pfad) ? pfad : nil
  end
  png file: png_files, layout: 'art', scale: 'fit'
  
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