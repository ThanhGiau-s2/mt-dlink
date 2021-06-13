<?php
require_once('block.mtunless.php');

function smarty_block_mtflcfunlessvalue($args, $content, &$ctx, &$repeat) {
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
    $val = $field_value->$name;
    $args['name'] = '__flcf_if_value';
    $vars =& $ctx->__stash['vars'];
    $vars['__flcf_if_value'] = $val;
    return smarty_block_mtunless($args, $content, $ctx, $repeat);
}
?>
