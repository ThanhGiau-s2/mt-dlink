<?php
function smarty_function_mtflcftype($args, &$ctx) {
    $name = $args['name'];
    if (!isset($name)) {
        $name = $args['field'];
    }
    if (!isset($name)) {
        return '';
    }
    $flcf_fields = $ctx->stash('flcf_fields');
    $type = $flcf_fields[$name]['type'];
    if (!$type) {
        $type = 'text';
    }
    return $type;
}
?>
