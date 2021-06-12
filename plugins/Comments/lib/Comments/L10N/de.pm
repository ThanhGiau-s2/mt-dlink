package Comments::L10N::de;

use strict;
use warnings;
use utf8;
use base 'Comments::L10N';

our %Lexicon = (

## plugins/Comments/config.yaml
	'Provides Comments.' => 'Ermöglicht Kommentare. ',
	'Mark as Spam' => 'Als Spam markieren',
	'Remove Spam status' => 'Kein Spam',
	'Unpublish Comment(s)' => 'Kommentar(e) nicht mehr veröffentlichen',
	'Trust Commenter(s)' => 'Kommentarautor(en) vertrauen',
	'Untrust Commenter(s)' => 'Kommentarautor(en) nicht mehr vertrauen',
	'Ban Commenter(s)' => 'Kommentarautor(en) sperren',
	'Unban Commenter(s)' => 'Kommentator(en) nicht mehr sperren',
	'Registration' => 'Registrierung',
	'Manage Commenters' => 'Kommentar-Autoren verwalten',
	'Comment throttle' => 'Kommentarbegrenzung',
	'Commenter Confirm' => 'Kommentarautorenbestätigung',
	'Commenter Notify' => 'Kommentarautorenbenachrichtigung',
	'New Comment' => 'Neuer Kommentar',

## plugins/Comments/default_templates/comment_detail.mtml

## plugins/Comments/default_templates/commenter_confirm.mtml
	'Thank you for registering an account to comment on [_1].' => 'Danke, daß Sie sich zum Kommentieren bei [_1] registriert haben.',
	'For your security and to prevent fraud, we ask you to confirm your account and email address before continuing. Once your account is confirmed, you will immediately be allowed to comment on [_1].' => 'Bitte bestätigen Sie Ihr Benutzerkonto und Ihre E-Mail-Adresse. Das ist nur ein Mal erforderlich. Anschließend können Sie direkt auf [_1] Kommentare schreiben.',
	'To confirm your account, please click on the following URL, or cut and paste this URL into a web browser:' => 'Um Ihr Benutzerkonto zu bestätigen, klicken Sie auf folgende Adresse oder kopieren Sie sie in die Adresszeile Ihres Browsers:',
	q{If you did not make this request, or you don't want to register for an account to comment on [_1], then no further action is required.} => q{Sollten Sie sich nicht registriert haben oder Sie sich doch nicht auf [_1] kommentieren möchten, brauchen Sie nichts weiter zu tun.},
	'Sincerely,' => ' Ihr',

## plugins/Comments/default_templates/commenter_notify.mtml
	q{This email is to notify you that a new user has successfully registered on the blog '[_1]'. Here is some information about this new user.} => q{Ein neuer Benutzer hat sich erfolgreich auf '[_1]' registriert. Hier die Angaben dieses Benutzers.},
	'New User Information:' => 'Informationen über den neuen Benutzer:',
	'Full Name: [_1]' => 'Vollständiger Name: [_1]',
	'To view or edit this user, please click on or cut and paste the following URL into a web browser:' => 'Um das zugehörige Benutzerkonto aufzurufen oder zu bearbeiten, klicken Sie bitte auf folgende Adresse (oder kopieren Sie sie und fügen Sie sie in Adresszeile Ihres Browsers ein):',

## plugins/Comments/default_templates/comment_listing.mtml

## plugins/Comments/default_templates/comment_preview.mtml

## plugins/Comments/default_templates/comment_response.mtml

## plugins/Comments/default_templates/comments.mtml

## plugins/Comments/default_templates/comment_throttle.mtml
	'If this was an error, you can unblock the IP address and allow the visitor to add it again by logging in to your Movable Type installation, choosing Blog Config - IP Banning, and deleting the IP address [_1] from the list of banned addresses.' => 'Soll diese Adresse nicht gesperrt und dem Benutzer ermöglicht werden, wieder von dieser Adresse aus kommentieren zu können, entfernen Sie sie unter Blog-Konfiguration - IP-Sperren aus der Sperrliste.',
	'A visitor to your blog [_1] has automatically been banned by adding more than the allowed number of comments in the last [_2] seconds.' => 'Die IP-Adresse eines Besuchers Ihres Weblogs [_1] wurde automatisch gesperrt, da er versucht hat, mehr Kommentare als in [_2] Sekunden zulässig zu veröffentlichen.',
	'This was done to prevent a malicious script from overwhelming your weblog with comments. The banned IP address is' => 'Dadurch wird verhindert, daß Ihr Blog mit automatisch erzeugten Kommentaren überschwemmt wird. Die gesperrte Adresse lautet',

## plugins/Comments/default_templates/new-comment.mtml
	q{An unapproved comment has been posted on your site '[_1]', on entry #[_2] ([_3]). You need to approve this comment before it will appear on your site.} => q{Zu Eintrag #[_2] ([_3]) Ihrer Website '[_1]' ist ein noch nicht freigeschalteter Kommentar eingegangen. Schalten Sie ihn frei, um ihn auf Ihrer Website erscheinen zu lassen.},
	q{An unapproved comment has been posted on your site '[_1]', on page #[_2] ([_3]). You need to approve this comment before it will appear on your site.} => q{Zu Seite #[_2] ([_3]) Ihrer Website '[_1]' ist ein noch nicht freigeschalteter Kommentar eingegangen. Schalten Sie ihn frei, um ihn auf Ihrer Website erscheinen zu lassen.},
	q{A new comment has been posted on your site '[_1]', on entry #[_2] ([_3]).} => q{Zu Eintrag #[_2] ([_3]) ist ein neuer Kommentar auf Ihrer Website '[_1]' erschienen.},
	q{A new comment has been posted on your site '[_1]', on page #[_2] ([_3]).} => q{Zu Seite #[_2] ([_3]) ist ein neuer Kommentar auf Ihrer Website '[_1]' erschienen.},
	'Commenter name: [_1]' => 'Name des Kommentarautors: [_1]',
	'Commenter email address: [_1]' => 'E-Mail-Adresse des Kommentarautors: [_1]',
	'Commenter URL: [_1]' => 'Web-Adresse (URL) des Kommentarautors:',
	'Commenter IP address: [_1]' => 'IP-Adresse des Kommentarautors:',
	'Approve comment:' => 'Kommentar freischalten:',
	'View comment:' => 'Kommentar ansehen:',
	'Edit comment:' => 'Kommentar bearbeiten:',
	'Report the comment as spam:' => 'Kommentar als Spam melden:',

## plugins/Comments/default_templates/recent_comments.mtml

## plugins/Comments/lib/Comments/App/ActivityFeed.pm
	'[_1] Comments' => '[_1] Kommentare',
	'All Comments' => 'Alle Kommentare',

## plugins/Comments/lib/Comments/App/CMS.pm
	'Are you sure you want to remove all comments reported as spam?' => 'Wirklich alle als Spam markierte Kommentare löschen?',
	'Delete all Spam comments' => 'Alle Spam-Kommentare löschen',

## plugins/Comments/lib/Comments/Blog.pm
	'Cloning comments for blog...' => 'Klone Kommentare für Weblog...',

## plugins/Comments/lib/Comments/CMS/Search.pm

## plugins/Comments/lib/Comments/Import.pm
	'Creating new comment (from \'[_1]\')...' => 'Lege neuen Kommentar (von &#8222;[_1]&#8220;) an...',
	'Saving comment failed: [_1]' => 'Der Kommentar konnte nicht gespeichert werden: [_1]',

## plugins/Comments/lib/Comments.pm
	'Search for other comments from anonymous commenters' => 'Nach anderen anonym abgegeben Kommentaren suchen',
	'__ANONYMOUS_COMMENTER' => 'Anonym',
	'Search for other comments from this deleted commenter' => 'Nach anderen Kommentaren des gelöschten Autors suchen',
	'(Deleted)' => '(Gelöscht)',
	'Edit this [_1] commenter.' => 'Diesen [_1] Kommentar-Autor bearbeiten',
	'Comments on [_1]: [_2]' => 'Kommentare zu [_1]: [_2]',
	'Not spam' => 'Nicht Spam',
	'Reported as spam' => 'Als Spam gemeldet',
	'All comments by [_1] \'[_2]\'' => 'Alle Kommentare von [_1] &#8222;[_2]&#8220;',
	'__COMMENTER_APPROVED' => 'Bestätigt',
	'Moderator' => 'Moderator',
	'Can comment and manage feedback.' => 'Kann kommentieren und Feedback verwalten',
	'Can comment.' => 'Kann kommentieren',
	'__COMMENT_COUNT' => 'Kommentare',
	'Comments on My Entries/Pages' => 'Kommentare zu meinen Einträgen/Seiten',
	'Entry/Page Status' => 'Eintrags-/Seiten-Status',
	'Date Commented' => 'Kommentardatum',
	'Comments in This Website' => 'Kommentare auf dieser Website',
	'Comments in This Site' => 'Kommentare auf dieser Website',
	'Non-spam comments' => 'Gültige Kommentare',
	'Non-spam comments on this website' => 'Gültige Kommentare auf dieser Website',
	'Pending comments' => 'Zu moderierende Kommentare',
	'Published comments' => 'Veröffentlichte Kommentare',
	'Comments on my entries/pages' => 'Kommentare zu meinen Einträgen/Seiten',
	'Comments in the last 7 days' => 'Kommentare der letzten 7 Tage',
	'Spam comments' => 'Spam-Kommentare',
	'Enabled Commenters' => 'Aktive Kommentar-Autoren',
	'Disabled Commenters' => 'Deaktivierte Kommentar-Autoren',
	'Pending Commenters' => 'Wartende Kommentar-Autoren',
	'Externally Authenticated Commenters' => 'Extern authentifizierte Kommentar-Autoren',
	'Entries with Comments Within the Last 7 Days' => 'Einträge mit Kommentaren in den letzten 7 Tagen',
	'Pages with comments in the last 7 days' => 'Seiten mit Kommentaren in den letzten 7 Tagen',

## plugins/Comments/lib/Comments/Upgrade.pm
	'Creating initial comment roles...' => 'Lege ursprüngliche Kommentar-Rollen an...',

## plugins/Comments/lib/MT/App/Comments.pm
	'Error assigning commenting rights to user \'[_1] (ID: [_2])\' for weblog \'[_3] (ID: [_4])\'. No suitable commenting role was found.' => 'Fehler bei der Zuweisung von Kommentierungsrechten an Benutzer &#8222;[_1] (ID: [_2])&#8220; für Weblog \'[_3] (ID: [_4])\'. Keine geeignete Kommentierungsrolle gefunden.',
	'Invalid commenter login attempt from [_1] to blog [_2](ID: [_3]) which does not allow Movable Type native authentication.' => 'Ungültiger Anmeldeversuch von Kommentarautor [_1] an Weblog [_2](ID: [_3]) - native Movable Type-Authentifizierung bei diesem Weblog nicht zulässig.',
	'Successfully authenticated, but signing up is not allowed.  Please contact your Movable Type system administrator.' => 'Sie haben sich erfolgreich authentifiziert, dürfen sich aber nicht anmelden. Bitte wenden Sie sich an Ihren Movable-Type-Administrator.',
	'You need to sign up first.' => 'Bitte registrieren Sie sich zuerst.',
	'Login failed: permission denied for user \'[_1]\'' => 'Anmeldung fehlgeschlagen: Zugriff verweigert für Benutzer &#8222;[_1]&#8220;',
	'Login failed: password was wrong for user \'[_1]\'' => 'Anmeldung fehlgeschlagen: falsches Passwort für Benutzer &#8222;[_1]&#8220;',
	'Signing up is not allowed.' => 'Registrierungen sind nicht erlaubt.',
	'Movable Type Account Confirmation' => 'Movable Type-Anmeldungsbestätigung',
	'Your confirmation has expired. Please register again.' => 'Ihre Bestätigung ist nicht mehr gültig. Bitte registrieren Sie sich erneut.',
	'<a href="[_1]">Return to the original page.</a>' => '<a href="[_1]">Zurück zur Ausgangsseite</a>',
	'Commenter \'[_1]\' (ID:[_2]) has been successfully registered.' => 'Kommentarautor &#8222;[_1]&#8220; (ID:[_2]) erfolgreich registriert.',
	'Thanks for the confirmation.  Please sign in to comment.' => 'Vielen Dank für Ihre Bestätigung. Sie können sich jetzt anmelden und kommentieren.',
	'[_1] registered to the blog \'[_2]\'' => '[_1] hat sich für das Blog &#8222;[_2]&#8220; registriert.',
	'No id' => 'Keine ID',
	'No such comment' => 'Kein entsprechender Kommentar',
	'IP [_1] banned because comment rate exceeded 8 comments in [_2] seconds.' => 'IP [_1] gesperrt, da mehr als 8 Kommentare in [_2] Sekunden abgegeben wurden.',
	'IP Banned Due to Excessive Comments' => 'IP-Adresse wegen exzessiver Kommentarabgabe gesperrt',
	'No such entry \'[_1]\'.' => 'Kein Eintrag &#8222;[_1]&#8220;.',
	'_THROTTLED_COMMENT' => 'Sie haben zu viele Kommentare in schneller Folge abgegeben. Bitte versuchen Sie es in einigen Augenblicken erneut.',
	'Comments are not allowed on this entry.' => 'Zu diesem Eintrag können keine Kommentare abgegeben werden.',
	'Comment text is required.' => 'Bitte geben Sie einen Kommentartext ein.',
	'Registration is required.' => 'Registrierung erforderlich',
	'Name and E-mail address are required.' => 'Name und E-Mail-Adresse sind erforderlich',
	'Invalid URL \'[_1]\'' => 'Ungültige Web-Adresse (URL) &#8222;[_1]&#8220;',
	'Comment save failed with [_1]' => 'Der Kommentar konnte nicht gespeichert werden: [_1]',
	'Comment on "[_1]" by [_2].' => 'Kommentar zu "[_1]" von [_2].',
	'Failed comment attempt by pending registrant \'[_1]\'' => 'Fehlgeschlagener Kommentierungsversuch durch wartenden Kommentarautoren &#8222;[_1]&#8220;',
	'You are trying to redirect to external resources. If you trust the site, please click the link: [_1]' => 'Weiterleitung auf eine externe Website. Wenn Sie dieser Site vertrauen, klicken Sie bitte auf diesen Link: [_1]',
	'No entry was specified; perhaps there is a template problem?' => 'Es wurde kein Eintrag angegeben. Vielleicht gibt es ein Problem mit der Vorlage?',
	'Somehow, the entry you tried to comment on does not exist' => 'Der Eintrag, den Sie kommentieren möchten, existiert nicht.',
	'Invalid entry ID provided' => 'Ungültige Eintrags-ID angegeben',
	'All required fields must be populated.' => 'Alle erforderlichen Felder müssen ausgefüllt sein.',
	'Commenter profile has successfully been updated.' => 'Das Profil des Kommentarautoren wurde erfolgreich aktualisiert.',
	'Commenter profile could not be updated: [_1]' => 'Das Profil des Kommentarautoren konnte nicht aktualisiert werden: [_1]',

## plugins/Comments/lib/MT/CMS/Comment.pm
	'No such commenter [_1].' => 'Kein Kommentarautor [_1].',
	'User \'[_1]\' trusted commenter \'[_2]\'.' => 'Benutzer &#8222;[_1]&#8220; hat Kommentarautor &#8222;[_2]&#8220; das Vertrauen ausgesprochen',
	'User \'[_1]\' banned commenter \'[_2]\'.' => 'Benutzer &#8222;[_1]&#8220; hat Kommentarautor &#8222;[_2]&#8220; gesperrt',
	'User \'[_1]\' unbanned commenter \'[_2]\'.' => 'Benutzer &#8222;[_1]&#8220; hat die Sperrung von Kommentarautor &#8222;[_2]&#8220; aufgehoben',
	'User \'[_1]\' untrusted commenter \'[_2]\'.' => 'Benutzer &#8222;[_1]&#8220; hat Kommentarautor &#8222;[_2]&#8220; das Vertrauen entzogen',
	'The parent comment id was not specified.' => 'ID des Eltern-Kommentars nicht angegeben.',
	'The parent comment was not found.' => 'Eltern-Kommentar nicht gefunden.',
	'You cannot reply to unapproved comment.' => 'Sie können nicht auf nicht freigeschaltete Kommentare antworten.',
	'You cannot create a comment for an unpublished entry.' => 'Nicht veröffentlichte Einträge können nicht kommentiert werden.',
	'You cannot reply to unpublished comment.' => 'Auf nicht veröffentlichte Kommentare kann nicht geantwortet werden.',
	'Comment (ID:[_1]) by \'[_2]\' deleted by \'[_3]\' from entry \'[_4]\'' => 'Kommentar (ID:[_1]) von &#8222;[_2]&#8220; von &#8222;[_3]&#8220; aus Eintrag &#8222;[_4]&#8220; gelöscht',
	'You do not have permission to approve this trackback.' => 'Sie haben keine Benutzerrechte zur Freischaltung des TrackBacks.',
	'The entry corresponding to this comment is missing.' => 'Zugehöriger Eintrag fehlt.',
	'You do not have permission to approve this comment.' => 'Sie haben keine Benutzerrechte zur Freischaltung des Kommentars.',
	'Orphaned comment' => 'Verwaister Kommentar',

## plugins/Comments/lib/MT/DataAPI/Endpoint/Comment.pm

## plugins/Comments/lib/MT/Template/Tags/Commenter.pm
	'This \'[_1]\' tag has been deprecated. Please use \'[_2]\' instead.' => 'Der Befehl &#8222;[_1]&#8220; wird nicht mehr unterstützt. Verwenden Sie stattdessen den Befehl \'[_2]\'.',

## plugins/Comments/lib/MT/Template/Tags/Comment.pm
	'The MTCommentFields tag is no longer available.  Please include the [_1] template module instead.' => 'Der Befehl MTComentFields steht nicht mehr zur Verfügung. Binden Sie stattdessen das Vorlagenmodul [_1] ein. ',

## plugins/Comments/php/function.mtcommentauthorlink.php

## plugins/Comments/php/function.mtcommentauthor.php

## plugins/Comments/php/function.mtcommenternamethunk.php
	'The \'[_1]\' tag has been deprecated. Please use the \'[_2]\' tag in its place.' => 'Der Befehl &#8222;[_1]&#8220; ist veraltet. Bitte verwenden Sie stattdessen \'[_2]\'',

## plugins/Comments/php/function.mtcommentreplytolink.php

## plugins/Comments/t/211-api-resource-objects.d/asset/from_object.yaml
	'Image photo' => 'Bild',

## plugins/Comments/t/211-api-resource-objects.d/asset/to_object.yaml

## plugins/Comments/t/211-api-resource-objects.d/category/from_object.yaml

## plugins/Comments/t/211-api-resource-objects.d/category/to_object.yaml
	'Original Test' => 'Original-Test',

## plugins/Comments/t/211-api-resource-objects.d/entry/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/authenticated/asset/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/authenticated/entry/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/non-authenticated/asset/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/non-authenticated/entry/from_object.yaml
);

1;
