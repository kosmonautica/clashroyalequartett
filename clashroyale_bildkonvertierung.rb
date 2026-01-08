require 'mini_magick'
require 'open-uri'
require 'roo'
require 'fileutils'

# Erstelle Verzeichnis für Bilder
FileUtils.mkdir_p('./bilder')

# Liste für fehlgeschlagene Downloads
failed_downloads = []

# Excel-Datei öffnen
begin
  xlsx = Roo::Spreadsheet.open('ClashRoyaleKartendaten.xlsx')
  sheet = xlsx.sheet(0)  # Erstes Sheet
  
  # Finde den Index der Spalte 'url_pfadname'
  headers = sheet.row(1)
  url_column_index = headers.index('url_pfadname')
  
  if url_column_index.nil?
    puts "Fehler: Spalte 'url_pfadname' nicht gefunden!"
    exit
  end
  
  # Alle Namen aus der Spalte holen (ohne Header)
  names = sheet.column(url_column_index + 1)[1..-1].compact
  
  puts "#{names.length} Namen zum Herunterladen gefunden.\n\n"
  
  # Verarbeite jeden Namen
  names.each_with_index do |name, index|
    puts "Verarbeite (#{index + 1}/#{names.length}): #{name}"
    begin
      # Erstelle die URL
      # url = "https://media.brawltime.ninja/brawlers/#{name}/model.webp?size=300"
      url = "https://clashroyale.fandom.com/wiki/#{name}?file=#{name}Card.png"
      
      # originale URL
      # https://clashroyale.fandom.com/wiki/Baby_Dragon?file=BabyDragonCard.png
      
      # Lade und konvertiere das Bild
      image = MiniMagick::Image.read(URI.open(url).read)
      image.format 'png'
      
      # Speichere als PNG im bilder-Verzeichnis
      output_filename = "./bilder/#{name}.png"
      image.write(output_filename)
      
      puts "✓ Erfolgreich konvertiert und gespeichert als: #{output_filename}"
    rescue OpenURI::HTTPError => e
      puts "✗ Fehler: Bild für '#{name}' konnte nicht gefunden werden (404)"
      failed_downloads << name
    rescue => e
      puts "✗ Fehler bei '#{name}': #{e.message}"
      failed_downloads << name
    end
    puts "" # Leerzeile für bessere Lesbarkeit
  end
  
  # Ausgabe der fehlgeschlagenen Downloads
  if failed_downloads.any?
    puts "\nFolgende Bilder konnten nicht heruntergeladen werden:"
    failed_downloads.each { |name| puts "- #{name}" }
    puts "\nAnzahl fehlgeschlagener Downloads: #{failed_downloads.length}"
  else
    puts "\nAlle Bilder wurden erfolgreich heruntergeladen!"
  end
  
rescue Errno::ENOENT
  puts "Fehler: Die Datei 'ClashRoyaleKartendaten.xlsx' wurde nicht gefunden!"
rescue => e
  puts "Fehler beim Lesen der Excel-Datei: #{e.message}"
end

puts "\nVerarbeitung abgeschlossen!"
