<?php
function smarty_block_mtflcfasset($args, $content, &$ctx, &$repeat) {
    $localvars = array('_assets', 'asset', '_assets_counter', 'conditional' ,'else_content');
    $counter = 0;

    if (!isset($content)) {
        $ctx->localize($localvars);
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
        if (isset($val) && is_numeric($val)) {
            $fetch_args = array('id' => $val);
            $assets = $ctx->mt->db()->fetch_assets($fetch_args);
        }
        else {
            $assets = array();
        }
        $ctx->stash('_assets', $assets);
    }
    else {
        $assets = $ctx->stash('_assets');
        $counter = $ctx->stash('_assets_counter');
    }

    $ctx->stash('conditional', empty($assets) ? 0 : 1);
    if (empty($assets)) {
        $ret = $ctx->_hdlr_if($args, $content, $ctx, $repeat, 0);
        if (!$repeat)
              $ctx->restore($localvars);
        return $ret;
    }
    if ($counter < count($assets)) {
        $ctx->stash('asset',  $assets[$counter]);
        $ctx->stash('_assets_counter', $counter + 1);
        $repeat = true;
    } else {
        $ctx->restore($localvars);
        $repeat = false;
    }

    return $content;
}
?>
