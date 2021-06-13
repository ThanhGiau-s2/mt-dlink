<?php
function smarty_block_mtflcfifunitname($args, $content, &$ctx, &$repeat) {
    if (!isset($content)) {
        $field_value = $ctx->stash('flcf_field_value');
        if (!isset($field_value)) {
            return '';
        }
        $unit_name = $field_value->flcf_unit_name;
        $if_name = $args['name'];
        if (!isset($if_name)) {
            $if_name = $args['field'];
        }
        return $ctx->_hdlr_if($args, $content, $ctx, $repeat, ($unit_name === $if_name ? 1 : 0));
    }
    else {
        return $ctx->_hdlr_if($args, $content, $ctx, $repeat);
    }
}
?>
