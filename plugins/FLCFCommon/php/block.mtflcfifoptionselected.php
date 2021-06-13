<?php
function smarty_block_mtflcfifoptionselected($args, $content, &$ctx, &$repeat) {
    if (!isset($content)) {
        $selected = $ctx->stash('flcf_option_selected');
        return $ctx->_hdlr_if($args, $content, $ctx, $repeat, ($selected ? 1 : 0));
    }
    else {
        return $ctx->_hdlr_if($args, $content, $ctx, $repeat);
    }
}
?>
