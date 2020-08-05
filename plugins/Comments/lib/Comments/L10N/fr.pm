package Comments::L10N::fr;

use strict;
use warnings;
use utf8;
use base 'Comments::L10N';

our %Lexicon = (

## plugins/Comments/config.yaml
	'Provides Comments.' => 'Fournit des commentaires.',
	'Mark as Spam' => 'Considérer comme spam',
	'Remove Spam status' => 'Ne plus considérer comme spam',
	'Unpublish Comment(s)' => 'Annuler la publication de ce (ou ces) commentaire(s)',
	'Trust Commenter(s)' => 'Donner le statut fiable à ce commentateur',
	'Untrust Commenter(s)' => 'Retirer le statut fiable à ce commentateur',
	'Ban Commenter(s)' => 'Bannir ce commentateur',
	'Unban Commenter(s)' => 'Lever le bannissement de ce commentateur',
	'Registration' => 'Enregistrement',
	'Manage Commenters' => 'Gérer les auteurs de commentaire',
	'Comment throttle' => 'Limitation des commentaires',
	'Commenter Confirm' => 'Confirmation du commentateur',
	'Commenter Notify' => 'Notification du commentateur',
	'New Comment' => 'Nouveau commentaire',

## plugins/Comments/default_templates/comment_detail.mtml

## plugins/Comments/default_templates/commenter_confirm.mtml
	'Thank you for registering an account to comment on [_1].' => 'Merci de vous être enregistré pour commenter sur [_1].',
	'For your security and to prevent fraud, we ask you to confirm your account and email address before continuing. Once your account is confirmed, you will immediately be allowed to comment on [_1].' => 'Pour votre sécurité et lutter contre la fraude, nous vous prions de confirmer votre compte et adresse e-mail avant de continuer. Une fois votre compte confirmé, vous pourrez commenter immédiatement sur [_1].',
	q{To confirm your account, please click on the following URL, or cut and paste this URL into a web browser:} => q{Veuillez cliquer sur le lien suivant ou copier/coller l'adresse URL dans un navigateur :},
	q{If you did not make this request, or you don't want to register for an account to comment on [_1], then no further action is required.} => q{Si vous n'êtes pas à l'origine de cette demande, ou si vous ne souhaitez pas vous enregistrer pour commenter sur [_1], alors aucune action n'est nécessaire.},
	'Sincerely,' => 'Cordialement,',

## plugins/Comments/default_templates/commenter_notify.mtml
	q{This email is to notify you that a new user has successfully registered on the blog '[_1]'. Here is some information about this new user.} => q{Un nouvel utilisateur s\'est enregistré sur le blog '[_1]'. Voici quelques informations sur ce nouvel utilisateur.},
	'New User Information:' => 'Informations concernant ce nouvel utilisateur :',
	'Full Name: [_1]' => 'Nom complet : [_1]',
	q{To view or edit this user, please click on or cut and paste the following URL into a web browser:} => q{Pour voir ou modifier cet utilisateur, merci de cliquer ou copier-coller l'adresse suivante dans votre navigateur web :},

## plugins/Comments/default_templates/comment_listing.mtml

## plugins/Comments/default_templates/comment_preview.mtml

## plugins/Comments/default_templates/comment_response.mtml

## plugins/Comments/default_templates/comments.mtml

## plugins/Comments/default_templates/comment_throttle.mtml
	q{If this was an error, you can unblock the IP address and allow the visitor to add it again by logging in to your Movable Type installation, choosing Blog Config - IP Banning, and deleting the IP address [_1] from the list of banned addresses.} => q{En cas d'erreur, vous pouvez débloquer l'adresse IP et permettre au visiteur de la rajouter et se reconnectant à votre installation Movable Type. Choisir Configuration du blog - Blocage IP, et en supprimant l'adresse IP [_1] de la liste des adresses bloquées.},
	'A visitor to your blog [_1] has automatically been banned by adding more than the allowed number of comments in the last [_2] seconds.' => 'Un visiteur de votre blog [_1] a été automatiquement banni après avoir publié une quantité de commentaires supérieure à la limite établie au cours des dernières [_2] secondes.',
	'This was done to prevent a malicious script from overwhelming your weblog with comments. The banned IP address is' => 'Ceci a été fait pour prévenir un assaut de commentaires sur votre blog par un script malicieux.',

## plugins/Comments/default_templates/new-comment.mtml
	q{An unapproved comment has been posted on your site '[_1]', on entry #[_2] ([_3]). You need to approve this comment before it will appear on your site.} => q{Un commentaire en attente de modération a été posté sur votre site '[_1]', sur la note #[_2] ([_3]). Vous devez l'approuver pour qu'il apparaisse sur votre site.},
	q{An unapproved comment has been posted on your site '[_1]', on page #[_2] ([_3]). You need to approve this comment before it will appear on your site.} => q{Un commentaire en attente de modération a été posté sur votre site '[_1]', sur la page #[_2] ([_3]). Vous devez l'approuver pour qu'il apparaisse sur votre site.},
	q{A new comment has been posted on your site '[_1]', on entry #[_2] ([_3]).} => q{Un commentaire en attente de modération a été posté sur votre site '[_1]', sur la note #[_2] ([_3]).},
	q{A new comment has been posted on your site '[_1]', on page #[_2] ([_3]).} => q{Un commentaire en attente de modération a été posté sur votre site '[_1]', sur la page #[_2] ([_3]).},
	'Commenter name: [_1]' => 'Nom du commentateur : [_1]',
	'Commenter email address: [_1]' => 'Adresse e-mail du commentateur :  [_1]',
	'Commenter URL: [_1]' => 'URL du commentateur : [_1]',
	'Commenter IP address: [_1]' => 'Adresse IP du commentateur : [_1]',
	'Approve comment:' => 'Approuver le commentaire :',
	'View comment:' => 'Voir le commentaire :',
	'Edit comment:' => 'Éditer le commentaire :',
	'Report the comment as spam:' => 'Signaler le commentaire comme spam :',

## plugins/Comments/default_templates/recent_comments.mtml

## plugins/Comments/lib/Comments/App/ActivityFeed.pm
	'[_1] Comments' => '[_1] commentaires',
	'All Comments' => 'Tous les commentaires',

## plugins/Comments/lib/Comments/App/CMS.pm
	'Are you sure you want to remove all comments reported as spam?' => 'Voulez-vous vraiment supprimer tous les commentaires reportés comme spam ?',
	'Delete all Spam comments' => 'Supprimer tous les commentaires marqués comme indésirables',

## plugins/Comments/lib/Comments/Blog.pm
	'Cloning comments for blog...' => 'Clonage des commentaires de blog...',

## plugins/Comments/lib/Comments/CMS/Search.pm

## plugins/Comments/lib/Comments/Import.pm
	'Creating new comment (from \'[_1]\')...' => 'Création d\'un nouveau commentaire (de \'[_1]\')...',
	'Saving comment failed: [_1]' => 'Échec de la sauvegarde du commentaire : [_1]',

## plugins/Comments/lib/Comments.pm
	'Search for other comments from anonymous commenters' => 'Chercher d\'autres commentaires anynomes',
	'__ANONYMOUS_COMMENTER' => 'Anonyme',
	'Search for other comments from this deleted commenter' => 'Chercher d\'autres commentaires de ce commentateur supprimé',
	'(Deleted)' => '(supprimé)',
	'Edit this [_1] commenter.' => 'Supprimer ce commentateur [_1]',
	'Comments on [_1]: [_2]' => 'Commentaires sur [_1] : [_2]',
	'Not spam' => 'Non spam',
	'Reported as spam' => 'Notifié comme spam',
	'All comments by [_1] \'[_2]\'' => 'Tous les commentaires par [_1] \'[_2]\'',
	'__COMMENTER_APPROVED' => 'Approuvé',
	'Moderator' => 'Modérateur',
	'Can comment and manage feedback.' => 'Peut commenter et gérer les commentaires.',
	'Can comment.' => 'Peut commenter.',
	'__COMMENT_COUNT' => 'Nombre de commentaires',
	'Comments on My Entries/Pages' => 'Commentaires sur mes notes/pages',
	'Entry/Page Status' => 'Status Note/Page',
	'Date Commented' => 'Date du commentaire',
	'Comments in This Website' => 'Commentaires dans ce site web',
	'Comments in This Site' => 'Commentaires dans ce site web',
	'Non-spam comments' => 'Commentaires marqués comme n\'étant pas du spam',
	'Non-spam comments on this website' => 'Commentaires n\'étant pas du spam sur ce site web',
	'Pending comments' => 'Commentaires en attente',
	'Published comments' => 'Commentaires publiés',
	'Comments on my entries/pages' => 'Commentaires sur mes notes/pages',
	'Comments in the last 7 days' => 'Commentaires des 7 derniers jours',
	'Spam comments' => 'Commentaires marqués comme étant du spam',
	'Enabled Commenters' => 'Auteurs de commentaire actifs',
	'Disabled Commenters' => 'Auteurs de commentaire désactivés',
	'Pending Commenters' => 'Auteurs de commentaire en attente',
	'Externally Authenticated Commenters' => 'Utilisateurs avec authentification externe',
	'Entries with Comments Within the Last 7 Days' => 'Notes avec commentaires ces 7 derniers jours',
	'Pages with comments in the last 7 days' => 'Pages commentées ces 7 derniers jours',

## plugins/Comments/lib/Comments/Upgrade.pm
	'Creating initial comment roles...' => 'Création des rôles initiaux de commentateurs...',

## plugins/Comments/lib/MT/App/Comments.pm
	'Error assigning commenting rights to user \'[_1] (ID: [_2])\' for weblog \'[_3] (ID: [_4])\'. No suitable commenting role was found.' => 'Erreur en assignant les droits de commenter à l\'utilisateur \'[_1] (ID:[_2])\' pour le blog \'[_3] (ID:[_4])\'. Aucun rôle de commentateur adéquat n\'a été trouvé.',
	'Invalid commenter login attempt from [_1] to blog [_2](ID: [_3]) which does not allow Movable Type native authentication.' => 'Tentative d\'identification échoué pour le commentateur [_1] sur le blog [_2] (ID:[_3]) qui n\'autorise pas l\'authentification native de Movable Type.',
	'Successfully authenticated, but signing up is not allowed.  Please contact your Movable Type system administrator.' => 'Authentification réussie, mais l\'enregistrement est interdit. Veuillez contacter votre administrateur Movable Type.',
	'You need to sign up first.' => 'Vous devez vous enregistrer d\'abord.',
	'Login failed: permission denied for user \'[_1]\'' => 'Identification échoué : accès interdit pour l\'utilisateur \'[_1]\'',
	'Login failed: password was wrong for user \'[_1]\'' => 'Identification échoué : mot de passe incorrect pour l\'utilisateur \'[_1]\'',
	'Signing up is not allowed.' => 'Enregistrement non autorisée.',
	'Movable Type Account Confirmation' => 'Confirmation de compte Movable Type',
	'Your confirmation has expired. Please register again.' => 'Votre confirmation a expirée. Veuillez vous enregistrer à nouveau.',
	'<a href="[_1]">Return to the original page.</a>' => '<a href="[_1]">Retourner à la page initiale</a>',
	'Commenter \'[_1]\' (ID:[_2]) has been successfully registered.' => 'Le commentateur \'[_1]\' (ID:[_2]) a été enregistré avec succès.',
	'Thanks for the confirmation.  Please sign in to comment.' => 'Merci pour la confirmation. Merci de vous identifier pour commenter.',
	'[_1] registered to the blog \'[_2]\'' => '[_1] est enregistré sur le blog \'[_2]\'',
	'No id' => 'Pas d\'id',
	'No such comment' => 'Pas de tel commentaire',
	'IP [_1] banned because comment rate exceeded 8 comments in [_2] seconds.' => 'l\'IP [_1] a été bannie car elle a envoyé plus de 8 commentaires en  [_2] seconds.',
	'IP Banned Due to Excessive Comments' => 'IP bannie pour cause de commentaires excessifs',
	'No such entry \'[_1]\'.' => 'Aucune note \'[_1]\'.',
	'_THROTTLED_COMMENT' => 'Afin de réduire les abus, nous avons activé une fonction obligeant les auteurs de commentaire à attendre quelques instants avant de publier un autre commentaire. Veuillez attendre quelques instants avant de publier un autre commentaire. Merci.',
	'Comments are not allowed on this entry.' => 'Les commentaires ne sont pas autorisés sur cette note.',
	'Comment text is required.' => 'Le texte de commentaire est requis.',
	'Registration is required.' => 'L\'inscription est requise.',
	'Name and E-mail address are required.' => 'Le nom et l\'adresse e-mail sont requis.',
	'Invalid URL \'[_1]\'' => 'URL invalide \'[_1]\'',
	'Comment save failed with [_1]' => 'La sauvegarde du commentaire a échoué [_1]',
	'Comment on "[_1]" by [_2].' => 'Commentaire sur « [_1] » par [_2].',
	'Failed comment attempt by pending registrant \'[_1]\'' => 'Tentative de commentaire échoué par utilisateur  \'[_1]\' en cours d\'inscription',
	'The sign-in attempt was not successful; Please try again.' => 'La tentative d\'enregistrement a échoué. Veuillez réessayer.',
	'You are trying to redirect to external resources. If you trust the site, please click the link: [_1]' => 'Vous tentez de rediriger vers une resource extérieure. Si vous faites confiance à ce site, cliquez sur ce lien : [_1]',
	'No entry was specified; perhaps there is a template problem?' => 'Aucune note n\'a été spécifiée, peut-être y a-t-il un problème de gabarit ?',
	'Somehow, the entry you tried to comment on does not exist' => 'Il semble que la note que vous souhaitez commenter n\'existe pas',
	'Invalid entry ID provided' => 'ID de note fourni invalide',
	'All required fields must be populated.' => 'Tous les champs requis doivent être renseignés.',
	'Commenter profile has successfully been updated.' => 'Le profil du commentateur a été modifié avec succès.',
	'Commenter profile could not be updated: [_1]' => 'Le profil du commentateur n\'a pu être modifié : [_1]',

## plugins/Comments/lib/MT/CMS/Comment.pm
	'No such commenter [_1].' => 'Aucun commentateur [_1].',
	'User \'[_1]\' trusted commenter \'[_2]\'.' => 'L\'utilisateur \'[_1]\' a considéré comme fiable le commentateur \'[_2]\'.',
	'User \'[_1]\' banned commenter \'[_2]\'.' => 'L\'utilisateur \'[_1]\' a banni le commentateur \'[_2]\'.',
	'User \'[_1]\' unbanned commenter \'[_2]\'.' => 'L\'utilisateur \'[_1]\' a retiré le statut Banni à le commentateur \'[_2]\'.',
	'User \'[_1]\' untrusted commenter \'[_2]\'.' => 'L\'utilisateur \'[_1]\' a retiré le statut Fiable à le commentateur \'[_2]\'.',
	'The parent comment id was not specified.' => 'L\'ID du commentaire parent est manquante.',
	'The parent comment was not found.' => 'Le commentaire parent est introuvable.',
	'You cannot reply to unapproved comment.' => 'Vous ne pouvez répondre à un commentaire non approuvé.',
	'You cannot create a comment for an unpublished entry.' => 'Vous ne pouvez pas créer un commentaire sur une note non publiée.',
	'You cannot reply to unpublished comment.' => 'Vous ne pouvez pas répondre à un commentaire non publié.',
	'Comment (ID:[_1]) by \'[_2]\' deleted by \'[_3]\' from entry \'[_4]\'' => 'Commentaire (ID:[_1]) de \'[_2]\' supprimé par \'[_3]\' de la note \'[_4]\'',
	'You do not have permission to approve this trackback.' => 'Vous n\'avez pas la permission d\'approuver ce TrackBack.',
	'The entry corresponding to this comment is missing.' => 'La note correspondante à ce commentaire est manquante.',
	'You do not have permission to approve this comment.' => 'Vous n\'avez pas la permission d\'approuver ce commentaire.',
	'Orphaned comment' => 'Commentaire orphelin',

## plugins/Comments/lib/MT/DataAPI/Endpoint/Comment.pm

## plugins/Comments/lib/MT/Template/Tags/Commenter.pm
	'This \'[_1]\' tag has been deprecated. Please use \'[_2]\' instead.' => 'La balise \'[_1]\' est obsolète. Veuillez utiliser \'[_2]\' à la place.',

## plugins/Comments/lib/MT/Template/Tags/Comment.pm
	'The MTCommentFields tag is no longer available.  Please include the [_1] template module instead.' => 'La balise MTCommentFields n\'est plus disponible. Veuillez inclure le module de gabarit [_1] à la place.',

## plugins/Comments/php/function.mtcommentauthorlink.php

## plugins/Comments/php/function.mtcommentauthor.php

## plugins/Comments/php/function.mtcommenternamethunk.php
	'The \'[_1]\' tag has been deprecated. Please use the \'[_2]\' tag in its place.' => 'La balise \'[_1]\' est obsolète. Veuillez utiliser la balise \'[_2]\' à la place.',

## plugins/Comments/php/function.mtcommentreplytolink.php

## plugins/Comments/t/211-api-resource-objects.d/asset/from_object.yaml
	'Image photo' => 'Photo image',

## plugins/Comments/t/211-api-resource-objects.d/asset/to_object.yaml

## plugins/Comments/t/211-api-resource-objects.d/category/from_object.yaml

## plugins/Comments/t/211-api-resource-objects.d/category/to_object.yaml
	'Original Test' => 'Test original',

## plugins/Comments/t/211-api-resource-objects.d/entry/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/authenticated/asset/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/authenticated/entry/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/non-authenticated/asset/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/non-authenticated/entry/from_object.yaml

);

1;
