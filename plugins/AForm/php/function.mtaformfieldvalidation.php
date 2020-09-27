<?php
require_once('classes/aform_field.class.php');
require_once('lib/aform_lib.php');

function smarty_function_mtaformfieldvalidation($args, &$ctx){
  global $mt;

  $aform_id = $args["aform_id"];
  $parts_id = $args["parts_id"];
  $args_tag = !empty($args["tag"]) ? $args["tag"] : "span";
  if( empty($aform_id) ){ return ""; }
  if( empty($parts_id) ){ return ""; }

  $field_class = new AFormField();
  $fields = $field_class->Find("aform_field_aform_id=".$aform_id." AND aform_field_parts_id='".$parts_id."'");
  if( empty($fields) ){ return ""; }
  $field = $fields[0];

  $tags = array();

  $only_ascii = '';
  if ($field->only_ascii) {
    $tags[] = $mt->translate('Only ascii characters');
  }

  if ($field->min_length && $field->max_length) {
    $tags[] = '<span class="max-length">'. encode_html($mt->translate('[_1]-[_2] characters', array($field->min_length, $field->max_length))) .'</span>';
  }
  elseif( $field->min_length ){
    $tags[] = '<span class="max-length">'. encode_html($mt->translate('minimum [_1] characters', $field->min_length)) .'</span>';
  }
  elseif( $field->max_length ){
    $tags[] = '<span class="max-length">'. encode_html($mt->translate('max [_1] characters', $field->max_length)) .'</span>';
  }
  if( count($tags) ){
    return '<'.$args_tag.' class="aform-validation '. encode_html($parts_id) .'">('. join('', $tags) .')</'.$args_tag.'>';
  }else{
    return "";
  }
}
