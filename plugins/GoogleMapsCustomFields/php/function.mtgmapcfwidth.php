<?php
function smarty_function_mtgmapcfwidth($args, &$ctx) {
    $params = $ctx->stash('fjgmcf_params');
    if (!count($params)) {
        return '';
    }
    return $params['width'];
}
?>
