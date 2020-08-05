package Trackback::L10N::nl;

use strict;
use warnings;
use utf8;
use base 'Trackback::L10N';

our %Lexicon = (

## plugins/Trackback/config.yaml
	'Provides Trackback.' => 'Verschaft trackback.',
	'Mark as Spam' => 'Markeren als spam',
	'Remove Spam status' => 'Spamstatus verwijderen',
	'Unpublish TrackBack(s)' => 'Publicatie ongedaan maken',
	'weblogs.com' => 'weblogs.com',
	'New Ping' => 'Nieuwe ping',

## plugins/Trackback/default_templates/new-ping.mtml
	q{An unapproved TrackBack has been posted on your site '[_1]', on entry #[_2] ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Een niet goedgekeurde TrackBack werd achtergelaten op uw site '[_1]', op bericht #[_2] ([_3]).  U moet deze TrackBack eerst goedkeuren voor hij op uw site verschijnt.},
	q{An unapproved TrackBack has been posted on your site '[_1]', on page #[_2] ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Een niet goedgekeurde TrackBack werd achtergelaten op uw site '[_1]', op pagina #[_2] ([_3]).  U moet deze TrackBack eerst goedkeuren voor hij op uw site verschijnt.},
	q{An unapproved TrackBack has been posted on your site '[_1]', on category #[_2], ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Een niet goedgekeurde TrackBack werd achtergelaten op uw site '[_1]', op categorie #[_2] ([_3]).  U moet deze TrackBack eerst goedkeuren voor hij op uw site verschijnt.},
	q{A new TrackBack has been posted on your site '[_1]', on entry #[_2] ([_3]).} => q{Een nieuwe TrackBack werd achtergelaten op uw site '[_1]', op bericht #[_2] ([_3]).},
	q{A new TrackBack has been posted on your site '[_1]', on page #[_2] ([_3]).} => q{Een nieuwe TrackBack werd achtergelaten op uw site '[_1]', op pagina #[_2] ([_3]).},
	q{A new TrackBack has been posted on your site '[_1]', on category #[_2] ([_3]).} => q{Een nieuwe TrackBack werd achtergelaten op uw site '[_1]', op categorie #[_2] ([_3]).},
	'Approve TrackBack' => 'TrackBack goedkeuren',
	'View TrackBack' => 'TrackBack bekijken',
	'Report TrackBack as spam' => 'TrackBack melden als spam',
	'Edit TrackBack' => 'TrackBack bewerken',

## plugins/Trackback/default_templates/trackbacks.mtml

## plugins/Trackback/lib/MT/App/Trackback.pm
	'You must define a Ping template in order to display pings.' => 'U moet een pingsjabloon definiÃ«ren om pings te kunnen tonen.',
	'Trackback pings must use HTTP POST' => 'Trackback pings moeten HTTP POST gebruiken',
	'TrackBack ID (tb_id) is required.' => 'TrackBack ID (tb_id) is vereist.',
	'Invalid TrackBack ID \'[_1]\'' => 'Ongeldig TrackBack-ID \'[_1]\'',
	'You are not allowed to send TrackBack pings.' => 'U heeft geen toestemming om TrackBack pings te versturen.',
	'You are sending TrackBack pings too quickly. Please try again later.' => 'U stuurt te veel TrackBack pings achter elkaar.  Gelieve la
ter opnieuw te proberen.',
	'You need to provide a Source URL (url).' => 'U moet een Source URL (url) opgeven.',
	'Invalid URL \'[_1]\'' => 'Ongeldige URL URL \'[_1]\'',
	'This TrackBack item is disabled.' => 'Dit TrackBack item is uitgeschakeld.',
	'This TrackBack item is protected by a passphrase.' => 'Dit TrackBack item is beschermd door een wachtwoord.',
	'TrackBack on "[_1]" from "[_2]".' => 'TrackBack op "[_1]" van "[_2]".',
	'TrackBack on category \'[_1]\' (ID:[_2]).' => 'TrackBack op categorie \'[_1]\' (ID:[_2]).',
	'Cannot create RSS feed \'[_1]\': ' => 'Kan RSS feed \'[_1]\' niet aanmaken: ',
	'New TrackBack ping to \'[_1]\'' => 'Nieuwe TrackBack ping op \'[_1]\'',
	'New TrackBack ping to category \'[_1]\'' => 'Nieuwe TrackBack ping op categorie \'[_1]\'',

## plugins/Trackback/lib/MT/CMS/TrackBack.pm
	'(Unlabeled category)' => '(Categorie zonder label)',
	'Ping (ID:[_1]) from \'[_2]\' deleted by \'[_3]\' from category \'[_4]\'' => 'Ping (ID:[_1]) van \'[_2]\' verwijderd door \'[_3]\' van
 categorie \'[_4]\'',
	'(Untitled entry)' => '(Bericht zonder titel)',
	'Ping (ID:[_1]) from \'[_2]\' deleted by \'[_3]\' from entry \'[_4]\'' => 'Ping (ID:[_1]) van \'[_2]\' verwijderd door \'[_3]\' van be
richt \'[_4]\'',
	'No Excerpt' => 'Geen uittreksel',
	'Orphaned TrackBack' => 'Verweesde TrackBack',
	'category' => 'categorie',

## plugins/Trackback/lib/MT/Template/Tags/Ping.pm
	'<\$MTCategoryTrackbackLink\$> must be used in the context of a category, or with the \'category\' attribute to the tag.' => '<\$MTCategoryTrackbackLink\$> moet gebruikt worden in een categorie, of met het \'category\' attribuute van de tag.',

## plugins/Trackback/lib/MT/XMLRPC.pm
	'No WeblogsPingURL defined in the configuration file' => 'Geen WeblogsPingURL opgegeven in het configuratiebestand',
	'No MTPingURL defined in the configuration file' => 'Geen MTPingURL opgegeven in het configuratiebestand',
	'HTTP error: [_1]' => 'HTTP fout: [_1]',
	'Ping error: [_1]' => 'Ping fout: [_1]',

## plugins/Trackback/lib/Trackback/App/ActivityFeed.pm
	'[_1] TrackBacks' => '[_1] TrackBacks',
	'All TrackBacks' => 'Alle TrackBacks',

## plugins/Trackback/lib/Trackback/App/CMS.pm
	'Are you sure you want to remove all trackbacks reported as spam?' => 'Bent u zeker dat u alle trackbacks die als spam aangemerkt staan wenst te verwijderen?',
	'Delete all Spam trackbacks' => 'Alle spam-TrackBacks verwijderen',

## plugins/Trackback/lib/Trackback/Blog.pm
	'Cloning TrackBacks for blog...' => 'Trackbacks worden gekloond voor blog...',
	'Cloning TrackBack pings for blog...' => 'TrackBack pings worden gekloond voor blog...',

## plugins/Trackback/lib/Trackback/CMS/Comment.pm
	'You do not have permission to approve this trackback.' => 'U heeft geen permissies om deze trackback goed te keuren.',
	'The entry corresponding to this comment is missing.' => 'Het bericht dat bij deze reactie hoort, ontbreekt.',
	'You do not have permission to approve this comment.' => 'U heeft geen permissie om deze reactie goed te keuren.',

## plugins/Trackback/lib/Trackback/CMS/Entry.pm
	'Ping \'[_1]\' failed: [_2]' => 'Ping \'[_1]\' mislukt: [_2]',

## plugins/Trackback/lib/Trackback/CMS/Search.pm
	'Source URL' => 'Bron URL',

## plugins/Trackback/lib/Trackback/Import.pm
	'Creating new ping (\'[_1]\')...' => 'Nieuwe ping aan het aanmaken (\'[_1]\')...',
	'Saving ping failed: [_1]' => 'Ping opslaan mislukt: [_1]',

## plugins/Trackback/lib/Trackback.pm
	'<a href="[_1]">Ping from: [_2] - [_3]</a>' => '<a href="[_1]">Ping van: [_2] - [_3]</a>',
	'Not spam' => 'Geen spam',
	'Reported as spam' => 'Gerapporteerd als spam',
	'Trackbacks on [_1]: [_2]' => 'TrackBacks op [_1]: [_2]',
	'__PING_COUNT' => 'Trackbacks',
	'Trackback Text' => 'TrackBack tekst',
	'Trackbacks on My Entries/Pages' => 'TrackBacks op mijn berichten/pagina\'s',
	'Non-spam trackbacks' => 'Non-spam TrackBacks',
	'Non-spam trackbacks on this website' => 'Non-spam TrackBacks op deze website',
	'Pending trackbacks' => 'TrackBacks in de wachtrij',
	'Published trackbacks' => 'Gepubliceerde TrackBacks',
	'Trackbacks on my entries/pages' => 'TrackBacks op mijn berichten/pagina\'s',
	'Trackbacks in the last 7 days' => 'TrackBacks in de afgelopen 7 dagen',
	'Spam trackbacks' => 'Spam TrackBacks',

## plugins/Trackback/t/211-api-resource-objects.d/asset/from_object.yaml
	'Image photo' => 'Afbeelding foto',

## plugins/Trackback/t/211-api-resource-objects.d/asset/to_object.yaml

## plugins/Trackback/t/211-api-resource-objects.d/category/from_object.yaml

## plugins/Trackback/t/211-api-resource-objects.d/category/to_object.yaml
	'Original Test' => 'Originele test',

## plugins/Trackback/t/211-api-resource-objects.d/entry/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/authenticated/asset/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/authenticated/entry/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/non-authenticated/asset/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/non-authenticated/entry/from_object.yaml

);

1;
