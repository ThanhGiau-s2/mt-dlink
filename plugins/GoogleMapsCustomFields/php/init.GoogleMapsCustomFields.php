<?php
$mt = MT::get_instance();
$ctx = &$mt->context();
if (defined('CUSTOMFIELDS_ENABLED')) {

    require_once('class.baseobject.php');
    require_once('class.mt_field.php');
    require_once('google_maps_custom_fields_common.php');
    $fld = new Field();
    $fields = $fld->Find("field_type = 'googlemaps'");
    if ( !empty( $fields ) ) {
        foreach ($fields as $field) {
            $tag_name = strtolower($field->field_tag);
            $fj_gmap_fields[$tag_name] = $field;
            $func = <<<CODE
function customfield_gmap_${tag_name}_block(\$args, \$content, &\$ctx, &\$repeat) {
    return _hdlr_customfield_gmap_block(\$args, \$content, \$ctx, \$repeat, '$tag_name');
}
CODE;
            eval($func);
            $ctx->add_container_tag($tag_name . 'block', "customfield_gmap_${tag_name}_block");
            $ctx->conditionals['mt' . $tag_name . 'block'] = 1;
        }
    }

    global $Lexicon_ja;
    $Lexicon_ja['View on larger map'] = '大きな地図で見る';
}
$ctx->conditionals['mtflcfgmap'] = 1;

function _hdlr_customfield_gmap_block($args, $content, &$ctx, &$repeat, $tag_name) {
    global $customfields_custom_handlers;

    $field = $customfields_custom_handlers[$tag_name];
    $obj = _hdlr_customfield_obj($ctx, $field->field_obj_type);
    $value = $obj->{$obj->_prefix . 'field.' . $field->field_basename};
    $params = _fjgmapcf_get_params($value, $field->field_options);
    $flag = count($params) && $params['show'];
    if (!isset($content)) {
        $ctx->stash('fjgmcf_params', $params);
        if (VERSION >= 6.3) {
            $ctx->assign('conditional', 1);
        }
        return $ctx->_hdlr_if($args, $content, $ctx, $repeat, $flag);
    }
    else {
        return $ctx->_hdlr_if($args, $content, $ctx, $repeat);
    }
}
?>
