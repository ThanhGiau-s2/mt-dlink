<?php
function smarty_function_mtgmapcfurl($args, &$ctx) {
    $params = $ctx->stash('fjgmcf_params');
    if (!count($params)) {
        return '';
    }
    $zoom = $args['zoom'] ? $args['zoom'] : $params['zoom'];
    $lat = $params['lat'];
    $lng = $params['lng'];
    
    return "http://maps.google.co.jp/maps?f=q&amp;source=s_q&amp;hl=ja&amp;q=${lat},${lng}&amp;z=${zoom}&amp;&ie=UTF8";
}
?>
