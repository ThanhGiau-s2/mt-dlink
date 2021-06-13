<?php
require_once('google_maps_custom_fields_common.php');

function smarty_function_mtgmapcfstatic($args, &$ctx) {
    return _fjgmapcf_static($ctx, $args, 'gmapcfstatic');
}
?>
