<?php
require_once('classes/aform.class.php');
require_once('classes/aform_field.class.php');

function smarty_function_mtaformfieldrelationscript($args, &$ctx){
  global $mt;

  $aform_id = $args["aform_id"];
  if( empty($aform_id) ){ return ""; }

  $aform_field = new AFormField();
  $fields = $aform_field->Find("aform_field_aform_id='".$aform_id."'");
  if( empty($fields) ){ return ""; }

  $conds = array(
    "eq" => "==",
    "ne" => "!=",
    "ge" => ">=",
    "gt" => ">",
    "le" => "<=",
    "lt" => "<",
  );

  $targets = array();
  $relations = array();
  foreach ($fields as $field) {
    if (is_array($field->relations)) {
      foreach ($field->relations as $relation) {
        if (!$targets[$relation["parts_id"]]) {
          $target_field = $aform_field->Find("aform_field_aform_id='". $aform_id ."' AND aform_field_parts_id='". $relation["parts_id"] ."'");
          $targets[$relation["parts_id"]] = $target_field[0];
        }
        $target_field = $targets[$relation["parts_id"]];
        if ($target_field) {
          $value = $relation["value"];
          if (!empty($target_field->options)) {
            foreach ($target_field->options as $option) {
              if ($option["label"] == $value) {
                $value = $option["value"];
              }
            }
          }
          $cond = $conds[$relation["cond"]] ? $conds[$relation["cond"]] : "==";
          if (!is_array($relations[$target_field->parts_id])) {
            $relations[$target_field->parts_id] = array();
          }
          $relations[$target_field->parts_id][] = array('parts_id' => $field->parts_id, 'value' => $value, 'cond' => $cond);
        }
      }
    }
  }

  $script = "aform.relations = " . json_encode($relations);

  return $script;
}
