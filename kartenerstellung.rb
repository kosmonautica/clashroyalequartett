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

# DEBUG: Prüfe ob seltenheit-Daten vorhanden sind
puts "=== DEBUG START ==="
puts "Anzahl Karten: #{daten['name'].size}"
puts "Seltenheit-Array: #{daten['seltenheit'].inspect}"
puts "Seltenheit-Länge: #{daten['seltenheit'].size}"
puts "Erstes Element: #{daten['seltenheit'][0].inspect}"
puts "=== DEBUG END ==="

Squib::Deck.new cards: daten['name'].size, layout: 'layout.yml' do

  background color: 'white'
  rect layout: 'cut'
  rect layout: 'safe'
  text str: daten['name'], layout: 'title'
  text str: daten['nummer'], layout: 'lower_right'
  png file: daten['url_pfadname'].map { |b| "bilder/#{b}.png" }, layout: 'art'
  
  character_werte = (0...daten['name'].size).map do |i|
    text = "Elixier: #{daten['elexier'][i]}\n" \
           "Anzahl: #{daten['anzahl'][i]}\n" \
           "Tempo: #{daten['tempo'][i]}\n" \
           "Reichweite: #{daten['reichweite'][i]}\n" \
           "Schaden: #{daten['schaden'][i]}\n" \
           "Leben: #{daten['leben'][i]}\n" \
           "Seltenheit: #{daten['seltenheit'][i]}"
    
    # DEBUG: Zeige jeden generierten Text
    puts "--- Karte #{i} ---"
    puts text
    puts "----------------"
    
    text
  end
  
  text str: character_werte, layout: 'description'
  text str: 'von Jakob Wiegärtner / Version 0.1', layout: 'credits'
  save_pdf trim: 37.5, file: 'clash_royale_quartett_brawl_karten.pdf'
  
end
