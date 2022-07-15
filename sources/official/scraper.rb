#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      Name.new(
        full:     fullname,
        prefixes: %w[Hon.],
        suffixes: %w[MP JP Hon. Cert. MBE QC]
      ).short.delete_suffix(',')
    end

    def position
      fullposition
        .gsub('Minister for Health, Wellness & Home Affairs', 'Minister for Health & Wellness and Minister for Home Affairs')
        .split(/ and (?=Minister)/).map(&:tidy)
    end

    private

    # There are three different sections: Premier+Deputy / Ministers / Ex-Officio
    # The first has a different layout from the latter two

    def text
      return noko.text if noko.text =~ /(Minister|Deputy|Attorney)/
    end

    def parts
      return unless text

      text.split(/(?=(Minister|Deputy|Attorney))/, 2).map(&:tidy)
    end

    def fullname
      parts ? parts.first : noko.text
    end

    def fullposition
      parts ? parts.last : noko.parent.next.text.tidy
    end
  end

  class Members
    def member_container
      noko.xpath('//span[@style="font-size:16px"]').select { |node| node.text.start_with? 'Hon.' }
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
