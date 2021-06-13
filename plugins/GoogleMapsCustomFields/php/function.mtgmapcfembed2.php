<?php
require_once('plugin_config.php');

function smarty_function_mtgmapcfembed2($args, &$ctx) {
    $params = $ctx->stash('fjgmcf_params');
    $blog = $ctx->stash('blog');
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
    $db = $ctx->mt->db();
    $pc = new PluginConfig($db, 'GoogleMapsCustomFields');
    $api_key = $pc->get_config_value('fjgmcf_api_key', 'blog:' . $blog->blog_id);
    return <<<HERE
<iframe frameborder="0" marginwidth="0" marginheight="0" border="0" style="border:0;margin:0;width:${width}px;height:${height}px;" src="http://www.google.com/maps/embed/v1/place?key=${api_key}&amp;q=${address_enc}&amp;zoom=${zoom}" scrolling="no" allowtransparency="true"></iframe><br /><small><a href="//maps.google.co.jp/maps?f=q&amp;hl=ja&amp;q=${lat},${lng}(${address_enc})&amp;ll=${lat},${lng}&amp;ie=UTF8&amp;t=${map_type}&amp;z=${zoom}${show_info}" style="color:#0000FF;text-align:left">${view_msg}</a></small>
HERE;
}
?>
