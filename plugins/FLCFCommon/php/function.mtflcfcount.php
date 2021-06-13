<?php
function smarty_function_mtflcfcount($args, &$ctx) {
    if ($ctx->stash('flcf_field_count')) {
        return $ctx->stash('flcf_field_count');
    }
    else {
        return '0';
    }
}
?>
