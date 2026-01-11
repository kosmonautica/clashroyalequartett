require 'mini_magick'
require 'open-uri'
require 'roo'
require 'fileutils'
require 'nokogiri'

# Konfiguration
TARGET_HEIGHT = 350  # Maximale Höhe in Pixeln

# Bild-Modus: :card oder :card_render
# :card        -> {Name}Card.png (z.B. BarbarianBarrelCard.png)
# :card_render -> {Name}_card_render.png (z.B. Barbarian_Barrel_card_render.png)
IMAGE_MODE = :card_render

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
    wiki_url = nil
    img_url = nil
    begin
      # Wiki-Pfad: Leerzeichen durch Unterstriche ersetzen
      wiki_path = name.gsub(' ', '_')

      # Dateiname: Leerzeichen entfernen (CamelCase)
      file_name = name.gsub(' ', '')

      # Bild-Dateiname je nach Modus
      if IMAGE_MODE == :card_render
        image_filename = "#{wiki_path}_card_render.png"
        search_pattern = '_card_render'
      else
        image_filename = "#{file_name}Card.png"
        search_pattern = "#{file_name}Card"
      end

      # Erwartete Bild-URL (für Fehlerausgabe)
      img_url = "https://static.wikia.nocookie.net/clashroyale/images/X/XX/#{image_filename}/revision/latest"

      # Erst die Wiki-Seite laden um die echte Bild-URL zu finden
      wiki_url = "https://clashroyale.fandom.com/wiki/#{wiki_path}?file=#{image_filename}"
      html = URI.open(wiki_url).read
      doc = Nokogiri::HTML(html)

      # Suche nach der direkten Bild-URL im HTML
      img_tag = doc.at_css("img[data-image-name='#{image_filename}']")

      if img_tag.nil?
        # Alternativ: Suche nach dem Bild im Media-Viewer
        img_tag = doc.at_css("a.image img[src*='#{search_pattern}']")
      end
      
      if img_tag.nil?
        raise "Bild-Tag nicht gefunden im HTML"
      end
      
      # Hole die src oder data-src URL
      img_url = img_tag['src'] || img_tag['data-src']
      
      # Bereinige die URL (entferne Thumbnail-Parameter)
      img_url = img_url.gsub(/\/scale-to-width-down\/\d+/, '')
      img_url = img_url.gsub(/\/revision\/latest.*/, '/revision/latest')

      # Stelle sicher, dass die URL vollständig ist
      img_url = "https:#{img_url}" unless img_url.start_with?('http')

      puts "  Lade: #{img_url}"

      # Lade das Bild
      image_data = URI.open(img_url).read
      image = MiniMagick::Image.read(image_data)
      
      # Skaliere das Bild falls nötig
      if image.height > TARGET_HEIGHT
        puts "  Skaliere von #{image.width}x#{image.height} auf Höhe #{TARGET_HEIGHT}..."
        image.resize "x#{TARGET_HEIGHT}"
      end
      
      # Konvertiere zu PNG
      image.format 'png'
      
      # Speichere als PNG im bilder-Verzeichnis
      output_filename = "./bilder/#{name}.png"
      image.write(output_filename)
      
      puts "✓ Erfolgreich konvertiert und gespeichert als: #{output_filename}"
    rescue OpenURI::HTTPError => e
      puts "✗ Fehler: Bild für '#{name}' konnte nicht gefunden werden (#{e.message})"
      failed_downloads << { name: name, url: img_url || wiki_url }
    rescue => e
      puts "✗ Fehler bei '#{name}': #{e.message}"
      failed_downloads << { name: name, url: img_url || wiki_url }
    end
    puts ""
  end
  
  # Ausgabe der fehlgeschlagenen Downloads
  if failed_downloads.any?
    puts "\nFolgende Bilder konnten nicht heruntergeladen werden:"
    failed_downloads.each do |entry|
      puts "- #{entry[:name]}"
      puts "  URL: #{entry[:url]}"
    end
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