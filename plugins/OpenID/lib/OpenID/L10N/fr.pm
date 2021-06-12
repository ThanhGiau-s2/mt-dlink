package OpenID::L10N::fr;

use strict;
use warnings;
use utf8;
use base 'OpenID::L10N';

our %Lexicon = (

## plugins/OpenID/config.yaml
	q{Provides OpenID authentication.} => q{Fournit l'authentification OpenID.},

## plugins/OpenID/lib/MT/Auth/GoogleOpenId.pm
	'A Perl module required for Google ID commenter authentication is missing: [_1].' => 'Le module Perl nécessaire pour l\'authentification de commentateur par Google ID est manquant : [_1].',

## plugins/OpenID/lib/MT/Auth/OpenID.pm
	'Could not save the session' => 'Impossible de sauver la session',
	'Could not load Net::OpenID::Consumer.' => 'Impossible de charger Net::OpenID::Consumer.',
	'The address entered does not appear to be an OpenID endpoint.' => 'L\'adresse entrée ne semble pas être un service OpenID',
	'The text entered does not appear to be a valid web address.' => 'Le texte entré ne semble pas être une adresse web valide.',
	'Unable to connect to [_1]: [_2]' => 'Impossible de se connecter à [_1] : [_2]',
	'Could not verify the OpenID provided: [_1]' => 'La vérification de l\'OpenID entré a échoué : [_1]',
	'The Perl module required for OpenID commenter authentication (Digest::SHA1) is missing.' => 'Le module Perl nécessaire pour l\'authentification OpenID (Digest::SHA1) est manquant.',

## plugins/OpenID/tmpl/comment/auth_aim.tmpl
	'Your AIM or AOL Screen Name' => 'Votre pseudonyme AIM ou AOL.',
	'Sign in using your AIM or AOL screen name. Your screen name will be displayed publicly.' => 'Identifiez-vous en utilisant votre pseudonyme AIM ou AOL. Votre pseudonyme sera affiché publiquement.',

## plugins/OpenID/tmpl/comment/auth_googleopenid.tmpl
	'Sign in using your Gmail account' => 'Identifiez-vous en utilisant votre compte Gmail',
	'Sign in to Movable Type with your[_1] Account[_2]' => 'Identifiez-vous dans Movable Type avec votre compte [_1] [_2]',

## plugins/OpenID/tmpl/comment/auth_hatena.tmpl
	'Your Hatena ID' => 'Votre identifiant Hatena',

## plugins/OpenID/tmpl/comment/auth_livedoor.tmpl

## plugins/OpenID/tmpl/comment/auth_livejournal.tmpl
	'Your LiveJournal Username' => 'Votre identifiant LiveJournal',
	'Learn more about LiveJournal.' => 'En savoir plus sur LiveJournal.',

## plugins/OpenID/tmpl/comment/auth_openid.tmpl
	'OpenID URL' => 'URL OpenID',
	q{Sign in with one of your existing third party OpenID accounts.} => q{Identifiez-vous avec l'une de vos identités OpenID tierce partie.},
	'http://www.openid.net/' => 'https://openid.net',
	'Learn more about OpenID.' => 'En savoir plus sur OpenID.',

## plugins/OpenID/tmpl/comment/auth_wordpress.tmpl
	'Your Wordpress.com Username' => 'Votre pseudonyme WordPress.com',
	'Sign in using your WordPress.com username.' => 'Identifiez-vous en utilisant votre pseudonyme WordPress.com',

## plugins/OpenID/tmpl/comment/auth_yahoojapan.tmpl
	'Turn on OpenID for your Yahoo! Japan account now' => 'Activer OpenID pour votre compte Yahoo! Japon maintenant',

## plugins/OpenID/tmpl/comment/auth_yahoo.tmpl
	'Turn on OpenID for your Yahoo! account now' => 'Activer OpenID pour votre compte Yahoo! maintenant',
);

1;
