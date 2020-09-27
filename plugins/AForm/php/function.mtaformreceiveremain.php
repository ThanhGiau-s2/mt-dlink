<?php
require_once('classes/aform.class.php');
require_once('classes/aform_data.class.php');

function smarty_function_mtaformreceiveremain($args, &$ctx){
  global $mt;

  $aform_id = $args["aform_id"];
  if( empty($aform_id) ){ return ""; }

  $aform = new AForm();
  $aform->Load("aform_id='".$aform_id."'");
  if( empty($aform) ){ return ""; }

  $aform_data = new AFormData();
  $received_count = $aform_data->count(array('where' => "aform_data_aform_id='".$aform_id."'"));

  return $aform->receive_limit - $received_count;
}
