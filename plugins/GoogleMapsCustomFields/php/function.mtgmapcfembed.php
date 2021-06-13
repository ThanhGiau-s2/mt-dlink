<?php
function smarty_function_mtgmapcfembed($args, &$ctx) {
    $params = $ctx->stash('fjgmcf_params');
    if (!count($params)) {
        return;
    }
    $address_enc = urlencode($params['address']);
    $width  = $args['width'] ? $args['width'] : $params['width'];
    $height = $args['height'] ? $args['height'] : $params['height'];
    $zoom   = $args['zoom'] ? $args['zoom'] : $params['zoom'];
    $lat = $params['lat'];
    $lng = $params['lng'];
    $show_info = $args['show_info'] ? '' : '&amp;iwloc=B';
    $map_type = $args['type'] ? $args['type'] : 'm';
    $view_msg = $ctx->mt->translate('View on larger map');
    return <<<HERE
<iframe width="${width}" height="${height}" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="//maps.google.co.jp/maps?f=q&amp;hl=ja&amp;q=${lat},${lng}(${address_enc})&amp;ll=${lat},${lng}&amp;ie=UTF8&amp;t=${map_type}&amp;z=${zoom}${show_info}&amp;output=embed"></iframe><br /><small><a href="//maps.google.co.jp/maps?f=q&amp;hl=ja&amp;q=${lat},${lng}(${address_enc})&amp;ll=${lat},${lng}&amp;ie=UTF8&amp;t=${map_type}&amp;z=${zoom}${show_info}" style="color:#0000FF;text-align:left">${view_msg}</a></small>
HERE;
}
?>
