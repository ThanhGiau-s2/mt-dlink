# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package FacebookCommenters::L10N::fr;

use strict;
use base 'FacebookCommenters::L10N::en_us';
use vars qw( %Lexicon );
%Lexicon = (
## plugins/FacebookCommenters/config.yaml
	q{Provides commenter registration through Facebook Connect.} => q{Permet l'enregistrement des auteurs de commentaires via Facebook Connect},
	'Facebook' => 'Facebook',

## plugins/FacebookCommenters/lib/FacebookCommenters/Auth.pm
	'Set up Facebook Commenters plugin' => 'Configurer le plugin Facebook Commenters',
	'The login could not be confirmed because of no/invalid blog_id' => 'Login non confirmé pour cause de blog_id inexistant ou invalide',
	'Authentication failure: [_1], reason:[_2]' => 'Échec de l\'authentification : [_1], raison : [_2]',
	'Failed to created commenter.' => 'Impossible de créer le commentateur.',
	'Failed to create a session.' => 'Impossible de créer une session.',
	'Facebook Commenters needs either Crypt::SSLeay or IO::Socket::SSL installed to communicate with Facebook.' => 'Facebook Commenters nécessite l\'installation de Crypt::SSLeay ou de IO::Socket::SSL pour communiquer avec Facebook.',
	'Please enter your Facebook App key and secret.' => 'Veuillez entrer votre clé et code secret d\'application Facebook.',
	'Could not verify this app with Facebook: [_1]' => 'impossible de vérifier cette application avec Facebook : [_1]',

## plugins/FacebookCommenters/tmpl/blog_config_template.tmpl
	q{OAuth Redirect URL of Facebook Login} => q{URL de redirection OAuth pour l'authentification Facebook},
	q{Please set this URL to "Valid OAuth redirect URIs" field of Facebook Login.} => q{Renseignez cette URL avec le champ "Valid OAuth redirect URIs" de l'authentification Facebook.},
	'Facebook App ID' => 'Clé Application Facebook',
	q{The key for the Facebook application associated with your blog.} => q{La clé pour l'application Facebook associée à votre blog.},
	q{Edit Facebook App} => q{Éditer l'application Facebook},
	'Create Facebook App' => 'Créer une application Facebook',
	'Facebook Application Secret' => 'Secret Application Facebook',
	q{The secret for the Facebook application associated with your blog.} => q{Le secret pour l'application Facebook associée à votre blog.},

);

1;
