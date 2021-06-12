package OpenID::L10N::de;

use strict;
use warnings;
use utf8;
use base 'OpenID::L10N';

our %Lexicon = (

## plugins/OpenID/config.yaml
	'Provides OpenID authentication.' => 'Ermöglicht Authentifizierung über OpenID',

## plugins/OpenID/lib/MT/Auth/GoogleOpenId.pm
	'A Perl module required for Google ID commenter authentication is missing: [_1].' => 'Ein zur Authentifizierung von Kommentarautoren per Google ID erforderliches Perl-Moduul fehlt: [_1].',

## plugins/OpenID/lib/MT/Auth/OpenID.pm
	'Could not save the session' => 'Konnte Session nicht speichern.',
	'Could not load Net::OpenID::Consumer.' => 'Konnte Net::OpenID::Consumer nicht laden.',
	'The address entered does not appear to be an OpenID endpoint.' => 'Die angebene Adresse ist kein OpenID-Endpunkt.',
	'The text entered does not appear to be a valid web address.' => 'Der eingegebene Text ist keine gültige Web-Adresse.',
	'Unable to connect to [_1]: [_2]' => 'Konnte keine Verbindung zu [_1] aufbauen: [_2]',
	'Could not verify the OpenID provided: [_1]' => 'Die angegebene OpenID konnte nicht bestätigt werden: [_1]',

## plugins/OpenID/tmpl/comment/auth_aim.tmpl
	'Your AIM or AOL Screen Name' => 'Ihr AIM- oder AOL-Bildschirmname',
	'Sign in using your AIM or AOL screen name. Your screen name will be displayed publicly.' => 'Mit Ihrem AIM- oder AOL-Bildschirmnamen anmelden. Ihr Bildschirmname wird öffentlich angezeigt.',

## plugins/OpenID/tmpl/comment/auth_googleopenid.tmpl
	'Sign in using your Gmail account' => 'Mit Ihrem Gmail-Konto anmelden',
	'Sign in to Movable Type with your[_1] Account[_2]' => 'Bei Movable Type mit Ihrem[_1]-Konto[_2] anmelden',

## plugins/OpenID/tmpl/comment/auth_hatena.tmpl
	'Your Hatena ID' => 'Ihre Hatena-ID',

## plugins/OpenID/tmpl/comment/auth_livedoor.tmpl

## plugins/OpenID/tmpl/comment/auth_livejournal.tmpl
	'Your LiveJournal Username' => 'Ihr LiveJournal-Benutzername',
	'Learn more about LiveJournal.' => 'Mehr über LiveJournal erfahren',

## plugins/OpenID/tmpl/comment/auth_openid.tmpl
	'OpenID URL' => 'OpenID-URL',
	'Sign in with one of your existing third party OpenID accounts.' => 'Mit einer Ihrer vorhandenen OpenID-Kennungen anmelden',
	'http://www.openid.net/' => 'http://www.openid.net/',
	'Learn more about OpenID.' => 'Mehr über OpenID erfahren',

## plugins/OpenID/tmpl/comment/auth_wordpress.tmpl
	'Your Wordpress.com Username' => 'Ihr Wordpress.com-Benutzername',
	'Sign in using your WordPress.com username.' => 'Mit Ihrem Wordpress.com-Benutzernamen anmelden',

## plugins/OpenID/tmpl/comment/auth_yahoojapan.tmpl
	'Turn on OpenID for your Yahoo! Japan account now' => 'OpenID für Ihr Yahoo! Japan-Konto jetzt aktivieren',

## plugins/OpenID/tmpl/comment/auth_yahoo.tmpl
	'Turn on OpenID for your Yahoo! account now' => 'Aktivieren Sie jetzt OpenID für Ihr Yahoo!-Benutzerkonto',
);

1;
