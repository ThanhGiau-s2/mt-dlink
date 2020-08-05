<?php
# Movable Type (r) (C) 2001-2017 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

function smarty_function_mtauthorcommentcount($args, &$ctx) {
    $mt = MT::get_instance();
    $author = $ctx->stash('author');

    $sql = "
        select count(*)
          from mt_comment
               join mt_entry on entry_id = comment_entry_id
         where comment_visible = ?
           and comment_commenter_id = ?
           and entry_status = ?";
    $conn = $mt->db()->db();
    $handle = $conn->prepare($sql);

    $comment_visible = 1;
    $commenter_id = $author->id;
    $entry_release = 2; # RELEASE
    $bindVars = array($comment_visible, $commenter_id, $entry_release);

    $row = $conn->getRow($handle, $bindVars);

    return $ctx->count_format($row[0], $args);
}
?>
