<?php
require_once("class.baseobject.php");

class AformField extends BaseObject
{
    public $_table = 'mt_aform_field';
    protected $_prefix = "aform_field_";
    protected $_has_meta = false;


    function Find($where, $bindarr=false, $pkeysArr=false, $extra=array()) {
        $fields = parent::Find($where, $bindarr, $pkeysArr, $extra);
        // set properties
        for( $i = 0; $i < count($fields); $i++ ){
            $fields[$i] = set_properties($fields[$i]);
        }
        return $fields;
    }

    function Save() {
        if (empty($this->aform_field_class))
            $this->aform_field_class = 'aform_field';
        return parent::Save();
    }
}


function set_properties( $field ){
    $json_data = json_decode($field->property, true);

    $field->use_default = $json_data['use_default'];
    $field->default_label = $json_data['default_label'];
    $field->privacy_link = $json_data['privacy_link'];
    $field->is_replyed = $json_data['is_replyed'];
    $field->only_ascii = $json_data['only_ascii'];
    $field->allow_ascii_chars = $json_data['allow_ascii_chars'];
    $field->input_example = $json_data['input_example'];
    $field->min_length = $json_data['min_length'];
    $field->max_length = $json_data['max_length'];
    $field->upload_type = $json_data['upload_type'];
    $field->upload_size = $json_data['upload_size'];
    $field->upload_size_numeric = get_upload_size_numeric($json_data['upload_size']);
    $field->parameter_name = $json_data['parameter_name'];
    $field->show_parameter = $json_data['show_parameter'];
    if( is_array($json_data['options']) ){
        for( $i=0; $i < count($json_data['options']); $i++ ){
            $json_data['options'][$i]{"index"} = $i+1;
        }
    }
    $field->options = $json_data['options'];
    $field->range_from = $json_data['range_from'];
    $field->range_to = $json_data['range_to'];
    $field->default_value = get_default_value($json_data['default_value']);
    $field->require_twice = $json_data['require_twice'];
    $field->use_ajaxzip = $json_data['use_ajaxzip'];
    $field->ajaxzip_prefecture_parts_id = $json_data['ajaxzip_prefecture_parts_id'];
    $field->ajaxzip_city_parts_id = $json_data['ajaxzip_city_parts_id'];
    $field->ajaxzip_area_parts_id = $json_data['ajaxzip_area_parts_id'];
    $field->ajaxzip_street_parts_id = $json_data['ajaxzip_street_parts_id'];
    $field->disable_dates = _parse_disable_dates($json_data['disable_dates']);
    $field->default_text = $json_data['default_text'];
    $field->options_horizontally = $json_data['options_horizontally'];
    $field->relations = ($json_data['relations'] ? $json_data['relations'] : array());
    if (!isset($json_data['require_hyphen'])) {
        if ($field->type == 'zipcode') {
            $json_data['require_hyphen'] = 1;
        }
    }
    $field->require_hyphen = $json_data['require_hyphen'];
    $field->abs_range_from = $json_data['abs_range_from'];
    $field->next_text = $json_data['next_text'];
    return $field;
}

function _parse_disable_dates($str) {
    $disable_dates = array();
    if ($str) {
        $dates = explode("\n", $str);
        if ($dates) {
            foreach ($dates as $date) {
                list($ymd, $title) = explode(",", $date);
                $ymd = preg_replace("/\D/", "", $ymd);
                $disable_dates[$ymd] = array('title' => $title);
            }
        }
    }
    return $disable_dates;
}

function get_upload_size_numeric( $size_text ){
    // remove [,]
    $size_text = preg_replace("/,/", "", $size_text);

    // calc size
    $size = 0;
    if( preg_match("/K$/i", $size_text) ){
      $size = sprintf("%0.1f", $size_text) * 1024;
    }elseif( preg_match("/M$/i", $size_text) ){
      $size = sprintf("%0.1f", $size_text) * 1024 * 1024;
    }elseif( preg_match("/G$/i", $size_text) ){
      $size = sprintf("%0.1f", $size_text) * 1024 * 1024 * 1024;
    }else{
      $size = sprintf("%0.1f", $size_text);
    }
    return $size;
}

function get_default_value($default_value) {
    $yy = date('Y');
    $mm = date('m');
    $dd = date('d');
    if( $default_value == 'today' ){
        ;
    }elseif( preg_match("/([\+\-]\d+)((day|month|year))/", $default_value, $matches) ){
        if( $matches[2] == 'year' ){
            $yy += intval($match[1]);
            $days_in = days_in($mm, $yy);
            if( $dd > $days_in ){
                $dd = $days_in;
            }
        }elseif( $matches[2] == 'month' ){
            $mm += intval($matches[1]);
            if( $mm > 12 ){
                $yy += 1;
                $mm -= 12;
            }
            if( $mm < 1 ){
                $yy -= 1;
                $mm += 12;
            }
            $days_in = days_in($mm, $yy);
            if( $dd > $days_in ){
                $dd = $days_in;
            }
        }elseif( $matches[2] == 'day' ){
            $ts = time() + intval($matches[1]) * 24*3600;
            $yy = date('Y', $ts);
            $mm = date('m', $ts);
            $dd = date('d', $ts);
        }
    }else{
        $yy = $mm = $dd= '';
    }
    $ret = array('yy' => $yy, 'mm' => $mm, 'dd' => $dd, 'text' => $default_value);
    return $ret;
}
?>
