<?php
require_once('google_maps_custom_fields_common.php');

class GoogleMapsCustomFields extends MTPlugin {
    var $registry = array(
        'name' => 'GoogleMapsCustomFields',
        'id'   => 'GoogleMapsCustomFields',
        'key'  => 'googlemapscustomfields',
        'author_name' => 'Hajime Fujimoto',
        'author_link' => 'http://www.h-fj.com/blog/',
        'version' => '1.20',
        'description' => 'Google Maps Custom Fields.',
        'callbacks' => array(
            'acf_tag_installer' => 'gmap_tag_installer'
        ),
    );

    function gmap_tag_installer($mt, &$ctx) {
        $args = $ctx->stash('acf_tag_install_args');
        $type = $args['type'];

        if ($type == 'googlemaps') {
            $tag        = $args['tag'];
            $plg_name   = $args['plugin_name'];
            $class      = $args['class'];
            $field_name = $args['field_name'];
            $data_type  = $args['data_type'];
            $func = <<<HERE
function acf_${tag}_gmap_block(\$args, \$content, &\$ctx, &\$repeat) {
    return acf_gmap_block(\$args, \$content, \$ctx, \$repeat, '$plg_name', '$class', '$field_name', '$data_type', '$type');
}
HERE;
            eval($func);
            $ctx->add_container_tag($tag . 'block', "acf_${tag}_gmap_block");
            $ctx->conditionals['mt' . $tag . 'block'] = 1;
        }
    }
}

function acf_gmap_block($args, $content, &$ctx, &$repeat, $plg_name, $class, $field_name, $data_type, $type) {
    global $app;

    $cfg = $app->stash('plugins_config');
    $field = $cfg[$plg_name]['object_types'][$class][$field_name];
    $obj = _acf_load_object($ctx, $class);
    $colname = "${class}_${field_name}";
    $value = $obj->$colname;
    $params = _fjgmapcf_get_params($value, $field['acf']['options']);
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
