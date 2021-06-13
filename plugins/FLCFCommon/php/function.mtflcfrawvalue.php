<?php
function smarty_function_mtflcfrawvalue($args, &$ctx) {
    $field_value = $ctx->stash('flcf_field_value');
    if (!isset($field_value)) {
        return '';
    }
    $name = $args['name'];
    if (!isset($name)) {
        $name = $args['field'];
    }
    if (!isset($name)) {
        return '';
    }
    $val = $field_value->$name;
    return isset($val) ? $val : '';
}
?>
