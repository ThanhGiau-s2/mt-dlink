<?php
function smarty_function_mtgmapcflatitude($args, &$ctx) {
    $params = $ctx->stash('fjgmcf_params');
    if (!count($params)) {
        return '';
    }
    return $params['lat'];
}
?>
