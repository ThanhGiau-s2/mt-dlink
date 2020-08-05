package Comments::L10N::nl;

use strict;
use warnings;
use utf8;
use base 'Comments::L10N';

our %Lexicon = (

## plugins/Comments/config.yaml
	'Provides Comments.' => 'Levert reacties.',
	'Mark as Spam' => 'Markeren als spam',
	'Remove Spam status' => 'Spamstatus verwijderen',
	'Unpublish Comment(s)' => 'Publicatie ongedaan maken',
	'Trust Commenter(s)' => 'Reageerder(s) vertrouwen',
	'Untrust Commenter(s)' => 'Reageerder(s) niet meer vertrouwen',
	'Ban Commenter(s)' => 'Reageerder(s) verbannen',
	'Unban Commenter(s)' => 'Verbanning opheffen',
	'Registration' => 'Registratie',
	'Manage Commenters' => 'Reageerders beheren',
	'Comment throttle' => 'Beperking reacties',
	'Commenter Confirm' => 'Bevestiging reageerder',
	'Commenter Notify' => 'Notificatie reageerder',
	'New Comment' => 'Nieuwe reactie',

## plugins/Comments/default_templates/comment_detail.mtml

## plugins/Comments/default_templates/commenter_confirm.mtml
	'Thank you for registering an account to comment on [_1].' => 'Bedankt om een account aan te maken om te kunnen reageren op [_1].',
	'For your security and to prevent fraud, we ask you to confirm your account and email address before continuing. Once your account is confirmed, you will immediately be allowed to comment on [_1].' => 'Voor uw eigen veiligheid en om fraude tegen te gaan, vragen we u om uw account en email adres te bevestigen vooraleer verder te gaan.  Zodra uw account bevestigd is, kunt u meteen reageren op [_1].',
	'To confirm your account, please click on the following URL, or cut and paste this URL into a web browser:' => 'Om uw account te bevestigen moet u op volgende URL klikken of hem in uw webbrowser knippen en plakken.',
	q{If you did not make this request, or you don't want to register for an account to comment on [_1], then no further action is required.} => q{Als u deze account niet heeft aangevraagd, of als u niet de bedoeling had te registreren om te kunnen reageren op [_1] dan hoeft u verder niets te doen.},
	'Sincerely,' => 'Hoogachtend,',

## plugins/Comments/default_templates/commenter_notify.mtml
	q{This email is to notify you that a new user has successfully registered on the blog '[_1]'. Here is some information about this new user.} => q{Deze email dient om u te melden dat een nieuwe gebruiker zich met succes heeft aangemeld op de blog '[_1]'.  Hier is wat meer informatie over deze nieuwe gebruiker.},
	'New User Information:' => 'Info nieuwe gebruiker:',
	'Full Name: [_1]' => 'Volledige naam: [_1]',
	'To view or edit this user, please click on or cut and paste the following URL into a web browser:' => 'Om deze gebruiker te bekijken of te bewerken, klik op deze link of plak de URL in een webbrowser:',

## plugins/Comments/default_templates/comment_listing.mtml

## plugins/Comments/default_templates/comment_preview.mtml

## plugins/Comments/default_templates/comment_response.mtml

## plugins/Comments/default_templates/comments.mtml

## plugins/Comments/default_templates/comment_throttle.mtml
	'If this was an error, you can unblock the IP address and allow the visitor to add it again by logging in to your Movable Type installation, choosing Blog Config - IP Banning, and deleting the IP address [_1] from the list of banned addresses.' => 'Als dit een vergissing was dan kunt u het IP adres deblokkeren en de bezoeker toelaten om het opnieuw toe te voegen door u aan te melden bij uw Movable Type installatie.  Ga vervolgens naar Blog Config - IP Blokkering en verwijder het IP adres [_1] uit de lijst van geblokkeerde adressen.',
	'A visitor to your blog [_1] has automatically been banned by adding more than the allowed number of comments in the last [_2] seconds.' => 'Een bezoeker van uw weblog [_1] is automatisch uitgesloten omdat dez meer dan het toegestane aantal reacties heeft gepubliceerd in de laatste [_2] seconden.',
	'This was done to prevent a malicious script from overwhelming your weblog with comments. The banned IP address is' => 'Dit werd gedaan om te voorkomen dat een kwaadaardig script uw weblog zou overspoelen met reacties. Het geblokkeerde IP adres is',

## plugins/Comments/default_templates/new-comment.mtml
	q{An unapproved comment has been posted on your site '[_1]', on entry #[_2] ([_3]). You need to approve this comment before it will appear on your site.} => q{Een niet goedgekeurde reactie werd achtergelaten op uw site '[_1]', op bericht #[_2] ([_3]).  U moet deze reactie eerst goedkeuren voor ze op uw site verschijnt.},
	q{An unapproved comment has been posted on your site '[_1]', on page #[_2] ([_3]). You need to approve this comment before it will appear on your site.} => q{Een niet goedgekeurde reactie werd achtergelaten op uw site '[_1]', op pagina #[_2] ([_3]).  U moet deze reactie eerst goedkeuren voor ze op uw site verschijnt.},
	q{A new comment has been posted on your site '[_1]', on entry #[_2] ([_3]).} => q{Een nieuwe reactie werd achtergelaten op uw site '[_1]', op bericht #[_2] ([_3]).},
	q{A new comment has been posted on your site '[_1]', on page #[_2] ([_3]).} => q{Een nieuwe reactie werd achtergelaten op uw site '[_1]', op pagina #[_2] ([_3]).},
	'Commenter name: [_1]' => 'Naam reageerder: [_1]',
	'Commenter email address: [_1]' => 'E-mail adres reageerder: [_1]',
	'Commenter URL: [_1]' => 'URL reageerder: [_1]',
	'Commenter IP address: [_1]' => 'IP adres reageerder: [_1]',
	'Approve comment:' => 'Reactie goedkeuren',
	'View comment:' => 'Reactie bekijken:',
	'Edit comment:' => 'Reactie bewerken:',
	'Report the comment as spam:' => 'Reactie als spam melden:',

## plugins/Comments/default_templates/recent_comments.mtml

## plugins/Comments/lib/Comments/App/ActivityFeed.pm
	'[_1] Comments' => '[_1] reacties',
	'All Comments' => 'Alle reacties',

## plugins/Comments/lib/Comments/App/CMS.pm
	'Are you sure you want to remove all comments reported as spam?' => 'Bent u zeker dat u alle reacties die als spam aangemerkt staan wenst te verwijderen?',
	'Delete all Spam comments' => 'Alle spamreacties verwijderen.',

## plugins/Comments/lib/Comments/Blog.pm
	'Cloning comments for blog...' => 'Reacties worden gekloond voor blog...',

## plugins/Comments/lib/Comments/CMS/Search.pm

## plugins/Comments/lib/Comments/Import.pm
	'Creating new comment (from \'[_1]\')...' => 'Nieuwe reactie aan het aanmaken (van \'[_1]\')...',
	'Saving comment failed: [_1]' => 'Reactie opslaan mislukt: [_1]',

## plugins/Comments/lib/Comments.pm
	'Search for other comments from anonymous commenters' => 'Zoeken naar andere reacties van anonieme reageerders',
	'__ANONYMOUS_COMMENTER' => 'Anoniem',
	'Search for other comments from this deleted commenter' => 'Zoeken naar andere reacties van deze verwijderde reageerder',
	'(Deleted)' => '(Verwijderd)',
	'Edit this [_1] commenter.' => 'Bewerk deze [_1] reageerder',
	'Comments on [_1]: [_2]' => 'Reacties op [_1]: [_2]',
	'Not spam' => 'Geen spam',
	'Reported as spam' => 'Gerapporteerd als spam',
	'All comments by [_1] \'[_2]\'' => 'Alle reacties van [_1] \'[_2]\'',
	'__COMMENTER_APPROVED' => 'Goedgekeurd',
	'Moderator' => 'Moderator',
	'Can comment and manage feedback.' => 'Kan reageren en feedback beheren',
	'Can comment.' => 'Kan reageren.',
	'__COMMENT_COUNT' => 'Reacties',
	'Comments on My Entries/Pages' => 'Reacties op mijn berichten/pagina\'s',
	'Entry/Page Status' => 'Status bericht/pagina',
	'Date Commented' => 'Datum gereageerd',
	'Comments in This Website' => 'Reacties op deze website',
	'Comments in This Site' => 'Reacties op deze website',
	'Non-spam comments' => 'Non-spam reacties',
	'Non-spam comments on this website' => 'Non-spam reacties op deze website',
	'Pending comments' => 'Te modereren reacties',
	'Published comments' => 'Gepubliceerde reacties',
	'Comments on my entries/pages' => 'Reacties op mijn berichten/pagina\'s',
	'Comments in the last 7 days' => 'Reacties in de afgelopen 7 dagen',
	'Spam comments' => 'Spamreacties',
	'Enabled Commenters' => 'Actieve reageerders',
	'Disabled Commenters' => 'Gedesactiveerde reageerders',
	'Pending Commenters' => 'Reageerders in aanvraag',
	'Externally Authenticated Commenters' => 'Extern geauthenticeerde reageerders',
	'Entries with Comments Within the Last 7 Days' => 'Berichten met reacties in de laatste zeven dagen',
	'Pages with comments in the last 7 days' => 'Pagina\'s waarop in de laatste zeven dagen gereageerd werd',

## plugins/Comments/lib/Comments/Upgrade.pm
	'Creating initial comment roles...' => 'Bezig initiõ�¼„e rollen aan te maken voor reacties...',

## plugins/Comments/lib/MT/App/Comments.pm
	'Error assigning commenting rights to user \'[_1] (ID: [_2])\' for weblog \'[_3] (ID: [_4])\'. No suitable commenting role was found.' => 'Fout bij het toekennen van reactierechten aan gebruiker \'[_1] (ID: [_2])\' op weblog \'[_3] (ID: [_4])\'.  Er werd geen geschikte reageerder-rol gevonden.',
	'Invalid commenter login attempt from [_1] to blog [_2](ID: [_3]) which does not allow Movable Type native authentication.' => 'Ongeldige aanmeldpoging van een reageerder [_1] op blog [_2](ID: [_3]) waar geenMovable Type native authenticatie is toegelaten.',
	'Successfully authenticated, but signing up is not allowed.  Please contact your Movable Type system administrator.' => 'U bent met succes aangemeld, maar registratie is niet toegestaan op dit moment.  Gelieve contact op te nemen met uw Movable Type systeembeheerder.',
	'You need to sign up first.' => 'U moet zich eerst registreren',
	'Login failed: permission denied for user \'[_1]\'' => 'Aanmelden mislukt: permissie geweigerd aan gebruiker \'[_1]\'',
	'Login failed: password was wrong for user \'[_1]\'' => 'Aanmelden mislukt: fout in wachtwoord van gebruiker \'[_1]\'',
	'Signing up is not allowed.' => 'Registreren is niet toegestaan.',
	'Movable Type Account Confirmation' => 'Movable Type accountbevestiging',
	'Your confirmation has expired. Please register again.' => 'Uw bevestigingsperiode is afgelopen.  Gelieve opnieuw te registreren.',
	'<a href="[_1]">Return to the original page.</a>' => '<a href="[_1]">Terugkeren naar de oorspronkelijke pagina.</a>',
	'Commenter \'[_1]\' (ID:[_2]) has been successfully registered.' => 'Reageerder \'[_1]\' (ID:[_2]) heeft zich met succes geregistreerd.',
	'Thanks for the confirmation.  Please sign in to comment.' => 'Bedankt voor de bevestiging.  Gelieve u aan te melden om te reageren.',
	'[_1] registered to the blog \'[_2]\'' => '[_1] registreerde zich op blog \'[_2]\'',
	'No id' => 'Geen id',
	'No such comment' => 'Reactie niet gevonden',
	'IP [_1] banned because comment rate exceeded 8 comments in [_2] seconds.' => 'IP [_1] verbannen omdat aantal reacties hoger was dan 8 in [_2] seconden.',
	'IP Banned Due to Excessive Comments' => 'IP verbannen wegens excessief achterlaten van reacties',
	'No such entry \'[_1]\'.' => 'Geen bericht \'[_1]\'.',
	'_THROTTLED_COMMENT' => 'U heeft in een korte periode te veel reacties achtergelaten.  Gelieve over enige tijd opnieuw te proberen.',
	'Comments are not allowed on this entry.' => 'Reacties op dit bericht zijn niet toegelaten.',
	'Comment text is required.' => 'Tekst van de reactie is verplicht.',
	'Registration is required.' => 'Registratie is verplicht.',
	'Name and E-mail address are required.' => 'Naam en e-mail adres zijn vereist',
	'Invalid URL \'[_1]\'' => 'Ongeldige URL \'[_1]\'',
	'Comment save failed with [_1]' => 'Opslaan van reactie mislukt met [_1]',
	'Comment on "[_1]" by [_2].' => 'Reactie op "[_1]" door [_2].',
	'Failed comment attempt by pending registrant \'[_1]\'' => 'Mislukte poging om een reactie achter te laten van op registratie wachtende gebruiker \'[_1]\'',
	'You are trying to redirect to external resources. If you trust the site, please click the link: [_1]' => 'U probeert om te leiden naar externe bronnen.  Als u de site vertrouwt, klik dan op de link: [_1]',
	'No entry was specified; perhaps there is a template problem?' => 'Geen bericht opgegeven; misschien is er een sjabloonprobleem?',
	'Somehow, the entry you tried to comment on does not exist' => 'Het bericht waar u een reactie op probeerde achter te laten, bestaat niet',
	'Invalid entry ID provided' => 'Ongeldig berichtID opgegeven',
	'All required fields must be populated.' => 'Alle vereiste velden moeten worden ingevuld.',
	'Commenter profile has successfully been updated.' => 'Reageerdersprofiel is met succes bijgewerkt.',
	'Commenter profile could not be updated: [_1]' => 'Reageerdersprofiel kon niet worden bijgewerkt: [_1]',

## plugins/Comments/lib/MT/CMS/Comment.pm
	'No such commenter [_1].' => 'Geen reageerder [_1].',
	'User \'[_1]\' trusted commenter \'[_2]\'.' => 'Gebruiker \'[_1]\' gaf reageerder \'[_2]\' de status VERTROUWD.',
	'User \'[_1]\' banned commenter \'[_2]\'.' => 'Gebruiker \'[_1]\' verbande reageerder \'[_2]\'.',
	'User \'[_1]\' unbanned commenter \'[_2]\'.' => 'Gebruiker \'[_1]\' maakte de verbanning van reageerder \'[_2]\' ongedaan.',
	'User \'[_1]\' untrusted commenter \'[_2]\'.' => 'Gebruiker \'[_1]\' gaf reageerder \'[_2]\' de status NIET VERTROUWD.',
	'The parent comment id was not specified.' => 'Het ID van de ouder van de reactie werd niet opgegeven.',
	'The parent comment was not found.' => 'De ouder-reactie werd niet gevonden.',
	'You cannot reply to unapproved comment.' => 'U kunt niet antwoorden op een niet-gekeurde reactie.',
	'You cannot create a comment for an unpublished entry.' => 'U kunt geen reactie aanmaken op een ongepubliceerd bericht.',
	'You cannot reply to unpublished comment.' => 'U kunt niet reageren op een niet gepubliceerde reactie.',
	'Comment (ID:[_1]) by \'[_2]\' deleted by \'[_3]\' from entry \'[_4]\'' => 'Reactie (ID:[_1]) door \'[_2]\' verwijderd door \'[_3]\' van bericht \'[_4]\'',
	'You do not have permission to approve this trackback.' => 'U heeft geen permissie om deze trackback goed te keuren.',
	'The entry corresponding to this comment is missing.' => 'Het bericht waarbij deze reactie hoort, ontbreekt.',
	'You do not have permission to approve this comment.' => 'U heeft geen permissie om deze reactie goed te keuren.',
	'Orphaned comment' => 'Verweesde reactie',

## plugins/Comments/lib/MT/DataAPI/Endpoint/Comment.pm

## plugins/Comments/lib/MT/Template/Tags/Commenter.pm
	'This \'[_1]\' tag has been deprecated. Please use \'[_2]\' instead.' => 'Deze \'[_1]\' tag word niet meer gebruikt.  Gelieve \'[_2]\' te gebruiken.',

## plugins/Comments/lib/MT/Template/Tags/Comment.pm
	'The MTCommentFields tag is no longer available.  Please include the [_1] template module instead.' => 'De MTCommentFields tag is niet langer beschikbaar.  Gelieve in de plaats de [_1] sjabloonmodule te includeren.',

## plugins/Comments/php/function.mtcommentauthorlink.php

## plugins/Comments/php/function.mtcommentauthor.php

## plugins/Comments/php/function.mtcommenternamethunk.php
	'The \'[_1]\' tag has been deprecated. Please use the \'[_2]\' tag in its place.' => 'De \'[_1]\' tag is verouderd.  Gelieve de \'[_2]\' tag te gebruiken ter vervanging.',

## plugins/Comments/php/function.mtcommentreplytolink.php

## plugins/Comments/t/211-api-resource-objects.d/asset/from_object.yaml
	'Image photo' => 'Afbeelding foto',

## plugins/Comments/t/211-api-resource-objects.d/asset/to_object.yaml

## plugins/Comments/t/211-api-resource-objects.d/category/from_object.yaml

## plugins/Comments/t/211-api-resource-objects.d/category/to_object.yaml
	'Original Test' => 'Originele test',

## plugins/Comments/t/211-api-resource-objects.d/entry/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/authenticated/asset/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/authenticated/entry/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/non-authenticated/asset/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/non-authenticated/entry/from_object.yaml

);

1;
