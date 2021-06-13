<?php
require_once('google_maps_custom_fields_common.php');

function smarty_block_mtflcfgmap($args, $content, &$ctx, &$repeat) {
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
    $flcf_def = $ctx->stash('flcf_def');
    $options = array(
        $flcf_def['fields'][$name]['width'],
        $flcf_def['fields'][$name]['height']
    );
    $params = _fjgmapcf_get_params($field_value->$name, $options);
    $flag = count($params) && $params['show'];
    if (!isset($content)) {
        $ctx->stash('fjgmcf_params', $params);
        return $ctx->_hdlr_if($args, $content, $ctx, $repeat, $flag);
    }
    else {
        return $ctx->_hdlr_if($args, $content, $ctx, $repeat);
    }
}
?>
