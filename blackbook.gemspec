--- !ruby/object:Gem::Specification 
name: blackbook
version: !ruby/object:Gem::Version 
  version: 1.0.5
platform: ruby
authors: 
- Contentfree
autorequire: 
bindir: bin
cert_chain: 
- |
  -----BEGIN CERTIFICATE-----
  MIIDPDCCAiSgAwIBAgIBADANBgkqhkiG9w0BAQUFADBEMRYwFAYDVQQDDA1taWtl
  bW9uZHJhZ29uMRUwEwYKCZImiZPyLGQBGRYFZ21haWwxEzARBgoJkiaJk/IsZAEZ
  FgNjb20wHhcNMDcwODI3MTk1NjQ1WhcNMDgwODI2MTk1NjQ1WjBEMRYwFAYDVQQD
  DA1taWtlbW9uZHJhZ29uMRUwEwYKCZImiZPyLGQBGRYFZ21haWwxEzARBgoJkiaJ
  k/IsZAEZFgNjb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD9J/K2
  wp3uqpMzXOfOlY+zb2qRuP0Q6SaqPf8+Y/OD4n+KR91999nRcd9MED4b9okQb5XF
  KjbIRtEyXRtX+nmajf3CqrtOe+Gej9Uru1jBiqwdegCipN2HRrqqOX0Tv15o2W6n
  Lxayxj4JD/DWLrBaKWagv87MCwb0FeKB45Z6bZFA62QM7beBSB9TY+Lv7qpW+uPk
  vlLC9nj765cU0jZNcddgLZcKVl4AihhA5YNOI6XztxA+DSYze8EryrkES8YjY+O7
  oPSSvyi/13QnIPpB884/k9alxWqzx3+qQI6UxXeVY1idS9M+1q3QC6vteo5KqE41
  enZ5Unpw288x+gc5AgMBAAGjOTA3MAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0G
  A1UdDgQWBBQfSk8NE+/Ad8ZKbEAgwIoKvI5H+TANBgkqhkiG9w0BAQUFAAOCAQEA
  ZyBadUGUGP/x2pZEIPYVcP9vG0l64wLDksJNVJ90rEgToaQqypCElvipbCXYF9Pe
  y+5G/bJItH/OKiIHcdJUs8UdXMH5icCpyqNgNopHVkVsE8gghMYm0ptHyKWswRAK
  6nBO3mw0C2n+KiWdTSXf6HtF9sBg5SV+I/kZEGHbiFEglxfiVoUnlvsCbRt2QlCC
  uMBzJ1sNVgCL3bqeEZwZj0o2HLxOHg0sSOc16rCfX5yvDo7bFM0XAMvwNgYg8ifQ
  zeHINowDygx2eefh0hynPGd/QwgANxHpr4+V93KLsyLosIgAIsqoXRkNx3a5gecL
  q8SfeAt4oNk4pWm9Ocmiww==
  -----END CERTIFICATE-----

date: 2008-02-27 00:00:00 +01:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: mechanize
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: 0.7.0
    version: 
- !ruby/object:Gem::Dependency 
  name: fastercsv
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: 1.2.0
    version: 
- !ruby/object:Gem::Dependency 
  name: hoe
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: 1.5.0
    version: 
description: "== DESCRIPTION:  Blackbook automates the nitty-gritty of importing contacts from various services and files and exporting them as VCard, XML, or simple Hash. Utilize those contacts from services like AOL, GMail, Yahoo Mail, Hotmail or CSV to help your social networking site become GIGANTIC overnight! You'll be able to get big and sell for millions before anyone figures out it's just like every other social network."
email: dave.myron@contentfree.com
executables: []

extensions: []

extra_rdoc_files: 
- CHANGES.markdown
- Manifest.txt
- README.markdown
files: 
- CHANGES.markdown
- Manifest.txt
- README.markdown
- Rakefile
- debug_blackbook.rb
- init.rb
- lib/blackbook.rb
- lib/blackbook/exporter/base.rb
- lib/blackbook/exporter/vcf.rb
- lib/blackbook/exporter/xml.rb
- lib/blackbook/importer/aol.rb
- lib/blackbook/importer/base.rb
- lib/blackbook/importer/csv.rb
- lib/blackbook/importer/gmail.rb
- lib/blackbook/importer/hotmail.rb
- lib/blackbook/importer/page_scraper.rb
- lib/blackbook/importer/yahoo.rb
- test/fixtures/aol_application_page.html
- test/fixtures/aol_bad_login_response_stage_3.html
- test/fixtures/aol_contacts.html
- test/fixtures/aol_login_response_stage_1.html
- test/fixtures/aol_login_response_stage_2.html
- test/fixtures/aol_login_response_stage_3.html
- test/fixtures/aol_login_response_stage_4.html
- test/fixtures/aol_login_response_stage_5.html
- test/fixtures/aol_new_contacts.html
- test/fixtures/gmail.csv
- test/fixtures/gmail_bad_login_response_stage_2.html
- test/fixtures/gmail_contacts.html
- test/fixtures/gmail_login_response_stage_1.html
- test/fixtures/gmail_login_response_stage_2.html
- test/fixtures/gmail_login_response_stage_2a.html
- test/fixtures/gmail_login_response_stage_3.html
- test/fixtures/hotmail_bad_login_response_stage_2.html
- test/fixtures/hotmail_contacts.html
- test/fixtures/hotmail_login_response_stage_1.html
- test/fixtures/hotmail_login_response_stage_2.html
- test/fixtures/hotmail_login_response_stage_3.html
- test/fixtures/yahoo_bad_login_response_stage_2.html
- test/fixtures/yahoo_contacts.csv
- test/fixtures/yahoo_contacts_not_logged_in.html
- test/fixtures/yahoo_contacts_stage_1.html
- test/fixtures/yahoo_login_response_stage_1.html
- test/fixtures/yahoo_login_response_stage_2.html
- test/scripts/live_test.rb
- test/test_blackbook.rb
- test/test_blackbook_exporter_base.rb
- test/test_blackbook_exporter_vcf.rb
- test/test_blackbook_exporter_xml.rb
- test/test_blackbook_importer_aol.rb
- test/test_blackbook_importer_base.rb
- test/test_blackbook_importer_csv.rb
- test/test_blackbook_importer_gmail.rb
- test/test_blackbook_importer_hotmail.rb
- test/test_blackbook_importer_page_scraper.rb
- test/test_blackbook_importer_yahoo.rb
- test/test_helper.rb
- vendor/plugins/blackbook/lib/autotest/blackbook.rb
- vendor/plugins/blackbook/lib/autotest/discover.rb
has_rdoc: true
homepage: http://rubyforge.org/projects/contentfree/
post_install_message: 
rdoc_options: 
- --main
- README.txt
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
requirements: []

rubyforge_project: contentfree
rubygems_version: 1.3.1
signing_key: 
specification_version: 2
summary: Blackbook handles the nitty-gritty of importing contacts from various service providers and contact lists and exporting them in a useful format.
test_files: 
- test/test_blackbook_importer_aol.rb
- test/test_blackbook_importer_csv.rb
- test/test_blackbook_importer_gmail.rb
- test/test_blackbook_importer_yahoo.rb
- test/test_blackbook_exporter_base.rb
- test/test_blackbook_exporter_vcf.rb
- test/test_blackbook_exporter_xml.rb
- test/test_blackbook_importer_page_scraper.rb
- test/test_helper.rb
- test/test_blackbook_importer_hotmail.rb
- test/test_blackbook.rb
- test/test_blackbook_importer_base.rb

