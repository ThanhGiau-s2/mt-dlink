<?php
# Movable Type (r) (C) 2001-2017 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

function smarty_block_mtifpingsmoderated($args, $content, &$ctx, &$repeat) {
    # status: complete
    if (!isset($content)) {
        $switch = $ctx->mt->config('PluginSwitch');
        if (isset($switch) && isset($switch["Trackback"]) && !$switch["Trackback"]) {
            return $ctx->_hdlr_if($args, $content, $ctx, $repeat, 0);
        }

        $blog = $ctx->stash('blog');
        $moderated = ($blog->blog_moderate_pings);
        return $ctx->_hdlr_if($args, $content, $ctx, $repeat, $moderated);
    } else {
        return $ctx->_hdlr_if($args, $content, $ctx, $repeat);
    }
}
?>
