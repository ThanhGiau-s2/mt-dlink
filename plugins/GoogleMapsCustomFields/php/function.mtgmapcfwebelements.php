<?php
function smarty_function_mtgmapcfwebelements($args, &$ctx) {
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

    return <<<HERE
<iframe frameborder="0" marginwidth="0" marginheight="0" border="0" style="border:0;margin:0;width:${width}px;height:${height}px;" src="http://www.google.com/uds/modules/elements/mapselement/iframe.html?maptype=roadmap&amp;latlng=${lat}%2C${lng}&amp;mlatlng=${lat}%2C${lng}&amp;maddress1=${address_enc}&amp;mtitle=${address_enc}&amp;zoom=${zoom}&amp;element=true" scrolling="no" allowtransparency="true"></iframe>
HERE;
}
?>
