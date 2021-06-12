package Comments::L10N::es;

use strict;
use warnings;
use utf8;
use base 'Comments::L10N';

our %Lexicon = (

## plugins/Comments/config.yaml
	'Provides Comments.' => 'Provee comentarios.', # Translate - New
	'Mark as Spam' => 'Marcar como basura',
	'Remove Spam status' => 'Desmarcar como basura',
	'Unpublish Comment(s)' => 'Despublicar comentario/s',
	'Trust Commenter(s)' => 'Confiar en comentarista/s',
	'Untrust Commenter(s)' => 'Desconfiar de comentarista/s',
	'Ban Commenter(s)' => 'Bloquear comentarista/s',
	'Unban Commenter(s)' => 'Desbloquear comentarista/s',
	'Registration' => 'Registro',
	'Manage Commenters' => 'Administrar comentaristas',
	'Comment throttle' => 'Aluvión de comentarios',
	'Commenter Confirm' => 'Confirmación de comentarista',
	'Commenter Notify' => 'Notificación de comentaristas',
	'New Comment' => 'Nuevo comentario',

## plugins/Comments/default_templates/comment_detail.mtml

## plugins/Comments/default_templates/commenter_confirm.mtml
	'Thank you for registering an account to comment on [_1].' => 'Gracias por registrar una cuenta para comentar en [_1].',
	'For your security and to prevent fraud, we ask you to confirm your account and email address before continuing. Once your account is confirmed, you will immediately be allowed to comment on [_1].' => 'Por su seguridad, y para prevenir fraudes, solicitamos que confirme su cuenta y dirección de correo antes de continuar. Tras confirmar su cuenta, podrá comentar de inmediato en [_1].',
	'To confirm your account, please click on the following URL, or cut and paste this URL into a web browser:' => 'Para confirmar su cuenta, por favor, haga clic en la siguiente URL, o copie y pegue la URL en un navegador:',
	q{If you did not make this request, or you don't want to register for an account to comment on [_1], then no further action is required.} => q{Si no realizó esta petición, o no quiere registrar una cuenta para comentar en [_1], no se necesitan más acciones.},
	'Sincerely,' => 'Cordialmente,',

## plugins/Comments/default_templates/commenter_notify.mtml
	q{This email is to notify you that a new user has successfully registered on the blog '[_1]'. Here is some information about this new user.} => q{Este correo es para notificarle que se ha registrado un nuevo usuario en el blog '[_1]'. Aquí se detallan algunos datos sobre él.},
	'New User Information:' => 'Informaciones sobre el nuevo usuario:',
	'Full Name: [_1]' => 'Nombre Completo: [_1]',
	'To view or edit this user, please click on or cut and paste the following URL into a web browser:' => 'Para ver o editar este usuario, por favor, haga clic en (o copie y pegue) la siguiente URL en un navegador:',

## plugins/Comments/default_templates/comment_listing.mtml

## plugins/Comments/default_templates/comment_preview.mtml

## plugins/Comments/default_templates/comment_response.mtml

## plugins/Comments/default_templates/comments.mtml

## plugins/Comments/default_templates/comment_throttle.mtml
	'If this was an error, you can unblock the IP address and allow the visitor to add it again by logging in to your Movable Type installation, choosing Blog Config - IP Banning, and deleting the IP address [_1] from the list of banned addresses.' => 'Si fue un error, puede desbloquear la dirección IP y permitir al visitante que lo añada de nuevo iniciando una sesión en Movable Type, seleccionando Bloqueo de IPs y eleminando la dirección IP [_1] de la lista de direcciones bloqueadas.',
	'A visitor to your blog [_1] has automatically been banned by adding more than the allowed number of comments in the last [_2] seconds.' => 'Se bloqueó automáticamente a una persona que visitó su weblog [_1] debido a que insertó más comentarios de los permitidos en menos de [_2] segundos.',
	q{This was done to prevent a malicious script from overwhelming your weblog with comments. The banned IP address is} => q{Se hizo para prevenir que un 'script' malicioso llene el blog con comentarios. La IP bloqueada es},

## plugins/Comments/default_templates/new-comment.mtml
	q{An unapproved comment has been posted on your site '[_1]', on entry #[_2] ([_3]). You need to approve this comment before it will appear on your site.} => q{Se ha publicado un comentario no aprobado en el sitio '[_1]', en la entrada #[_2] ([_3]). Para que aparezca en el sitio primero debe aprobarlo.},
	q{An unapproved comment has been posted on your site '[_1]', on page #[_2] ([_3]). You need to approve this comment before it will appear on your site.} => q{Se ha publicado un comentario no aprobado en el sitio '[_1]', en la página #[_2] ([_3]). Para que aparezca en el sitio primero debe aprobarlo.},
	q{A new comment has been posted on your site '[_1]', on entry #[_2] ([_3]).} => q{Se ha publicado un nuevo comentario en el sitio '[_1]', en la entrada #[_2] ([_3]).},
	q{A new comment has been posted on your site '[_1]', on page #[_2] ([_3]).} => q{Se ha publicado un nuevo comentario en el sitio '[_1]', en la página #[_2] ([_3]).},
	'Commenter name: [_1]' => 'Nombre del comentarista',
	'Commenter email address: [_1]' => 'Correo electrónico del comentarista: [_1]',
	'Commenter URL: [_1]' => 'URL del comentarista: [_1]',
	'Commenter IP address: [_1]' => 'Dirección IP del comentarista: [_1]',
	'Approve comment:' => 'Comentario aceptado:',
	'View comment:' => 'Ver comentario:',
	'Edit comment:' => 'Editar comentario:',
	'Report the comment as spam:' => 'Marcar el comentario como spam:',

## plugins/Comments/default_templates/recent_comments.mtml

## plugins/Comments/lib/Comments/App/ActivityFeed.pm
	'[_1] Comments' => '[_1] comentarios',
	'All Comments' => 'Todos los comentarios',

## plugins/Comments/lib/Comments/App/CMS.pm
	'Are you sure you want to remove all comments reported as spam?' => '¿Está de que desea borrar todos los comentarios marcados como spam?',
	'Delete all Spam comments' => 'Borrar todos los comentarios basura',

## plugins/Comments/lib/Comments/Blog.pm
	'Cloning comments for blog...' => 'Clonando comentarios para el blog...',

## plugins/Comments/lib/Comments/CMS/Search.pm

## plugins/Comments/lib/Comments/Import.pm
	'Creating new comment (from \'[_1]\')...' => 'Creando nuevo comentario (de \'[_1]\')...',
	'Saving comment failed: [_1]' => 'Fallo guardando comentario: [_1]',

## plugins/Comments/lib/Comments.pm
	'Search for other comments from anonymous commenters' => 'Buscar otros comentarios anónimos',
	'__ANONYMOUS_COMMENTER' => 'Anónimo',
	'Search for other comments from this deleted commenter' => 'Buscar otros comentarios de este comentarista eliminado',
	'(Deleted)' => '(Borrado)',
	'Edit this [_1] commenter.' => 'Editar este comentarista [_1].',
	'Comments on [_1]: [_2]' => 'Comentarios en [_1]: [_2]',
	'Not spam' => 'No es spam',
	'Reported as spam' => 'Marcado como spam',
	'All comments by [_1] \'[_2]\'' => 'Todos los comentarios de [_1] \'[_2]\'',
	'__COMMENTER_APPROVED' => 'Aprobado',
	'Moderator' => 'Moderador',
	'Can comment and manage feedback.' => 'Puede comentar y administrar las respuestas.',
	'Can comment.' => 'Puede comentar.',
	'__COMMENT_COUNT' => 'Comentarios',
	'Comments on My Entries/Pages' => 'Comentarios en mis entradas/páginas',
	'Entry/Page Status' => 'Estado de entrada/página', # Translate - New
	'Date Commented' => 'Fecha comentario',
	'Comments in This Website' => 'Comentarios en este sitio',
	'Comments in This Site' => 'Comentarios en este sitio',
	'Non-spam comments' => 'Comentarios que no son spam',
	'Non-spam comments on this website' => 'Comentarios no spam en este sitio web',
	'Pending comments' => 'Comentarios pendientes',
	'Published comments' => 'Comentarios publicados',
	'Comments on my entries/pages' => 'Comentarios en mis entradas/páginas',
	'Comments in the last 7 days' => 'Comentarios en los últimos 7 días',
	'Spam comments' => 'Comentarios spam',
	'Enabled Commenters' => 'Comentaristas habilitados',
	'Disabled Commenters' => 'Comentaristas deshabilitados',
	'Pending Commenters' => 'Comentaristas pendientes',
	'Externally Authenticated Commenters' => 'Comentaristas autentificados externamente',
	'Entries with Comments Within the Last 7 Days' => 'Entradas con comentarios en los últimos 7 días',
	'Pages with comments in the last 7 days' => 'Páginas con comentarios en los últimos 7 días',

## plugins/Comments/lib/Comments/Upgrade.pm
	'Creating initial comment roles...' => 'Creando roles iniciales de comentarios...', # Translate - New

## plugins/Comments/lib/MT/App/Comments.pm
	'Error assigning commenting rights to user \'[_1] (ID: [_2])\' for weblog \'[_3] (ID: [_4])\'. No suitable commenting role was found.' => 'Error asignando permisos para comentar al usuario \'[_1] (ID: [_2])\' para el weblog \'[_3] (ID: [_4])\'. No se encontró un rol adecuado.',
	'Invalid commenter login attempt from [_1] to blog [_2](ID: [_3]) which does not allow Movable Type native authentication.' => 'Intento de identificación de comentarista no válido desde [_1] en el blog [_2](ID: [_3]) que no permite la autentificación nativa de Movable Type.',
	'Successfully authenticated, but signing up is not allowed.  Please contact your Movable Type system administrator.' => 'Autentificado con éxito, pero el registro no está habilitado. Por favor, contacte con el administrador de sistemas de Movable Type.',
	'You need to sign up first.' => 'Primero identifíquese',
	'Login failed: permission denied for user \'[_1]\'' => 'Falló la identificación: permiso denegado al usuario \'[_1]\'',
	'Login failed: password was wrong for user \'[_1]\'' => 'Falló la identificación: contraseña errónea del usuario \'[_1]\'',
	'Signing up is not allowed.' => 'No está permitida la inscripción.',
	'Movable Type Account Confirmation' => 'Confirmación de cuenta - Movable Type',
	'Your confirmation has expired. Please register again.' => 'La confirmación caducó. Por favor, regístrese de nuevo.',
	'<a href="[_1]">Return to the original page.</a>' => '<a href="[_1]">Regresar a la página original.</a>',
	'Commenter \'[_1]\' (ID:[_2]) has been successfully registered.' => 'El comentarista \'[_1]\' (ID:[_2]) se inscribió con éxito.',
	'Thanks for the confirmation.  Please sign in to comment.' => 'Gracias por la confirmación. Por favor, identifíquese para comentar.',
	'[_1] registered to the blog \'[_2]\'' => '[_1] registrado en el blog \'[_2]\'',
	'No id' => 'Sin id',
	'No such comment' => 'No existe dicho comentario',
	'IP [_1] banned because comment rate exceeded 8 comments in [_2] seconds.' => 'IP [_1] bloqueada porque excedió el ritmo de comentarios, más de 8 en [_2] segundos.',
	'IP Banned Due to Excessive Comments' => 'IP bloqueada debido al exceso de comentarios',
	'No such entry \'[_1]\'.' => 'No existe la entrada \'[_1]\'.',
	'_THROTTLED_COMMENT' => 'Demasiados comentarios en un corto periodo de tiempo. Por favor, inténtelo dentro de un rato.',
	'Comments are not allowed on this entry.' => 'No se permiten comentarios en esta entrada.',
	'Comment text is required.' => 'El texto del comentario es obligatorio.',
	'Registration is required.' => 'El registro es obligatorio.',
	'Name and E-mail address are required.' => 'El nombre y la dirección de correo son obligatorios.',
	'Invalid URL \'[_1]\'' => 'URL no válida \'[_1]\'',
	'Comment save failed with [_1]' => 'Fallo guardando comentario con [_1]',
	'Comment on "[_1]" by [_2].' => 'Comentario en "[_1]" por [_2].',
	'Failed comment attempt by pending registrant \'[_1]\'' => 'Falló el intento de comentar por el comentarista pendiente \'[_1]\'',
	'You are trying to redirect to external resources. If you trust the site, please click the link: [_1]' => 'Está intentando redireccionar hacia un recurso externo. Si confía en el sitio, haga clic en el enlace: [_1]',
	'No entry was specified; perhaps there is a template problem?' => 'No se especificó ninguna entrada; ¿quizás hay un problema con la plantilla?',
	'Somehow, the entry you tried to comment on does not exist' => 'De alguna manera, la entrada en la que intentó comentar no existe',
	'Invalid entry ID provided' => 'ID de entrada provisto no válido',
	'All required fields must be populated.' => 'Debe rellenar todos los campos obligatorios.',
	'Commenter profile has successfully been updated.' => 'Se actualizó con éxito el perfil del comentarista.',
	'Commenter profile could not be updated: [_1]' => 'No se pudo actualizar el perfil del comentarista: [_1]',

## plugins/Comments/lib/MT/CMS/Comment.pm
	'No such commenter [_1].' => 'No existe el comentarista [_1].',
	'User \'[_1]\' trusted commenter \'[_2]\'.' => 'Usuario \'[_1]\' confió en el comentarista \'[_2]\'.',
	'User \'[_1]\' banned commenter \'[_2]\'.' => 'Usuario \'[_1]\' bloqueó al comentarista \'[_2]\'.',
	'User \'[_1]\' unbanned commenter \'[_2]\'.' => 'Usuario \'[_1]\' desbloqueó al comentarista \'[_2]\'.',
	'User \'[_1]\' untrusted commenter \'[_2]\'.' => 'Usuario \'[_1]\' desconfió del comentarista \'[_2]\'.',
	'The parent comment id was not specified.' => 'No se especificó el identificador del comentario raíz.',
	'The parent comment was not found.' => 'No se encontró el comentario padre.',
	'You cannot reply to unapproved comment.' => 'No puede responder a un comentario no aprobado.',
	'You cannot create a comment for an unpublished entry.' => 'No puede crear un comentario en una entrada sin publicar.',
	'You cannot reply to unpublished comment.' => 'No puede contestar a comentarios no publicados.',
	'Comment (ID:[_1]) by \'[_2]\' deleted by \'[_3]\' from entry \'[_4]\'' => 'Comentario (ID:[_1]) por \'[_2]\' borrado por \'[_3]\' de la entrada \'[_4]\'',
	'You do not have permission to approve this trackback.' => 'No tiene permiso para aprobar este trackback.',
	'The entry corresponding to this comment is missing.' => 'No se encuentra la entrada correspondiente a este comentario.',
	'You do not have permission to approve this comment.' => 'No tiene permisos para aprobar este comentario.',
	'Orphaned comment' => 'Comentario huérfano',

## plugins/Comments/lib/MT/DataAPI/Endpoint/Comment.pm

## plugins/Comments/lib/MT/Template/Tags/Commenter.pm
	'This \'[_1]\' tag has been deprecated. Please use \'[_2]\' instead.' => 'Esta etiqueta \'[_1]\' está obsoleta. Por favor, en su lugar use \'[_2]\'.',

## plugins/Comments/lib/MT/Template/Tags/Comment.pm
	'The MTCommentFields tag is no longer available.  Please include the [_1] template module instead.' => 'La etiqueta MTCommentFields ya no está disponible. Por favor, en su lugar, incluya el módulo de plantilla [_1].',

## plugins/Comments/php/function.mtcommentauthorlink.php

## plugins/Comments/php/function.mtcommentauthor.php

## plugins/Comments/php/function.mtcommenternamethunk.php
	'The \'[_1]\' tag has been deprecated. Please use the \'[_2]\' tag in its place.' => 'La etiqueta \'[_1]\' está obsoleta. Por favor, utilice en su lugar la etiqueta \'[_2]\'.',

## plugins/Comments/php/function.mtcommentreplytolink.php

## plugins/Comments/t/211-api-resource-objects.d/asset/from_object.yaml
	'Image photo' => 'Imagen foto', # Translate - New

## plugins/Comments/t/211-api-resource-objects.d/asset/to_object.yaml

## plugins/Comments/t/211-api-resource-objects.d/category/from_object.yaml

## plugins/Comments/t/211-api-resource-objects.d/category/to_object.yaml
	'Original Test' => 'Prueba original', # Translate - New

## plugins/Comments/t/211-api-resource-objects.d/entry/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/authenticated/asset/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/authenticated/entry/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/non-authenticated/asset/from_object.yaml

## plugins/Comments/t/213-api-resource-objects-disabled-fields.d/non-authenticated/entry/from_object.yaml
    );

1;
