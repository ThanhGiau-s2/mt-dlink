# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package MT::Commercial::L10N::es;

use strict;
use base 'MT::Commercial::L10N::en_us';
use vars qw( %Lexicon );

## The following is the translation table.

%Lexicon = (
## addons/Commercial.pack/config.yaml
	'https://www.sixapart.com/movabletype/' => 'https://www.sixapart.com/movabletype/',
	'Professionally designed, well-structured and easily adaptable web site. You can customize default pages, footer and top navigation easily.' => 'Sitio web con diseño profesional, bien estructurado y fácilmente adaptable. Puede personalizar fácilmente las páginas predefinidas, el pie y la navegación.', # Translate - New
	q{_PWT_ABOUT_BODY} => q{
<p><strong>Vuelva a colocar el texto de ejemplo con su propia información.</strong></p>
<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. In nec tellus sed turpis varius sagittis. Nullam pulvinar. Fusce dapibus neque pellentesque nulla. Maecenas condimentum quam. Vestibulum pretium fringilla quam. Nam elementum. Suspendisse odio magna, aliquam vitae, vulputate et, dignissim at, pede. Integer pellentesque orci at nibh. Morbi ante.</p>

<p>Maecenas convallis mattis justo. Ut mauris sapien, consequat a, bibendum vitae, sagittis ac, nisi. Nulla et sapien. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Ut condimentum turpis ut elit. Quisque ultricies sollicitudin justo. Duis vitae magna nec risus pulvinar ultricies.</p>
<!-- remove this link after editing -->
<p class="admin-edit-link">
<a href="#" onclick="location.href=adminurl + '?__mode=view&_type=page&id=' + page_id + '&blog_id=' + blog_id; return false">Editar este contenido</a>
</p>
	 },
	q{_PWT_CONTACT_BODY} => q{
<p><strong>Vuelva a colocar el texto de ejemplo con su propia información.</strong></p>

<p>Nos encantaría saber de usted. Enviar correo electrónico a email (at) domainname.com</p>

<!-- remove this link after editing -->
<p class="admin-edit-link">
<a href="#" onclick="location.href=adminurl + '?__mode=view&_type=page&id=' + page_id + '&blog_id=' + blog_id; return false">Editar este contenido</a>
</p>
	 },
	'Welcome to our new website!' => '¡Bienvenido a nuestro nuevo sitio!',
	q{_PWT_HOME_BODY} => q{
<p><strong>Vuelva a colocar el texto de ejemplo con su propia información.</strong></p>
<p>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. In nec tellus sed turpis varius sagittis. Nullam pulvinar. Fusce dapibus neque pellentesque nulla. Maecenas condimentum quam. Aliquam erat volutpat. Ut placerat porta nibh. Donec vitae nulla. Pellentesque nisi leo, pretium a, gravida quis, sollicitudin non, eros. Vestibulum pretium fringilla quam. Nam elementum. Suspendisse odio magna, aliquam vitae, vulputate et, dignissim at, pede. Integer pellentesque orci at nibh. Morbi ante.</p>

<p>Maecenas convallis mattis justo. Ut mauris sapien, consequat a, bibendum vitae, sagittis ac, nisi. Nulla et sapien. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Ut condimentum turpis ut elit. Quisque ultricies sollicitudin justo. Duis vitae magna nec risus pulvinar ultricies. Aliquam sagittis volutpat metus.</p>

<p>Sed enim. Integer hendrerit, arcu ac pretium nonummy, velit turpis faucibus risus, pulvinar egestas enim elit sed ante. Curabitur orci diam, placerat a, faucibus id, condimentum vitae, magna. Etiam enim massa, convallis quis, rutrum vitae, porta quis, turpis.</p>
<!-- remove this link after editing -->
<p class="admin-edit-link">
<a href="#" onclick="location.href=adminurl + '?__mode=view&_type=page&id=' + page_id + '&blog_id=' + blog_id; return false">Editar este contenido</a>
</p>
	 },
	'Create a blog as a part of structured website. This works best with Professional Website theme.' => 'Crear un blog como parte de la estructura de un sitio web. Funciona mejor con el tema Sitio Web Profesional.',
	'Unknown Type' => 'Tipo de desconocido',
	'Unknown Object' => 'Objeto de desconocido',
	'Not Required' => 'No obligatorio',
	'Are you sure you want to delete the selected CustomFields?' => '¿Está seguro de que desea borrar los campos personalizados seleccionados?',
	'Photo' => 'Foto',
	'Embed' => 'Embeber',
	'Custom Fields' => 'Campos personalizados',
	'Template tag' => 'Etiqueta de plantilla',
	'Updating Universal Template Set to Professional Website set...' => 'Actualizar el conjuntto de plantillas Universal al conjunto Sitio Web Profesional...',
	'Migrating CustomFields type...' => 'Migrando tipo de Campos Personalizados...',
	'Converting CustomField type...' => 'Convirtiendo el tipo de Campos Personalizados...',
	'Professional Styles' => 'Estilos Profesionales',
	'A collection of styles compatible with Professional themes.' => 'Colección de estilos compatible con los temas Profesionales.',
	'Professional Website' => 'Web Profesional',
	'Entry Listing' => 'Listado de entradas',
	'Header' => 'Cabecera',
	'Footer' => 'Pie',
	'Entry Detail' => 'Detalle de la entrada',
	'Entry Metadata' => 'Metadatos de la entrada',
	'Page Detail' => 'Detalle de la página',
	'Footer Links' => 'Enlaces del pie',
	'Powered By (Footer)' => 'Powered By (Pie)',
	'Recent Entries Expanded' => 'Entradas recientes expandidas',
	'Main Sidebar' => 'Barra lateral principal',
	'Blog Activity' => 'Actividad del blog',
	'Professional Blog' => 'Blog Profesional',
	'Blog Archives' => 'Archivos del blog',

## addons/Commercial.pack/lib/CustomFields/App/CMS.pm
	'Date & Time' => 'Fecha & Hora',
	'Date Only' => 'Fecha solo',
	'Time Only' => 'Hora solo',
	'Please enter all allowable options for this field as a comma delimited list' => 'Por favor, introduzca todas las opciones permitidas a este campo en forma de lista de elementos separados por comas',
	'Exclude Custom Fields' => 'Excluir campos personalizados',
	'[_1] Fields' => 'Campos de [_1]',
	'Create Custom Field' => 'Crear campo personalizado',
	'Invalid date \'[_1]\'; dates must be in the format YYYY-MM-DD HH:MM:SS.' => 'Fecha no válida \'[_1]\'; las fechas deben estar en el formato YYYY-MM-DD HH:MM:SS.',
	'Please enter valid URL for the URL field: [_1]' => 'Por favor, introduzca una URL válida en el campo de la URL: [_1]',
	'Please enter some value for required \'[_1]\' field.' => 'Por favor, introduzca un valor en el campo obligatorio \'[_1]\'.',
	'Please ensure all required fields have been filled in.' => 'Por favor, asegúrese de que todos los campos se han introducido.',
	'The template tag \'[_1]\' is an invalid tag name.' => 'La etiqueta de plantilla \'[_1]\' es un nombre de etiqueta inválido.',
	'The template tag \'[_1]\' is already in use.' => 'La etiqueta de plantilla \'[_1]\' ya está en uso.',
	'blog and the system' => 'blog y el sistema',
	'website and the system' => 'sitio y el sistema',
	'The basename \'[_1]\' is already in use. It must be unique within this [_2].' => 'El nombre base \'[_1]\' ya está en uso. Debe ser único en este [_2].',
	'You must select other type if object is the comment.' => 'Debe seleccionar otro tipo si el objeto es un comentario.',
	'type' => 'tipo',
	'Customize the forms and fields for entries, pages, folders, categories, and users, storing exactly the information you need.' => 'Personalice los formularios y campos de las entradas, páginas, carpetas, categorías y usuarios, guardando los datos exactos que necesite.',
	' ' => ' ',
	'Single-Line Text' => 'Texto - Una sola línea',
	'Multi-Line Text' => 'Texto multilínea',
	'Checkbox' => 'Casilla',
	'Drop Down Menu' => 'Menú desplegable',
	'Radio Buttons' => 'Botones radiales',
	'Embed Object' => 'Embeber objeto',
	'Post Type' => 'Tipo de entrada',

## addons/Commercial.pack/lib/CustomFields/BackupRestore.pm
	'Importing custom fields data stored in MT::PluginData...' => 'Importando los datos de los campos personalizados guardados en MT::PluginData', # Translate - New
	'Importing asset associations found in custom fields ( [_1] ) ...' => 'Importando las asociaciones de ficheros multimedia que se encuentran en los campos personalizados ( [_1]) ...', # Translate - New
	'Importing url of the assets associated in custom fields ( [_1] )...' => 'Importando las URLs de los ficheros multimedia asociados a los campos personalizados ( [_1] )...', # Translate - New

## addons/Commercial.pack/lib/CustomFields/DataAPI/Callback/Field.pm
	'The type "[_1]" is invalid.' => 'El tipo "[_1]" no es válido.',
	'The systemObject "[_1]" is invalid.' => 'El systemObject "[_1]" no es válido.',

## addons/Commercial.pack/lib/CustomFields/DataAPI/Callback.pm
	'Invalid date \'[_1]\'; dates should be real dates.' => 'Fecha no válida \'[_1]\'; debe ser una fecha real.',
	'Please enter valid option for the [_1] field: [_2]' => 'Por favor, introduzca una opción válida para el campo [_1]: [_2]',

## addons/Commercial.pack/lib/CustomFields/DataAPI/Endpoint/v2/Field.pm
	'Invalid includeShared parameter provided: [_1]' => 'Parámetro de includeShare no válido: [_1]',

## addons/Commercial.pack/lib/CustomFields/Field.pm
	'The template tag \'[_1]\' is already in use in the system level' => 'La etiqueta de plantilla \'[_1]\' ya está en uso a nivel del sistema.',
	'The template tag \'[_1]\' is already in use in [_2]' => 'La etiqueta de plantilla \'[_1]\' ya está en uso en [_2]',
	'The template tag \'[_1]\' is already in use in this blog' => 'La etiqueta de plantilla \'[_1]\' ya está uso en este blog',
	'The \'[_1]\' of the template tag \'[_2]\' that is already in use in [_3] is [_4].' => 'El \'[_1]\' de la etiqueta de plantilla \'[_2]\' que ya está en uso en [_3] es [_4].',
	'_CF_BASENAME' => 'Nombre base',
	'__CF_REQUIRED_VALUE__' => 'Valor',

## addons/Commercial.pack/lib/CustomFields/Template/ContextHandlers.pm
	'Are you sure you have used a \'[_1]\' tag in the correct context? We could not find the [_2]' => '¿Está seguro de que ha utilizado la etiqueta \'[_1]\' en el contexto adecuado? No se encontró el [_2]',
	'You used an \'[_1]\' tag outside of the context of the correct content; ' => 'Ha utilizado una etiqueta \'[_1]\' fuera del contexto del contenido correcto;',

## addons/Commercial.pack/lib/CustomFields/Theme.pm
	'[_1] custom fields' => '[_1] campos personalizados',
	'a field on this blog' => 'un campo en este blog',
	'a field on system wide' => 'un campo en todo el sistema',
	'Conflict of [_1] "[_2]" with [_3]' => 'Conflicto entre [_1] "[_2]" y [_3]',
	'Template Tag' => 'Etiqueta de plantilla',

## addons/Commercial.pack/lib/CustomFields/Upgrade.pm
	'Moving metadata storage for pages...' => 'Trasladando los metadatos de las páginas...',
	'Removing CustomFields display-order from plugin data...' => 'Borrando el orden de visualización de los campos personalizados en los datos de las extensiones...',
	'Removing unlinked CustomFields...' => 'Borrando campos personalizados no enlazados...',

## addons/Commercial.pack/lib/CustomFields/Util.pm
	'Cloning fields for blog:' => 'Clonando campos para el blog:',

## addons/Commercial.pack/templates/professional/blog/about_this_page.mtml

## addons/Commercial.pack/templates/professional/blog/archive_index.mtml

## addons/Commercial.pack/templates/professional/blog/archive_widgets_group.mtml

## addons/Commercial.pack/templates/professional/blog/author_archive_list.mtml

## addons/Commercial.pack/templates/professional/blog/calendar.mtml

## addons/Commercial.pack/templates/professional/blog/categories.mtml

## addons/Commercial.pack/templates/professional/blog/category_archive_list.mtml

## addons/Commercial.pack/templates/professional/blog/comment_detail.mtml

## addons/Commercial.pack/templates/professional/blog/comment_form.mtml

## addons/Commercial.pack/templates/professional/blog/comment_listing.mtml

## addons/Commercial.pack/templates/professional/blog/comment_preview.mtml

## addons/Commercial.pack/templates/professional/blog/comment_response.mtml

## addons/Commercial.pack/templates/professional/blog/comments.mtml

## addons/Commercial.pack/templates/professional/blog/creative_commons.mtml

## addons/Commercial.pack/templates/professional/blog/current_author_monthly_archive_list.mtml

## addons/Commercial.pack/templates/professional/blog/current_category_monthly_archive_list.mtml

## addons/Commercial.pack/templates/professional/blog/date_based_author_archives.mtml

## addons/Commercial.pack/templates/professional/blog/date_based_category_archives.mtml

## addons/Commercial.pack/templates/professional/blog/dynamic_error.mtml

## addons/Commercial.pack/templates/professional/blog/entry_detail.mtml

## addons/Commercial.pack/templates/professional/blog/entry_listing.mtml
	'Recently by <em>[_1]</em>' => 'Novedades por <em>[_1]</em>',

## addons/Commercial.pack/templates/professional/blog/entry_metadata.mtml

## addons/Commercial.pack/templates/professional/blog/entry.mtml

## addons/Commercial.pack/templates/professional/blog/entry_summary.mtml

## addons/Commercial.pack/templates/professional/blog/footer_links.mtml

## addons/Commercial.pack/templates/professional/blog/footer.mtml

## addons/Commercial.pack/templates/professional/blog/header.mtml

## addons/Commercial.pack/templates/professional/blog/javascript.mtml

## addons/Commercial.pack/templates/professional/blog/main_index.mtml

## addons/Commercial.pack/templates/professional/blog/main_index_widgets_group.mtml

## addons/Commercial.pack/templates/professional/blog/monthly_archive_dropdown.mtml

## addons/Commercial.pack/templates/professional/blog/monthly_archive_list.mtml

## addons/Commercial.pack/templates/professional/blog/navigation.mtml

## addons/Commercial.pack/templates/professional/blog/openid.mtml

## addons/Commercial.pack/templates/professional/blog/page.mtml

## addons/Commercial.pack/templates/professional/blog/pages_list.mtml

## addons/Commercial.pack/templates/professional/blog/powered_by_footer.mtml

## addons/Commercial.pack/templates/professional/blog/recent_assets.mtml

## addons/Commercial.pack/templates/professional/blog/recent_comments.mtml
	'<a href="[_1]">[_2] commented on [_3]</a>: [_4]' => '<a href="[_1]">[_2] comentó en [_3]</a>: [_4]',

## addons/Commercial.pack/templates/professional/blog/recent_entries.mtml

## addons/Commercial.pack/templates/professional/blog/search.mtml

## addons/Commercial.pack/templates/professional/blog/search_results.mtml

## addons/Commercial.pack/templates/professional/blog/sidebar.mtml

## addons/Commercial.pack/templates/professional/blog/signin.mtml

## addons/Commercial.pack/templates/professional/blog/syndication.mtml

## addons/Commercial.pack/templates/professional/blog/tag_cloud.mtml

## addons/Commercial.pack/templates/professional/blog/tags.mtml

## addons/Commercial.pack/templates/professional/blog/trackbacks.mtml

## addons/Commercial.pack/templates/professional/website/archive_index.mtml

## addons/Commercial.pack/templates/professional/website/blog_index.mtml

## addons/Commercial.pack/templates/professional/website/blogs.mtml
	'Entries ([_1]) Comments ([_2])' => 'Entradas ([_1]) Comentarios ([_2])',

## addons/Commercial.pack/templates/professional/website/categories.mtml

## addons/Commercial.pack/templates/professional/website/comment_detail.mtml

## addons/Commercial.pack/templates/professional/website/comment_form.mtml

## addons/Commercial.pack/templates/professional/website/comment_listing.mtml

## addons/Commercial.pack/templates/professional/website/comment_preview.mtml

## addons/Commercial.pack/templates/professional/website/comment_response.mtml

## addons/Commercial.pack/templates/professional/website/comments.mtml

## addons/Commercial.pack/templates/professional/website/dynamic_error.mtml

## addons/Commercial.pack/templates/professional/website/entry_detail.mtml

## addons/Commercial.pack/templates/professional/website/entry_listing.mtml

## addons/Commercial.pack/templates/professional/website/entry_metadata.mtml

## addons/Commercial.pack/templates/professional/website/entry.mtml

## addons/Commercial.pack/templates/professional/website/entry_summary.mtml

## addons/Commercial.pack/templates/professional/website/footer_links.mtml

## addons/Commercial.pack/templates/professional/website/footer.mtml

## addons/Commercial.pack/templates/professional/website/header.mtml

## addons/Commercial.pack/templates/professional/website/javascript.mtml

## addons/Commercial.pack/templates/professional/website/main_index.mtml

## addons/Commercial.pack/templates/professional/website/navigation.mtml

## addons/Commercial.pack/templates/professional/website/openid.mtml

## addons/Commercial.pack/templates/professional/website/page.mtml

## addons/Commercial.pack/templates/professional/website/pages_list.mtml

## addons/Commercial.pack/templates/professional/website/powered_by_footer.mtml

## addons/Commercial.pack/templates/professional/website/recent_entries_expanded.mtml
	'on [_1]' => 'en [_1]',
	'By [_1] | Comments ([_2])' => 'Por [_1] | Comentarios ([_2]) ',

## addons/Commercial.pack/templates/professional/website/search.mtml
	'Case sensitive' => 'Distinguir mayúsculas y minúsculas',

## addons/Commercial.pack/templates/professional/website/search_results.mtml

## addons/Commercial.pack/templates/professional/website/sidebar.mtml

## addons/Commercial.pack/templates/professional/website/signin.mtml

## addons/Commercial.pack/templates/professional/website/syndication.mtml

## addons/Commercial.pack/templates/professional/website/tag_cloud.mtml

## addons/Commercial.pack/templates/professional/website/tags.mtml

## addons/Commercial.pack/templates/professional/website/trackbacks.mtml

## addons/Commercial.pack/tmpl/asset-chooser.tmpl

## addons/Commercial.pack/tmpl/category_fields.tmpl
	'Show These Fields' => 'Mostrar estos campos',

## addons/Commercial.pack/tmpl/edit_field.tmpl
	'Edit Custom Field' => 'Editar campo personalizado',
	'The selected field(s) has been deleted from the database.' => 'Los campos seleccionados han sido borrados de la base de datos.',
	'You must enter information into the required fields highlighted below before the custom field can be created.' => 'Antes de que pueda crear el campo personalizado debe introducir la información en los campos obligatorios resaltados abajo.',
	'You must save this custom field before setting a default value.' => 'Debe guardar este campo personalizado antes de indicar un valor predefinido.',
	'Choose the system object where this custom field should appear.' => 'Seleccione el objeto del sistema donde aparecerá el campo personalizado.',
	'Required?' => '¿Obligatorio?',
	'Must the user enter data into this custom field before the object may be saved?' => '¿El usuario debe introducir datos en este campo personalizado antes de que el objeto se guarde?',
	'The basename must be unique within this [_1].' => 'El nombre base debe ser único en este [_1].',
	q{Warning: Changing this field's basename may require changes to existing templates.} => q{Atención: Si cambia el nombre base de este campo, quizás se necesiten cambios en las plantillas existentes.},
	'Example Template Code' => 'Código de ejemplo',
	'Show In These [_1]' => 'Mostrar en estos [_1]',
	'Save this field (s)' => 'Guardar este campo (s)',
	'field' => 'campo',
	'fields' => 'campos',
	'Delete this field (x)' => 'Borrar este campo (x)',

## addons/Commercial.pack/tmpl/export_field.tmpl
	'Object' => 'Objeto',

## addons/Commercial.pack/tmpl/listing/field_list_header.tmpl

## addons/Commercial.pack/tmpl/reorder_fields.tmpl
	'open' => 'abrir',
	'click-down and drag to move this field' => 'haga clic y arrastre el campo para moverlo',
	'click to %toggle% this box' => 'haga clic para %toggle% esta casilla',
	'use the arrow keys to move this box' => 'use las flechas para mover esta caja',
	', or press the enter key to %toggle% it' => ', o presione la tecla enter para %toggle%',
);

1;

