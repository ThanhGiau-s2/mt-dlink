package Trackback::L10N::fr;

use strict;
use warnings;
use utf8;
use base 'Trackback::L10N';

our %Lexicon = (

## plugins/Trackback/config.yaml
	'Provides Trackback.' => 'Fournit des Trackbacks.',
	'Mark as Spam' => 'Considérer comme spam',
	'Remove Spam status' => 'Ne plus considérer comme spam',
	'Unpublish TrackBack(s)' => 'Annuler la publication de ce (ou ces) TrackBacks(s)',
	'weblogs.com' => 'weblogs.com',
	'New Ping' => 'Nouveau ping',

## plugins/Trackback/default_templates/new-ping.mtml
	q{An unapproved TrackBack has been posted on your site '[_1]', on entry #[_2] ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Un TrackBack en attente de modération a été posté sur votre site '[_1]', sur la note #[_2] ([_3]). Vous devez l'approuver pour qu'il apparaisse sur votre site.},
	q{An unapproved TrackBack has been posted on your site '[_1]', on page #[_2] ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Un TrackBack en attente de modération a été posté sur votre site '[_1]', sur la page #[_2] ([_3]). Vous devez l'approuver pour qu'il apparaisse sur votre site.},
	q{An unapproved TrackBack has been posted on your site '[_1]', on category #[_2], ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Un TrackBack en attente de modération a été posté sur votre site '[_1]', sur la catégorie #[_2] ([_3]). Vous devez l'approuver pour qu'il apparaisse sur votre site.},
	q{A new TrackBack has been posted on your site '[_1]', on entry #[_2] ([_3]).} => q{Un TrackBack en attente de modération a été posté sur votre site '[_1]', sur la note #[_2] ([_3]).},
	q{A new TrackBack has been posted on your site '[_1]', on page #[_2] ([_3]).} => q{Un TrackBack en attente de modération a été posté sur votre site '[_1]', sur la page #[_2] ([_3]).},
	q{A new TrackBack has been posted on your site '[_1]', on category #[_2] ([_3]).} => q{Un TrackBack en attente de modération a été posté sur votre site '[_1]', sur la catégorie #[_2] ([_3]).},
	'Approve TrackBack' => 'Approuver le TrackBack',
	'View TrackBack' => 'Voir le TrackBack',
	'Report TrackBack as spam' => 'Signaler le TrackBack comme spam',
	'Edit TrackBack' => 'Éditer les TrackBacks',

## plugins/Trackback/default_templates/trackbacks.mtml

## plugins/Trackback/lib/MT/App/Trackback.pm
	'You must define a Ping template in order to display pings.' => 'Vous devez définir un gabarit d\'affichage Ping pour les afficher.',
	'Trackback pings must use HTTP POST' => 'Les Pings TrackBack doivent utiliser HTTP POST',
	'TrackBack ID (tb_id) is required.' => 'L\'ID de TrackBack (tb_id) est requis.',
	'Invalid TrackBack ID \'[_1]\'' => 'L\'ID de TrackBack \'[_1]\' est invalide',
	'You are not allowed to send TrackBack pings.' => 'You n\'êtes pas autorisé à envoyer des pings TrackBack.',
	'You are sending TrackBack pings too quickly. Please try again later.' => 'Vous envoyez des pings TrackBack trop rapidement. Veuillez
réessayer plus tard.',
	'You need to provide a Source URL (url).' => 'Vous devez fournir une URL source (url).',
	'Invalid URL \'[_1]\'' => 'URL invalide \'[_1]\'',
	'This TrackBack item is disabled.' => 'Cet élément TrackBack est désactivé.',
	'This TrackBack item is protected by a passphrase.' => 'Cet élément de TrackBack est protégé par un mot de passe.',
	'TrackBack on "[_1]" from "[_2]".' => 'TrackBack sur "[_1]" provenant de "[_2]".',
	'TrackBack on category \'[_1]\' (ID:[_2]).' => 'TrackBack sur la catégorie \'[_1]\' (ID:[_2]).',
	'Cannot create RSS feed \'[_1]\': ' => 'Impossible de créer le flux RSS \'[_1]\' : ',
	'New TrackBack ping to \'[_1]\'' => 'Nouveau TrackBack vers \'[_1]\'',
	'New TrackBack ping to category \'[_1]\'' => 'Nouveau TrackBack vers la catégorie \'[_1]\'',

## plugins/Trackback/lib/MT/CMS/TrackBack.pm
	'(Unlabeled category)' => '(Catégorie sans description)',
	'Ping (ID:[_1]) from \'[_2]\' deleted by \'[_3]\' from category \'[_4]\'' => 'Ping (ID:[_1]) de \'[_2]\' supprimé par \'[_3]\' de la c
atégorie \'[_4]\'',
	'(Untitled entry)' => '(Note sans titre)',
	'Ping (ID:[_1]) from \'[_2]\' deleted by \'[_3]\' from entry \'[_4]\'' => 'Ping (ID:[_1]) de \'[_2]\' supprimé par \'[_3]\' de la note
 \'[_4]\'',
	'No Excerpt' => 'Pas d\'extrait',
	'Orphaned TrackBack' => 'TrackBack orphelin',
	'category' => 'catégorie',

## plugins/Trackback/lib/MT/Template/Tags/Ping.pm
	'<\$MTCategoryTrackbackLink\$> must be used in the context of a category, or with the \'category\' attribute to the tag.' => '<\$MTCategoryTrackbackLink\$> doit être utilisé dans le contexte d\'une catégorie, ou avec l\'attribut \'category\' dans la balise.',

## plugins/Trackback/lib/MT/XMLRPC.pm
	'No WeblogsPingURL defined in the configuration file' => 'Pas de WeblogsPingURL défini dans le fichier de configuration',
	'No MTPingURL defined in the configuration file' => 'Pas de MTPingURL défini dans le fichier de configuration',
	'HTTP error: [_1]' => 'Erreur HTTP : [_1]',
	'Ping error: [_1]' => 'Erreur Ping : [_1]',

## plugins/Trackback/lib/Trackback/App/ActivityFeed.pm
	'[_1] TrackBacks' => '[_1] TrackBacks',
	'All TrackBacks' => 'Tous les TrackBacks',

## plugins/Trackback/lib/Trackback/App/CMS.pm
	'Are you sure you want to remove all trackbacks reported as spam?' => 'Voulez-vous vraiment supprimer tous les TrackBacks reportés comme spam ?',
	'Delete all Spam trackbacks' => 'Supprimer tous les TrackBacks marqués comme indésirables',

## plugins/Trackback/lib/Trackback/Blog.pm
	'Cloning TrackBacks for blog...' => 'Clonage des TrackBacks du blog...',
	'Cloning TrackBack pings for blog...' => 'Clonage des pings de TrackBack du blog...',

## plugins/Trackback/lib/Trackback/CMS/Comment.pm
	'You do not have permission to approve this trackback.' => 'Vous n\'avez pas la permission d\'approuver ce TrackBack.',
	'The entry corresponding to this comment is missing.' => 'La note correspondnate à ce commentaire est manquante.',
	'You do not have permission to approve this comment.' => 'Vous n\'avez pas la permission d\'approuver ce commentaire.',

## plugins/Trackback/lib/Trackback/CMS/Entry.pm
	'Ping \'[_1]\' failed: [_2]' => 'Le ping \'[_1]\' n\'a pas fonctionné : [_2]',

## plugins/Trackback/lib/Trackback/CMS/Search.pm
	'Source URL' => 'URL Source',

## plugins/Trackback/lib/Trackback/Import.pm
	'Creating new ping (\'[_1]\')...' => 'Création d\'un nouveau ping (\'[_1]\')...',
	'Saving ping failed: [_1]' => 'Échec de la sauvegarde du ping : [_1]',

## plugins/Trackback/lib/Trackback.pm
	'<a href="[_1]">Ping from: [_2] - [_3]</a>' => '<a href="[_1]">Ping de : [_2] - [_3]</a>',
	'Not spam' => 'Non spam',
	'Reported as spam' => 'Notifié comme spam',
	'Trackbacks on [_1]: [_2]' => 'TrackBacks sur [_1] : [_2]',
	'__PING_COUNT' => 'Nombre de pings',
	'Trackback Text' => 'Texte du TrackBack',
	'Trackbacks on My Entries/Pages' => 'TrackBacks sur mes notes/pages',
	'Non-spam trackbacks' => 'TrackBacks n\'étant pas du spam',
	'Non-spam trackbacks on this website' => 'TrackBacks n\'étant pas du spam sur ce site web',
	'Pending trackbacks' => 'TrackBacks en attente',
	'Published trackbacks' => 'TrackBacks publiés',
	'Trackbacks on my entries/pages' => 'TrackBacks sur mes notes/pages',
	'Trackbacks in the last 7 days' => 'TrackBacks des 7 derniers jours',
	'Spam trackbacks' => 'TrackBacks indésirables',

## plugins/Trackback/t/211-api-resource-objects.d/asset/from_object.yaml
	'Image photo' => 'Photo image',

## plugins/Trackback/t/211-api-resource-objects.d/asset/to_object.yaml

## plugins/Trackback/t/211-api-resource-objects.d/category/from_object.yaml

## plugins/Trackback/t/211-api-resource-objects.d/category/to_object.yaml
	'Original Test' => 'Test original',

## plugins/Trackback/t/211-api-resource-objects.d/entry/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/authenticated/asset/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/authenticated/entry/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/non-authenticated/asset/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/non-authenticated/entry/from_object.yaml

);

1;
