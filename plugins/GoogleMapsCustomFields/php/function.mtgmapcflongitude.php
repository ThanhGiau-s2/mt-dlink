<?php
function smarty_function_mtgmapcflongitude($args, &$ctx) {
    $params = $ctx->stash('fjgmcf_params');
    if (!count($params)) {
        return '';
    }
    return $params['lng'];
}
?>
