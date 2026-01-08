require 'mini_magick'

# Verzeichnis mit Bildern
verzeichnis = './bilder'

# Zielhöhe
ziel_hoehe = 300

# Alle PNG-Dateien im Verzeichnis durchgehen
Dir.glob("#{verzeichnis}/*.png") do |dateipfad|
  bild = MiniMagick::Image.open(dateipfad)
  urspruenglich_breite = bild.width
  urspruenglich_hoehe = bild.height

  # Neue Breite basierend auf Zielhöhe und Seitenverhältnis berechnen
  seitenverhaeltnis = urspruenglich_breite.to_f / urspruenglich_hoehe
  neue_breite = (ziel_hoehe * seitenverhaeltnis).round

  # Bild skalieren
  bild.resize "#{neue_breite}x#{ziel_hoehe}"

  # Überschreiben der Originaldatei
  bild.write(dateipfad)

  puts "#{File.basename(dateipfad)}: #{urspruenglich_breite}x#{urspruenglich_hoehe} → #{neue_breite}x#{ziel_hoehe}"
end
