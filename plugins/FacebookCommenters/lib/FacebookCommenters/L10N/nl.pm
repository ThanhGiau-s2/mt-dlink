# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package FacebookCommenters::L10N::nl;

use strict;
use base 'FacebookCommenters::L10N::en_us';
use vars qw( %Lexicon );
%Lexicon = (

## plugins/FacebookCommenters/config.yaml
	'Provides commenter registration through Facebook Connect.' => 'Voegt registratie van reageerders toe via Facebook Connect.',
	'Facebook' => 'Facebook',

## plugins/FacebookCommenters/lib/FacebookCommenters/Auth.pm
	'Set up Facebook Commenters plugin' => 'Facebook Reageerders plugin instellen',
	'The login could not be confirmed because of no/invalid blog_id' => 'Aanmelding kon niet worden bevestigd wegens geen/ongeldig blog_id',
	'Authentication failure: [_1], reason:[_2]' => 'Authenticatie mislukt: [_1], reden: [_2]',
	'Failed to created commenter.' => 'Aanmaken reageerder mislukt.',
	'Failed to create a session.' => 'Aanmaken sessie mislukt.',
	'Facebook Commenters needs either Crypt::SSLeay or IO::Socket::SSL installed to communicate with Facebook.' => 'Facebook Commenters vereist dat ofwel Crypt::SSLeay of IO::Socket::SSL geÃ¯nstalleerd zijn om met Facebook te kunnen communiceren.',
	'Please enter your Facebook App key and secret.' => 'Gelieve uw Facebook App key en secret in te vullen.',
	'Could not verify this app with Facebook: [_1]' => 'Kon deze app niet verifiÃ«ren bij Facebook: [_1]',

## plugins/FacebookCommenters/tmpl/blog_config_template.tmpl
	'OAuth Redirect URL of Facebook Login' => 'OAuth omleidings-URL of Facebook login',
	'Please set this URL to "Valid OAuth redirect URIs" field of Facebook Login.' => 'Gelieve deze URL in te stellen naar de waarde van het "Valid OAuth redirect URIs" veld van Facebook Login.',
	'Facebook App ID' => 'Facebook applicatiesleutel',
	'The key for the Facebook application associated with your blog.' => 'De sleutel voor de Facebook-applicatie geassocieerd met uw blog.',
	'Edit Facebook App' => 'Facebook app bewerken',
	'Create Facebook App' => 'Facebook app aanmaken',
	'Facebook Application Secret' => 'Facebook applicatiegeheim',
	'The secret for the Facebook application associated with your blog.' => 'Het geheim voor de Facebook-applicatie geassocieerd met uw blog.',
);

1;
