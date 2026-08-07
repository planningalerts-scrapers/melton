#!/usr/bin/env ruby
# frozen_string_literal: true

require "scraperwiki"
require "mechanize"

class Scraper
  INDEX_URL = "https://www.melton.vic.gov.au/Services/Building-Planning-Transport/Statutory-planning/Advertised-planning-applications/Planning-apps-current"
  STATE = "VIC"

  def clean_whitespace(text)
    text.gsub("\r", " ").gsub("\n", " ").squeeze(" ").strip
  end

  attr_accessor :pause_duration

  # Throttle block to be nice to servers we are scraping
  def throttle_block(extra_delay: 0.5)
    if @pause_duration
      puts "  Pausing #{@pause_duration}s"
      sleep(@pause_duration)
    end
    start_time = Time.now.to_f
    page = yield
    @pause_duration = (Time.now.to_f - start_time + extra_delay).round(3)
    page
  end

  # Cleanup and vacuum database of old records (planning alerts only looks at last 5 days)
  def cleanup_old_records
    cutoff_date = (Date.today - 30).to_s
    vacuum_cutoff_date = (Date.today - 35).to_s

    stats = ScraperWiki.sqliteexecute(
      "SELECT COUNT(*) as count, MIN(date_scraped) as oldest FROM data WHERE date_scraped < ?",
      [cutoff_date]
    ).first

    deleted_count = stats["count"]
    oldest_date = stats["oldest"]

    return unless deleted_count.positive? || ENV["VACUUM"]

    puts "Deleting #{deleted_count} applications scraped between #{oldest_date} and #{cutoff_date}"
    ScraperWiki.sqliteexecute("DELETE FROM data WHERE date_scraped < ?", [cutoff_date])

    # VACUUM roughly once each 33 days or if older than 35 days (first time) or if VACUUM is set
    return unless rand < 0.03 || (oldest_date && oldest_date < vacuum_cutoff_date) || ENV["VACUUM"]

    puts "  Running VACUUM to reclaim space..."
    ScraperWiki.sqliteexecute("VACUUM")
  end

  def parse_date(date_string)
    Date.parse(date_string).to_s
  rescue ArgumentError
    nil
  end

  def first_description_paragraph(main_content)
    main_content.search("p").find do |p|
      text = clean_whitespace(p.text)
      !text.empty? && text !~ /Planning Application Number|Council won't make a decision/
    end
  end

  # Extract description and on_notice_to from details page
  def extract_details(agent, info_url, record)
    detail_page = throttle_block do
      puts "  Fetching detail page: #{info_url}"
      agent.get(info_url)
    end

    main_content = detail_page.at("div#main-content")
    return unless main_content

    # Description from first em paragraph, falling back to the first
    # non-boilerplate paragraph (pages published since July 2026 dropped the em)
    first_p = main_content.at("p em") || first_description_paragraph(main_content)
    record["description"] = clean_whitespace(first_p.text) if first_p

    # on_notice_to from paragraph with "Council won't make a decision before"
    main_content.search("p").each do |p|
      text = clean_whitespace(p.text)
      next unless text =~ /Council won't make a decision before:\s*(.+)/

      date_text = ::Regexp.last_match(1)&.strip
      record["on_notice_to"] = parse_date(date_text)
      break
    end
  rescue StandardError => e
    puts "  Error fetching detail page #{info_url}: #{e.message}"
  end

  def process_card(agent, card)
    link = card.at("a")
    return unless link

    info_url = link["href"]
    info_url = "https://www.melton.vic.gov.au#{info_url}" unless info_url.start_with?("http")

    # Extract address from h2
    h2 = card.at("h2.list-item-title")
    return unless h2

    address = clean_whitespace(h2.text)
    address = "#{address}, #{STATE}" unless address.end_with?(STATE)

    # Extract council_reference from p text
    p_elem = card.at("p")
    return unless p_elem

    p_text = clean_whitespace(p_elem.text)
    unless p_text =~ /Planning Application Number:\s*(.+)/
      puts "Warning - Unable to extract council reference from: #{p_text} (skipped)"
      return
    end

    council_reference = ::Regexp.last_match(1).strip

    record = {
      "council_reference" => council_reference,
      "address" => address,
      "info_url" => info_url,
      "date_scraped" => Date.today.to_s,
    }

    # Fetch detail page for description and on_notice_to
    extract_details(agent, info_url, record)

    if record["description"].to_s.empty?
      puts "Warning - Unable to extract description for #{council_reference} (skipped)"
      return
    end
    if address.to_s.empty?
      puts "Warning - Unable to extract address for #{council_reference} (skipped)"
      return
    end

    puts "Saving record #{council_reference} - #{address}"
    ScraperWiki.save_sqlite(["council_reference"], record)
    true
  end

  def run
    agent = Mechanize.new
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE

    page = throttle_block do
      puts "Getting index page: #{INDEX_URL}"
      agent.get(INDEX_URL)
    end

    added = found = 0

    nav_container = page.at("div.landing-page-nav")
    unless nav_container
      puts "Warning - Unable to find landing-page-nav container"
      return
    end

    cards = nav_container.search("div.list-item-container")

    cards.each do |card|
      found += 1
      added += 1 if process_card(agent, card)
    end

    cleanup_old_records

    skipped = found - added
    puts "Finished! Added #{added} applications, and skipped #{skipped} unprocessable applications."
  end
end

Scraper.new.run if __FILE__ == $PROGRAM_NAME
