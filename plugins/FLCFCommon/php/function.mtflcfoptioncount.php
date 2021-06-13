<?php
function smarty_function_mtflcfoptioncount($args, &$ctx) {
    $name = $args['name'];
    if (!isset($name)) {
        $name = $args['field'];
    }
    if (!isset($name)) {
        return '';
    }
    $flcf_def = $ctx->stash('flcf_def');
    if (!isset($flcf_def)) {
        return '';
    }
    $options = $flcf_def['fields'][$name]['options'];
    return is_array($options) ? count($options) : 0;
}
?>
