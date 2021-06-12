package Trackback::L10N::de;

use strict;
use warnings;
use utf8;
use base 'Trackback::L10N';

our %Lexicon = (

## plugins/Trackback/config.yaml
	'Provides Trackback.' => 'Ermöglicht TrackBack.',
	'Mark as Spam' => 'Als Spam markieren',
	'Remove Spam status' => 'Kein Spam',
	'Unpublish TrackBack(s)' => 'TrackBack(s) nicht mehr veröffentlichen',
	'weblogs.com' => 'weblogs.com',
	'New Ping' => 'Neuer Ping',

## plugins/Trackback/default_templates/new-ping.mtml
	q{An unapproved TrackBack has been posted on your site '[_1]', on entry #[_2] ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Zu Eintrag #[_2] ([_3]) Ihrer Website '[_1]' ist ein noch nicht freigeschaltetes TrackBack eingegangen. Schalten Sie es frei, um es auf Ihrer Website erscheinen zu lassen.},
	q{An unapproved TrackBack has been posted on your site '[_1]', on page #[_2] ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Zu Seite #[_2] ([_3]) Ihrer Website '[_1]' ist ein noch nicht freigeschaltetes TrackBack eingegangen. Schalten Sie es frei, um es auf Ihrer Website erscheinen zu lassen.},
	q{An unapproved TrackBack has been posted on your site '[_1]', on category #[_2], ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Zu Kategorie #[_2] ([_3]) Ihrer Website '[_1]' ist ein noch nicht freigeschaltetes TrackBack eingegangen. Schalten Sie es frei, um es auf Ihrer Website erscheinen zu lassen.},
	q{A new TrackBack has been posted on your site '[_1]', on entry #[_2] ([_3]).} => q{Zu Eintrag #[_2] ([_3]) ist ein neues TrackBack auf Ihrer Website '[_1]' erschienen.},
	q{A new TrackBack has been posted on your site '[_1]', on page #[_2] ([_3]).} => q{Zu Seite #[_2] ([_3]) ist ein neues TrackBack auf Ihrer Website '[_1]' erschienen.},
	q{A new TrackBack has been posted on your site '[_1]', on category #[_2] ([_3]).} => q{Zu Kategorie #[_2] ([_3]) ist ein neues TrackBack auf Ihrer Website'[_1]' erschienen.},
	'Approve TrackBack' => 'TrackBack annehmen',
	'View TrackBack' => 'TrackBack ansehen',
	'Report TrackBack as spam' => 'TrackBack als Spam melden',
	'Edit TrackBack' => 'TrackBack bearbeiten',

## plugins/Trackback/default_templates/trackbacks.mtml

## plugins/Trackback/lib/MT/App/Trackback.pm
	'You must define a Ping template in order to display pings.' => 'Sie müssen eine Ping-Vorlage definieren, um Pings anzeigen zu können.
',
	'Trackback pings must use HTTP POST' => 'Trackbacks müssen HTTP-POST verwenden',
	'TrackBack ID (tb_id) is required.' => 'TrackBack_ID (tb_id) erforderlich.',
	'Invalid TrackBack ID \'[_1]\'' => 'Ungültige TrackBack-ID &#8222;[_1]&#8220;',
	'You are not allowed to send TrackBack pings.' => 'Sie haben keine Berechtigung, TrackBack-Pings zu senden.',
	'You are sending TrackBack pings too quickly. Please try again later.' => 'Sie versenden TrackBacks-Pings zu schnell hintereinander. B
itte versuchen Sie es später erneut.',
	'You need to provide a Source URL (url).' => 'Bitte geben Sie eine Quell-URL (url) an.',
	'Invalid URL \'[_1]\'' => 'Ungültige URL \'[_1]\'',
	'This TrackBack item is disabled.' => 'Dieser TrackBack-Eintrag ist deaktiviert.',
	'This TrackBack item is protected by a passphrase.' => 'Dieser TrackBack-Eintrag ist passwortgeschützt.',
	'TrackBack on "[_1]" from "[_2]".' => 'TrackBack zu "[_1]" von "[_2]".',
	'TrackBack on category \'[_1]\' (ID:[_2]).' => 'TrackBack für Kategorie &#8222;[_1]&#8220; (ID:[_2])',
	'Cannot create RSS feed \'[_1]\': ' => 'RSS-Feed &#8222;[_1]&#8220; kann nicht angelegt werden: ',
	'New TrackBack ping to \'[_1]\'' => 'Neuer TrackBack-Ping an &#8222;[_1]&#8220;',
	'New TrackBack ping to category \'[_1]\'' => 'Neuer TrackBack-Ping an Kategorie &#8222;[_1]&#8220;',

## plugins/Trackback/lib/MT/CMS/TrackBack.pm
	'(Unlabeled category)' => '(Namenlose Kategorie)',
	'Ping (ID:[_1]) from \'[_2]\' deleted by \'[_3]\' from category \'[_4]\'' => 'Ping (ID:[_1]) von &#8222;[_2]&#8220; von &#8222;[_3]&#8
220; aus Kategorie &#8222;[_4]&#8220; gelöscht',
	'(Untitled entry)' => '(Namenloser Eintrag)',
	'Ping (ID:[_1]) from \'[_2]\' deleted by \'[_3]\' from entry \'[_4]\'' => 'Ping (ID:[_1]) von &#8222;[_2]&#8220; von &#8222;[_3]&#8220
; aus Eintrag &#8222;[_4]&#8220; gelöscht',
	'No Excerpt' => 'Kein Auszug',
	'Orphaned TrackBack' => 'Verwaistes TrackBack',
	'category' => 'Kategorien',

## plugins/Trackback/lib/MT/Template/Tags/Ping.pm
	'<\$MTCategoryTrackbackLink\$> must be used in the context of a category, or with the \'category\' attribute to the tag.' => '<\$MTCategoryTrackbackLink\$> muss im Kategoriekontext stehen oder mit dem &#8222;category&#8220;-Attribut des Tags verwendet werden.',

## plugins/Trackback/lib/MT/XMLRPC.pm
	'No WeblogsPingURL defined in the configuration file' => 'Keine WeblogsPingURL in der Konfigurationsdatei definiert',
	'No MTPingURL defined in the configuration file' => 'Keine MTPingURL in der Konfigurationsdatei definiert',
	'HTTP error: [_1]' => 'HTTP-Fehler: [_1]',
	'Ping error: [_1]' => 'Ping-Fehler: [_1]',

## plugins/Trackback/lib/Trackback/App/ActivityFeed.pm
	'[_1] TrackBacks' => '[_1] TrackBacks',
	'All TrackBacks' => 'Alle TrackBacks',

## plugins/Trackback/lib/Trackback/App/CMS.pm
	'Are you sure you want to remove all trackbacks reported as spam?' => 'Wirklich alle als Spam markierten TrackBacks löschen?',
	'Delete all Spam trackbacks' => 'Alle Spam-TrackBacks löschen',

## plugins/Trackback/lib/Trackback/Blog.pm
	'Cloning TrackBacks for blog...' => 'Klone TrackBacks für Weblog...',
	'Cloning TrackBack pings for blog...' => 'Klone TrackBack-Pings für Weblog...',

## plugins/Trackback/lib/Trackback/CMS/Comment.pm
	'You do not have permission to approve this trackback.' => 'Sie sind nicht berechtigt, TrackBacks freizuschalten.',
	'The entry corresponding to this comment is missing.' => 'Der zu diesem Kommentar gehörende Eintrag fehlt.',
	'You do not have permission to approve this comment.' => 'Sie sind nicht berechtigt, Kommentare freizuschalten.',

## plugins/Trackback/lib/Trackback/CMS/Entry.pm
	'Ping \'[_1]\' failed: [_2]' => 'Ping &#8222;[_1]&#8220; fehlgeschlagen: [_2]',

## plugins/Trackback/lib/Trackback/CMS/Search.pm
	'Source URL' => 'Quell-URL',

## plugins/Trackback/lib/Trackback/Import.pm
	'Creating new ping (\'[_1]\')...' => 'Erzeuge neuen Ping &#8222;[_1]&#8220;)...',
	'Saving ping failed: [_1]' => 'Der Ping konnte nicht gespeichert werden: [_1]',

## plugins/Trackback/lib/Trackback.pm
	'<a href="[_1]">Ping from: [_2] - [_3]</a>' => '<a href="[_1]">Ping von: [_2] - [_3]</a>',
	'Not spam' => 'Nicht Spam',
	'Reported as spam' => 'Als Spam gemeldet',
	'Trackbacks on [_1]: [_2]' => 'TrackBacks zu [_1]: [_2]',
	'__PING_COUNT' => 'TrackBacks',
	'Trackback Text' => 'TrackBack-Text',
	'Trackbacks on My Entries/Pages' => 'TrackBacks zu meinen Einträgen/Seiten',
	'Non-spam trackbacks' => 'Gültige TrackBacks',
	'Non-spam trackbacks on this website' => 'Gültige TrackBacks auf dieser Website',
	'Pending trackbacks' => 'Wartende TrackBacks',
	'Published trackbacks' => 'Veröffentlichte TrackBacks',
	'Trackbacks on my entries/pages' => 'TrackBacks zu meinen Einträgen/Seiten',
	'Trackbacks in the last 7 days' => 'TrackBacks der letzten 7 Tage',
	'Spam trackbacks' => 'Spam-TrackBacks',

## plugins/Trackback/t/211-api-resource-objects.d/asset/from_object.yaml
	'Image photo' => 'Bild',

## plugins/Trackback/t/211-api-resource-objects.d/asset/to_object.yaml

## plugins/Trackback/t/211-api-resource-objects.d/category/from_object.yaml

## plugins/Trackback/t/211-api-resource-objects.d/category/to_object.yaml
	'Original Test' => 'Original-Test',

## plugins/Trackback/t/211-api-resource-objects.d/entry/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/authenticated/asset/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/authenticated/entry/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/non-authenticated/asset/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/non-authenticated/entry/from_object.yaml

);

1;
