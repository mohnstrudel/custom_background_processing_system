require 'open-uri'
require 'nokogiri'
require_relative 'magique'

RUBYMAGIC = %w(https://rbc.ru https://gamestar.de https://atomic-digital.ru https://overclockers.ru https://focus.de https://web.de)

class TitleExtractorService
  include Magique::Worker

  def perform(url)
    document = Nokogiri::HTML(open(url))
    title = document.css('html > head > title').first.content
    puts "[#{Thread.current.name}] #{title.gsub(/[[:space:]]+/, ' ').strip}"
  rescue
    puts "Unable to find a title for #{url}"
  end
end

Magique.backend = Queue.new
Magique::Processor.start(5)

RUBYMAGIC.each do |url|
  TitleExtractorService.perform_async(url)
  sleep 0.5
end



# Aktuell im Schnitt ca. so:
#        user     system      total        real
# URL  0.190000   0.020000   0.210000 (  1.318162)
# Average: 1.3707450999936555