package Trackback::L10N::es;

use strict;
use warnings;
use utf8;
use base 'Trackback::L10N';

our %Lexicon = (

## plugins/Trackback/config.yaml
	'Provides Trackback.' => 'Provee TrackBack', # Translate - New
	'Mark as Spam' => 'Marcar como basura',
	'Remove Spam status' => 'Desmarcar como basura',
	'Unpublish TrackBack(s)' => 'Despublicar TrackBack/s',
	'weblogs.com' => 'weblogs.com',
	'New Ping' => 'Nuevo ping',

## plugins/Trackback/default_templates/new-ping.mtml
	q{An unapproved TrackBack has been posted on your site '[_1]', on entry #[_2] ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Se ha publicado un TrackBack no aprobado en el sitio '[_1]', en la entrada #[_2] ([_3]). Para que aparezca en el sitio primero debe aprobarlo.},
	q{An unapproved TrackBack has been posted on your site '[_1]', on page #[_2] ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Se ha publicado un TrackBack no aprobado en el sitio '[_1]', en la página #[_2] ([_3]). Para que aparezca en el sitio primero debe aprobarlo.},
	q{An unapproved TrackBack has been posted on your site '[_1]', on category #[_2], ([_3]). You need to approve this TrackBack before it will appear on your site.} => q{Se ha publicado un TrackBack no aprobado en el sitio '[_1]', en la categoría #[_2] ([_3]). Para que aparezca en el sitio primero debe aprobarlo.},
	q{A new TrackBack has been posted on your site '[_1]', on entry #[_2] ([_3]).} => q{Se ha publicado un nuevo TrackBack en el sitio '[_1]', en la entrada #[_2] ([_3]).},
	q{A new TrackBack has been posted on your site '[_1]', on page #[_2] ([_3]).} => q{Se ha publicado un nuevo TrackBack en el sitio '[_1]', en la página #[_2] ([_3]).},
	q{A new TrackBack has been posted on your site '[_1]', on category #[_2] ([_3]).} => q{Se ha publicado un nuevo TrackBack en el sitio '[_1]', en la categoría #[_2] ([_3]).},
	'Approve TrackBack' => 'Aprobar TrackBack',
	'View TrackBack' => 'Ver TrackBack',
	'Report TrackBack as spam' => 'Marcar TrackBack como spam',
	'Edit TrackBack' => 'Editar TrackBack',

## plugins/Trackback/default_templates/trackbacks.mtml

## plugins/Trackback/lib/MT/App/Trackback.pm
	'You must define a Ping template in order to display pings.' => 'Debe definir una plantilla de ping para poderlos mostrar.',
	'Trackback pings must use HTTP POST' => 'Los pings de Trackback deben usar HTTP POST',
	'TrackBack ID (tb_id) is required.' => 'TrackBack ID (tb_id) es necesario.',
	'Invalid TrackBack ID \'[_1]\'' => 'ID de TrackBack no válido \'[_1]\'',
	'You are not allowed to send TrackBack pings.' => 'No se le permite enviar pings de TrackBack.',
	'You are sending TrackBack pings too quickly. Please try again later.' => 'Está enviando pings de TrackBack demasiado rápido. Por favo
r, inténtelo más tarde.',
	'You need to provide a Source URL (url).' => 'Debe indicar una URL fuente (url).',
	'Invalid URL \'[_1]\'' => 'URL \'[_1]\' no válida', # Translate - New
	'This TrackBack item is disabled.' => 'Este elemento de TrackBack fue deshabilitado.',
	'This TrackBack item is protected by a passphrase.' => 'Este elemento de TrackBack está protegido por una contraseña.',
	'TrackBack on "[_1]" from "[_2]".' => 'TrackBack en "[_1]" de "[_2]".',
	'TrackBack on category \'[_1]\' (ID:[_2]).' => 'TrackBack en la categoría \'[_1]\' (ID:[_2]).',
	'Cannot create RSS feed \'[_1]\': ' => 'No se pudo crear la fuente RSS \'[_1]\': ',
	'New TrackBack ping to \'[_1]\'' => 'Nuevo ping de TrackBack en \'[_1]\'',
	'New TrackBack ping to category \'[_1]\'' => 'Nuevo ping de TrackBack en la categoría \'[_1]\'',

## plugins/Trackback/lib/MT/CMS/TrackBack.pm
	'(Unlabeled category)' => '(Categoría sin título)',
	'Ping (ID:[_1]) from \'[_2]\' deleted by \'[_3]\' from category \'[_4]\'' => 'Ping (ID:[_1]) desde \'[_2]\' borrado por \'[_3]\' de la
 categoría \'[_4]\'',
	'(Untitled entry)' => '(Entrada sin título)',
	'Ping (ID:[_1]) from \'[_2]\' deleted by \'[_3]\' from entry \'[_4]\'' => 'Ping (ID:[_1]) desde \'[_2]\' borrado por \'[_3]\' de la en
trada \'[_4]\'',
	'No Excerpt' => 'Sin resumen',
	'Orphaned TrackBack' => 'TrackBack huérfano',
	'category' => 'categoría',

## plugins/Trackback/lib/MT/Template/Tags/Ping.pm
	'<\$MTCategoryTrackbackLink\$> must be used in the context of a category, or with the \'category\' attribute to the tag.' => '<\$MTCategoryTrackbackLink\$> debe utilizarse en el contexto de una categoría, o con el atributo \'category\' en la etiqueta.',

## plugins/Trackback/lib/MT/XMLRPC.pm
	'No WeblogsPingURL defined in the configuration file' => 'WeblogsPingURL no está definido en el fichero de configuración',
	'No MTPingURL defined in the configuration file' => 'MTPingURL no está definido en el fichero de configuración',
	'HTTP error: [_1]' => 'Error HTTP: [_1]',
	'Ping error: [_1]' => 'Error de ping: [_1]',

## plugins/Trackback/lib/Trackback/App/ActivityFeed.pm
	'[_1] TrackBacks' => '[_1] TrackBacks',
	'All TrackBacks' => 'Todos los TrackBacks',

## plugins/Trackback/lib/Trackback/App/CMS.pm
	'Are you sure you want to remove all trackbacks reported as spam?' => '¿Está seguro de que desea borrar todos los trackbacks marcados como spam?',
	'Delete all Spam trackbacks' => 'Borrar todos los TrackBacks basura',

## plugins/Trackback/lib/Trackback/Blog.pm
	'Cloning TrackBacks for blog...' => 'Clonando TrackBacks para el blog...',
	'Cloning TrackBack pings for blog...' => 'Clonando pings de TrackBack para el blog...',

## plugins/Trackback/lib/Trackback/CMS/Comment.pm
	'You do not have permission to approve this trackback.' => 'No tiene permisos para aprobar este TrackBack.', # Translate - New
	'The entry corresponding to this comment is missing.' => 'No se encuentra la entrada correspondiente a este comentario.', # Translate - New
	'You do not have permission to approve this comment.' => 'No tiene permisos para aprobar este comentario.', # Translate - New

## plugins/Trackback/lib/Trackback/CMS/Entry.pm
	'Ping \'[_1]\' failed: [_2]' => 'Falló ping \'[_1]\' : [_2]',

## plugins/Trackback/lib/Trackback/CMS/Search.pm
	'Source URL' => 'URL origen',

## plugins/Trackback/lib/Trackback/Import.pm
	'Creating new ping (\'[_1]\')...' => 'Creando nuevo ping (\'[_1]\')...',
	'Saving ping failed: [_1]' => 'Fallo guardando ping: [_1]',

## plugins/Trackback/lib/Trackback.pm
	'<a href="[_1]">Ping from: [_2] - [_3]</a>' => '<a href="[_1]">Ping desde: [_2] - [_3]</a>',
	'Not spam' => 'No es spam',
	'Reported as spam' => 'Marcado como spam',
	'Trackbacks on [_1]: [_2]' => 'Trackbacks en [_1]: [_2]',
	'__PING_COUNT' => 'Trackbacks',
	'Trackback Text' => 'Texto del TrackBack',
	'Trackbacks on My Entries/Pages' => 'TrackBacks en mis entradas/páginas',
	'Non-spam trackbacks' => 'Trackbacks que no son spam',
	'Non-spam trackbacks on this website' => 'TrackBacks no spam en este sitio web',
	'Pending trackbacks' => 'TrackBacks pendientes',
	'Published trackbacks' => 'Trackback publicados',
	'Trackbacks on my entries/pages' => 'TrackBacks en mis entradas/páginas',
	'Trackbacks in the last 7 days' => 'TrackBacks en los últimos 7 días',
	'Spam trackbacks' => 'TrackBacks spam',

## plugins/Trackback/t/211-api-resource-objects.d/asset/from_object.yaml
	'Image photo' => 'Fotografía', # Translate - New

## plugins/Trackback/t/211-api-resource-objects.d/asset/to_object.yaml

## plugins/Trackback/t/211-api-resource-objects.d/category/from_object.yaml

## plugins/Trackback/t/211-api-resource-objects.d/category/to_object.yaml
	'Original Test' => 'Prueba original', # Translate - New

## plugins/Trackback/t/211-api-resource-objects.d/entry/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/authenticated/asset/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/authenticated/entry/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/non-authenticated/asset/from_object.yaml

## plugins/Trackback/t/213-api-resource-objects-disabled-fields.d/non-authenticated/entry/from_object.yaml
);

1;
