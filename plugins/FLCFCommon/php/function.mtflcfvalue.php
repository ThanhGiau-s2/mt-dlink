<?php
function smarty_function_mtflcfvalue($args, &$ctx) {
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
    $type = $flcf_fields[$name]['type'];
    if (!$type) {
        $type = 'text';
    }
    $val = $field_value->$name;
    if (isset($val)) {
        if (VERSION >= 6.3) {
            $flcf_tmpl_output = $ctx->getTemplateVars('flcf_tmpl_output');
        }
        else {
            $flcf_tmpl_output = $ctx->flcf_tmpl_output;
        }
        if (isset($flcf_tmpl_output[$type])) {
            return call_user_func($flcf_tmpl_output[$type], $args, $ctx, $val);
        }
        else if ($type == 'datetime' || $type == 'date' || $type == 'time') {
            if (preg_match('/\d{14}/', $val)) {
                $args['ts'] = $val;
                return $ctx->_hdlr_date($args, $ctx);
            }
            else {
                return '';
            }
        }
        else if ($type == 'textarea') {
            return html_text_transform($val);
        }
        else {
            return $val;
        }
    }
    else {
        return '';
    }
}
?>
