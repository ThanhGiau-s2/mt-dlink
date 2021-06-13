<?php
function smarty_function_mtgmapcfzoom($args, &$ctx) {
    $params = $ctx->stash('fjgmcf_params');
    if (!count($params)) {
        return '';
    }
    return $params['zoom'];
}
?>
