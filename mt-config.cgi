## Movable Type Configuration File
##
## This file defines system-wide
## settings for Movable Type. In 
## total, there are over a hundred 
## options, but only those 
## critical for everyone are listed 
## below.
##
## Information on all others can be 
## found at:
##  https://www.movabletype.jp/documentation/config

#======== REQUIRED SETTINGS ==========

CGIPath        /cgi-bin/mt/
StaticWebPath  /mt-static/
StaticFilePath /Applications/AMPPS/www/mt-static

#======== DATABASE SETTINGS ==========

ObjectDriver DBI::sqlite
Database /Applications/AMPPS/www/cgi-bin/mt/db/mt.db

#======== MAIL =======================
EmailAddressMain vogiau2381@gmail.com
MailTransfer smtp
SMTPServer localhost
SMTPPort 25
    
DefaultLanguage ja

ImageDriver ImageMagick
SSLVerifyNone 1
