<?php
function smarty_function_mtgmapcfheight($args, &$ctx) {
    $params = $ctx->stash('fjgmcf_params');
    if (!count($params)) {
        return '';
    }
    return $params['height'];
}
?>
