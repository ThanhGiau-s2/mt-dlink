<?php
require_once('classes/aform_field.class.php');
require_once('lib/aform_lib.php');

function smarty_function_mtaformfielderror($args, &$ctx){
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

  $tag;
  if( $field->type == 'calendar' ){
    $tag = '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-yy-error"></'.$args_tag.'>'.
           '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-mm-error"></'.$args_tag.'>'.
           '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-dd-error"></'.$args_tag.'>';
  }elseif( $field->type == 'reserve' ){
    $tag = '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-date-error"></'.$args_tag.'>'.
           '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-plan-id-error"></'.$args_tag.'>'.
           '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-option-value-id-error"></'.$args_tag.'>';
  }elseif( $field->type == 'name' ){
    $tag = '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-lastname-error"></'.$args_tag.'>'.
           '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-firstname-error"></'.$args_tag.'>';
  }elseif( $field->type == 'kana' ){
    $tag = '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-lastname-kana-error"></'.$args_tag.'>'.
           '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-firstname-kana-error"></'.$args_tag.'>';
  }else{
    $tag = '<'.$args_tag.' class="aform-error '. encode_html($parts_id) .'" id="'. encode_html($parts_id) .'-error"></'.$args_tag.'>';
  }
  return $tag;
}
