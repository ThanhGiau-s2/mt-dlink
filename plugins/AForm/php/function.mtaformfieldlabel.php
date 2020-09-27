<?php
require_once('classes/aform.class.php');
require_once('classes/aform_field.class.php');
require_once('lib/aform_lib.php');

function smarty_function_mtaformfieldlabel($args, &$ctx){
  global $mt;

  $aform_id = $args["aform_id"];
  $parts_id = $args["parts_id"];
  if( empty($aform_id) ){ return ""; }
  if( empty($parts_id) ){ return ""; }
  $aform_class = new AForm();
  $aform = $aform_class->Find("aform_id=".$aform_id);
  if( empty($aform) ){ return ""; }
  $aform = $aform[0];
  if( $aform->lang != "" && $aform->lang != "en_us" ){
    require_once('lib/l10n_'. $aform->lang .'.php');
  } else {
    require_once('lib/l10n_en.php');
  }

  $field_class = new AFormField();
  $fields = $field_class->Find("aform_field_aform_id=".$aform_id." AND aform_field_parts_id='".$parts_id."'");
  if( empty($fields) ){ return ""; }
  $field = $fields[0];

  aform_callback('aform_before_field_label', array('ctx' => $ctx, 'args' => $args, 'field' => $field));

  $args_tag = !empty($args["tag"]) ? $args["tag"] : "label";
  $for = "";
  if ($args_tag == "label") {
    $for = ' for="'. encode_html($parts_id) .'"';
  }

  $required_tag = '';
  if( $field->is_necessary ){
    $required_tag = '<span class="aform-required">'. $mt->translate('required') .'</span>';
  }

  $tag;
  if( $field->type == 'checkbox' || $field->type == 'radio' ){
    $tag = '<span class="aform-label '. encode_html($parts_id) .'">'.  encode_html($field->label) . $required_tag .'</span>';
  }elseif( $field->type == 'privacy' ){
    $tag = '<span class="aform-label '. encode_html($parts_id) .'">';
    if( $field->privacy_link != "" ){
      $icon = $mt->translate('icon_new_windows');
      if ($icon == "" || $icon == 'icon_new_windows') {
        $icon = _get_plugin_static_uri() . 'images/icons/icon_new_windows.gif';
      }
      $tag .= '<a target="_blank" href="'. encode_html($field->privacy_link) .'">'. encode_html($field->label) .'<img src="'. $icon .'" alt="'. encode_html($mt->translate('new window open')) .'"></a>';
    }else{
      $tag .= encode_html($field->label);
    }
    $tag .= $required_tag .'</span>';
  }elseif( $field->type == 'parameter' ){
    if( $field->show_parameter ){
      $tag = '<'. $args_tag . $for .' class="aform-label '. encode_html($parts_id) .'">'.  encode_html($field->label) . $required_tag .'</'. $args_tag .'>';
    }
  }else{
    $tag = '<'. $args_tag . $for .' class="aform-label '. encode_html($parts_id) .'">'.  encode_html($field->label) . $required_tag .'</'. $args_tag .'>';
  }
  return $tag;
}
