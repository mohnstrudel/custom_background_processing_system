require 'open-uri'
require 'nokogiri'
require_relative 'magique'

class TitleExtractorService
  include Magique::Worker

  def call(url)
    document = Nokogiri::HTML(open(url))
    title = document.css('html > head > title').first.content
    puts title.gsub(/[[:space:]]+/, ' ').strip
  rescue
    puts "Unable to find a title for #{url}"
  end
end

TitleExtractorService.new.perform_now