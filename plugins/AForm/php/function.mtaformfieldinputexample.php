<?php
require_once('classes/aform_field.class.php');
require_once('lib/aform_lib.php');

function smarty_function_mtaformfieldinputexample($args, &$ctx){
  global $mt;

  $aform_id = $args["aform_id"];
  $parts_id = $args["parts_id"];
  $args_tag = !empty($args["tag"]) ? $args["tag"] : "div";
  if( empty($aform_id) ){ return ""; }
  if( empty($parts_id) ){ return ""; }

  $field_class = new AFormField();
  $fields = $field_class->Find("aform_field_aform_id=".$aform_id." AND aform_field_parts_id='".$parts_id."'");
  if( empty($fields) ){ return ""; }
  $field = $fields[0];

  if( !$field->input_example ){
    return "";
  }

  $tag = '<'.$args_tag.' class="aform-input-example '. encode_html($parts_id) .'">'. $field->input_example .'</'.$args_tag.'>';
  return $tag;
}
