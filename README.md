# Melton City Council - Advertised planning applications Scraper

* Cookie tracking - No
* Pagnation - no
* Javascript - No
* Clearly defined data within a row - Yes, with some on detail page

This is a scraper that runs on [Morph](https://morph.io). 
To get started [see the documentation](https://morph.io/documentation)

Add any issues to https://github.com/planningalerts-scrapers/issues/issues

## To run the scraper

    bundle exec ruby scraper.rb

### Expected output

    Getting index page: https://www.melton.vic.gov.au/Services/Building-Planning-Transport/Statutory-planning/Advertised-planning-applications/Planning-apps-current
      Pausing 0.604s
      Fetching detail page: https://www.melton.vic.gov.au/Services/Building-Planning-Transport/Statutory-planning/Advertised-planning-applications/Planning-apps-current/211-229-Faulkners-Road-Mount-Cottrell
    Saving record PA2024/8851/1 - 211-229 Faulkners Road, Mount Cottrell, VIC
      Pausing 0.541s
      Fetching detail page: https://www.melton.vic.gov.au/Services/Building-Planning-Transport/Statutory-planning/Advertised-planning-applications/Planning-apps-current/1871-1881-Mount-Cottrell-Road-Mount-Cottrell
    Saving record PA2025/9381/1 - 1871-1881 Mount Cottrell Road, Mount Cottrell, VIC
      Pausing 0.533s
      Fetching detail page: https://www.melton.vic.gov.au/Services/Building-Planning-Transport/Statutory-planning/Advertised-planning-applications/Planning-apps-current/15-Parklea-Way-Thornhill-Park
    Saving record PA2025/9211/1 - 15 Parklea Way, Thornhill Park, VIC
      Pausing 0.933s
      Fetching detail page: https://www.melton.vic.gov.au/Services/Building-Planning-Transport/Statutory-planning/Advertised-planning-applications/Planning-apps-current/4-Walhalla-Way-Ravenhall
    Saving record PA2025/9300/1 - 4 Walhalla Way, Ravenhall, VIC
      Pausing 1.11s
      Fetching detail page: https://www.melton.vic.gov.au/Services/Building-Planning-Transport/Statutory-planning/Advertised-planning-applications/Planning-apps-current/13-Target-Street-Melton
    Saving record PA2025/9284/1 - 13 Target Street, Melton, VIC
      Pausing 0.536s
      Fetching detail page: https://www.melton.vic.gov.au/Services/Building-Planning-Transport/Statutory-planning/Advertised-planning-applications/Planning-apps-current/490-Christies-Road-Ravenhall
    Saving record PA2014/4450/4 - 490 Christies Road, Ravenhall, VIC
      Pausing 0.535s
      Fetching detail page: https://www.melton.vic.gov.au/Services/Building-Planning-Transport/Statutory-planning/Advertised-planning-applications/Planning-apps-current/141-Momentum-Way-Ravenhall
    Saving record PA2025/9431/1 - 141 Momentum Way, Ravenhall, VIC
      Pausing 0.533s
      Fetching detail page: https://www.melton.vic.gov.au/Services/Building-Planning-Transport/Statutory-planning/Advertised-planning-applications/Planning-apps-current/135-Momentum-Way-Ravenhall
    Saving record PA2025/9429/1 - 135 Momentum Way, Ravenhall, VIC
      Pausing 0.77s
      Fetching detail page: https://www.melton.vic.gov.au/Services/Building-Planning-Transport/Statutory-planning/Advertised-planning-applications/Planning-apps-current/783-857-Coburns-Road-Harkness
    Saving record PA2025/9317/1 - 783-857 Coburns Road, Harkness, VIC
    Finished! Added 9 applications, and skipped 0 unprocessable applications.

Execution time: ~ 10 seconds

## To run the tests

    bundle exec rake

## To run style and coding checks

    bundle exec rubocop

## To check for security updates

As well as GitHub's [Dependabot](https://dependabot.com/) you can use the following commmands locally to check for security vulnerabilities:

    bundle exec bundle-audit
    bundle exec ruby_audit
