<?php
function smarty_function_mtgmapcfaddress($args, &$ctx) {
    $params = $ctx->stash('fjgmcf_params');
    if (!count($params)) {
        return '';
    }
    return $params['address'];
}
?>
