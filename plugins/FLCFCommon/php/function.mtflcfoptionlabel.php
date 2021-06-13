<?php
function smarty_function_mtflcfoptionlabel($args, &$ctx) {
    if ($ctx->stash('flcf_option_label')) {
        return $ctx->stash('flcf_option_label');
    }

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
    $flcf_fields = $ctx->stash('flcf_fields');
    $options = $flcf_fields[$name]['options'];
    if (!isset($options)) {
        $options = array();
    }
    $val = $field_value->$name;
    if (isset($val)) {
        foreach ($options as $option) {
            if ($option['value'] == $val) {
                return $option['label'] ? $option['label'] : $option['value'];
            }
        }
        return '';
    }
    else {
        return '';
    }
}
?>
