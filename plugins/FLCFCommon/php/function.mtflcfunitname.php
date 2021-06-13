<?php
function smarty_function_mtflcfunitname($args, &$ctx) {
    $field_value = $ctx->stash('flcf_field_value');
    if (!isset($field_value)) {
        return '';
    }
    $val = $field_value->flcf_unit_name;
    return $val ? $val : '';
}
?>
