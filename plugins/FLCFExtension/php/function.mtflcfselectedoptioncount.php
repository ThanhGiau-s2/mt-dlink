<?php
function smarty_function_mtflcfselectedoptioncount($args, &$ctx) {
    $name = $args['name'];
    if (!isset($name)) {
        $name = $args['field'];
    }
    if (!isset($name)) {
        return '';
    }
    $field_value = $ctx->stash('flcf_field_value');
    if (!isset($field_value)) {
        return '';
    }
    $options = $field_value->$name;
    return isset($options) ? count($options) : 0;
}
?>
