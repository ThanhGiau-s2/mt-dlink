<?php
require_once('classes/aform.class.php');
require_once('classes/aform_field.class.php');
require_once('lib/aform_lib.php');

function smarty_function_mtaformfieldinput($args, &$ctx){
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

  $value = $field->default_text;
  aform_callback('aform_before_field_input', array('ctx' => $ctx, 'args' => $args, 'field' => $field, 'value' => &$value));

  $tag;
  if( $field->type == 'label' ){
    $tag = _make_label_tag($field);
  }elseif( $field->type == 'note' ){
    $tag = _make_note_tag($field);
  }elseif( $field->type == 'text' ){
    $tag = _make_text_tag($field, null, $value);
  }elseif( $field->type == 'textarea' ){
    $tag = _make_textarea_tag($field, null, $value);
  }elseif( $field->type == 'radio' ){
    $tag = _make_radio_tag($field, null, $value);
  }elseif( $field->type == 'checkbox' ){
    $tag = _make_checkbox_tag($field, null, $value);
  }elseif( $field->type == 'select' ){
    $tag = _make_select_tag($field, null,$value);
  }elseif( $field->type == 'prefecture' ){
    $tag = _make_select_tag($field, null,$value);
  }elseif( $field->type == 'email' ){
    $tag = _make_text_tag($field, array('hankaku', 'validate-email'), $value);
  }elseif( $field->type == 'tel' ){
    $tag = _make_text_tag($field, array('hankaku', 'validate-tel'), $value);
  }elseif( $field->type == 'zipcode' ){
    $tag = _make_zipcode_tag($field, null, $value);
  }elseif( $field->type == 'url' ){
    $tag = _make_text_tag($field, array('hankaku', 'validate-url'), $value);
  }elseif( $field->type == 'privacy' ){
    $tag = _make_checkbox_tag($field, array('validate-privacy'));
  }elseif( $field->type == 'upload' ){
    $tag = _make_upload_tag($field);
  }elseif( $field->type == 'parameter' ){
    $tag = _make_parameter_tag($field, null, $value);
  }elseif( $field->type == 'calendar' ){
    $tag = _make_calendar_tag($field, null, $value);
  }elseif( $field->type == 'password' ){
    $tag = _make_password_tag($field);
  }elseif( $field->type == 'name' ){
    $tag = _make_name_tag($field, null, $value);
  }elseif( $field->type == 'kana' ){
    $tag = _make_kana_tag($field, null, $value);
  }elseif( $field->type == 'reserve' ){
    $tag = _make_reserve_tag($field);
  }elseif( $field->type == 'payment' ){
    $aform_payment_path = aform_payment_path();
    if (file_exists($aform_payment_path)) {
      require_once($aform_payment_path . 'php/lib/Plugin.php');
      $aform_payment_plugin = new AFormPaymentPlugin();
      $tag = $aform_payment_plugin->make_payment_tag($ctx, $field);
    }
  }

  aform_callback('aform_after_field_input', array('ctx' => $ctx, 'args' => $args, 'field' => $field, 'tag' => &$tag));

  return $tag;
}

# label
function _make_label_tag( $field, $additional_class = null ){
    $classes = array('aform-input', 'aform-hdln', $field->parts_id);
    if(is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    $tag = '<div
        class="'. encode_html(join(' ', $classes)) .'">'.
        $field->label . '</div>';
    return $tag;
}

# note
function _make_note_tag ( $field, $additional_class = null ){
    $classes = array('aform-input', 'aform-note', $field->parts_id);
    if(is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    $tag = '<div
        class="'. encode_html(join(' ', $classes)) .'">'.
        $field->label . '</div>';
    return $tag;
}

# text
function _make_text_tag( $field, $additional_class = null, $value = null ){
    $classes = array('aform-input', 'aform-'. $field->type, $field->parts_id, 'aform-validate');
    if(is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->is_necessary ){ $classes[] = 'required'; }
    if( $field->min_length > 0 || $field->max_length > 0 ){ $classes[] = 'validate-length'; }
    if( $field->only_ascii ){ $classes[] = 'hankaku'; $classes[] = 'validate-ascii'; }
    if( $field->require_hyphen ){ $classes[] = 'require-hyphen'; }
	$type = 'text';
	switch ($field->type) {
	case 'email':
		$type = 'email';
		break;
	case 'tel':
		$type = 'tel';
		break;
	case 'url':
		$type = 'url';
		break;
	}

	$pattern = _make_field_pattern($field);

    $tag = '<input 
        id="'. encode_html($field->parts_id) .'"
        class="'. encode_html(join(' ', $classes)) .'" 
        name="aform-field-'. encode_html($field->id) .'" 
        type="'. $type .'" 
        '. put_attr_value($value) .' 
        size="40" 
        title="'. encode_html(_get_tag_title($field)) .'"
        '. ($field->is_necessary ? 'required' : '') .'
        '. ($pattern ? $pattern : '') .'
        '. ($field->max_length ? 'maxlength="'. encode_html($field->max_length) .'"' : '') .' />';
    if ($field->require_twice) {
        $tag .= _make_reenter_tag($type, $field, $classes);
    }
    return $tag;
}

# zipcode
function _make_zipcode_tag( $field, $additional_class = null, $value = null ){
    $classes = array('aform-input', 'aform-'. $field->type, $field->parts_id, 'hankaku', 'validate-zipcode', 'aform-validate');
    if(is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->is_necessary ){ $classes[] = 'required'; }
    if( $field->min_length > 0 || $field->max_length > 0 ){ $classes[] = 'validate-length'; }
    if( $field->require_hyphen ){ $classes[] = 'require-hyphen'; }

    $onkeyup = '';
    if ($field->use_ajaxzip == '4') {
        $prefecture_field = _get_aform_field_by_parts_id($field->aform_id, $field->ajaxzip_prefecture_parts_id);
        $city_field = _get_aform_field_by_parts_id($field->aform_id, $field->ajaxzip_city_parts_id);
        $area_field = _get_aform_field_by_parts_id($field->aform_id, $field->ajaxzip_area_parts_id);
        $street_field = _get_aform_field_by_parts_id($field->aform_id, $field->ajaxzip_street_parts_id);
        if ($prefecture_field && $city_field && $area_field && $street_field) {
            $onkeyup = sprintf(" onKeyUp=\"AjaxZip2.zip2addr(this,'aform-field-%d','aform-field-%d',null,'aform-field-%d','aform-field-%d');\"", $prefecture_field->id, $city_field->id, $street_field->id, $area_field->id);
        }
    }
    elseif ($field->use_ajaxzip == '3') {
        $prefecture_field = _get_aform_field_by_parts_id($field->aform_id, $field->ajaxzip_prefecture_parts_id);
        $city_field = _get_aform_field_by_parts_id($field->aform_id, $field->ajaxzip_city_parts_id);
        $street_field = _get_aform_field_by_parts_id($field->aform_id, $field->ajaxzip_street_parts_id);
        if ($prefecture_field && $city_field && $street_field) {
            $onkeyup = sprintf(" onKeyUp=\"AjaxZip2.zip2addr(this,'aform-field-%d','aform-field-%d',null,'aform-field-%d');\"", $prefecture_field->id, $city_field->id, $street_field->id);
        }
    }
    elseif ($field->use_ajaxzip == '2') {
        $prefecture_field = _get_aform_field_by_parts_id($field->aform_id, $field->ajaxzip_prefecture_parts_id);
        $city_field = _get_aform_field_by_parts_id($field->aform_id, $field->ajaxzip_city_parts_id);
        if ($prefecture_field && $city_field) {
            $onkeyup = sprintf(" onKeyUp=\"AjaxZip2.zip2addr(this,'aform-field-%d','aform-field-%d',null,'aform-field-%d');\"", $prefecture_field->id, $city_field->id, $city_field->id);
        }
    }
    $tag = '<input 
        id="'. encode_html($field->parts_id) .'"
        class="'. encode_html(join(' ', $classes)) .'" 
        name="aform-field-'. encode_html($field->id) .'" 
        type="text" 
        '. put_attr_value($value) .' 
        size="40" 
        title="'. encode_html(_get_tag_title($field)) .'"
        '. ($field->is_necessary ? 'required' : '') .'
        '. ($field->max_length ? 'maxlength="'. encode_html($field->max_length) .'"' : '') .
        $onkeyup .' />';
    return $tag;
}

# textarea
function _make_textarea_tag( $field, $additional_class = null, $value = null ){
    $classes = array('aform-input', 'aform-textarea', $field->parts_id, 'aform-validate');
    if(is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->is_necessary ){ $classes[] = 'required'; }
    if( $field->min_length > 0 || $field->max_length > 0 ){ $classes[] = 'validate-length'; }

	$pattern = _make_field_pattern($field);

    $tag = '<textarea 
        id="'. encode_html($field->parts_id) .'"
        class="'. encode_html(join(' ', $classes)) .'" 
        name="aform-field-'. encode_html($field->id) .'" 
        cols="40" 
        rows="6" 
        title="'. encode_html(_get_tag_title($field)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->is_necessary ? 'required' : '') .'
        '. ($field->max_length ? 'maxlength="'. encode_html($field->max_length) .'"' : '') .' >'. encode_html($value) .'</textarea>';
    return $tag;
}

# radio
function _make_radio_tag( $field, $additional_class = null, $value = null ){
    global $mt;

    $classes = array('aform-input', 'aform-radio', $field->parts_id, 'aform-validate');
    if(is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->is_necessary ){ $classes[] = 'validate-one-required'; }

    // if other_text

    $additional_ul_class = $field->options_horizontally ? 'aform-horizontal-ul' : 'aform-vertical-ul';
    $tag = '<ul class="aform-radio-ul aform-field-'. $field->id .' '. $field->parts_id .' '. $additional_ul_class .'">';
    $cnt = 0;
    foreach( $field->options as $option ){
        $cnt++;
        if ($value['value']) {
          if ($option[label] == $value['value']) {
            $option[checked] = true;
            $option[other_text] = $value['other_text'];
          }else{
            $option[checked] = false;
            $option[other_text] = "";
          }
        }
        $other_text_field = '';
        if( $option[use_other] ){
          $other_text_field = '<input
              type="text"
              class="aform-validate aform-field-option-text validate-option-text '. $field->parts_id.'"
              id="'. $field->parts_id .'-'. $cnt .'-text"
              name="aform-field-'. $field->id .'-'. $cnt .'-text"
              title="'. encode_html($mt->translate('please input [_1] text.', $option[label])) .'"
              '. put_attr_value($option[other_text]) .'
          />';
        }
        $tag .= '<li><input
            class="'. encode_html(join(' ', $classes)) .'" 
            id="'. $field->parts_id .'-'. $cnt .'" 
            name="aform-field-'. encode_html($field->id) .'"
            type="radio" 
            value="'. encode_html($option[value]) .'" 
            '. ($field->is_necessary ? 'required' : '') .'
            title="'. encode_html(_get_tag_title($field)) .'"'.
            ($option[checked] ? ' checked="checked"' : '') .' />';
        $tag .= '<label for="'. encode_html($field->parts_id) .'-'. encode_html($cnt) .'">'. encode_html($option[label]) .'</label>'. $other_text_field .'</li>';
    }
    $tag .= '</ul>';
    return $tag;
}

# checkbox
function _make_checkbox_tag( $field, $additional_class = null, $value = null ){
    global $mt;

    $classes = array('aform-input', 'aform-checkbox', $field->parts_id, 'aform-validate');
    if(is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->type == 'checkbox' && $field->is_necessary ){
        $classes[] = 'validate-one-required';
    }
    $values = $value;

    $additional_ul_class = $field->options_horizontally ? 'aform-horizontal-ul' : 'aform-vertical-ul';
    $tag = '<ul class="aform-checkbox-ul aform-field-'. $field->id .' '. $field->parts_id .' '. $additional_ul_class .'">';
    $cnt = 0;
    foreach( $field->options as $option ){
        $cnt++;
        if (is_array($values)) {
          $option[checked] = false;
          $option[other_text] = '';
          foreach( $values as $v ){
            if( $option[label] == $v['value'] ){
              $option[checked] = true;
              $option[other_text] = $v['other_text'];
              break;
            }
          }
        }
        $other_text = '';
        if( $option[use_other] ){
          $other_text = '<input
              type="text"
              class="aform-validate aform-field-option-text validate-option-text '. $field->parts_id .'"
              id="'. $field->parts_id .'-'. $cnt .'-text"
              name="aform-field-'. $field->id .'-'. $cnt .'-text"
              title="'. encode_html($mt->translate('please input [_1] text.', $option[label])) .'"
              '. put_attr_value($option[other_text]) .'
          />';
        }
        $tag .= '<li><input
            class="'. encode_html(join(' ', $classes)) .'" 
            id="'. $field->parts_id .'-'. $cnt .'" 
            name="aform-field-'. encode_html($field->id) .'-'. $cnt .'"
            type="checkbox" 
            value="'. encode_html($cnt) .'" 
            '. ($field->is_necessary ? '' : '') .'
            title="'. encode_html(_get_tag_title($field)) .'"'.
            ($option[checked] ? ' checked="checked"' : '') .' />';
        $tag .= '<label for="'. encode_html($field->parts_id) .'-'. encode_html($cnt) .'">'. encode_html($option[label]) .'</label>'. $other_text .'</li>';
    }
    $tag .= '</ul>';
    return $tag;
}

# select
function _make_select_tag( $field, $additional_class = null, $value = null ){
    global $mt;

    $classes = array('aform-input', 'aform-'. $field->type, $field->parts_id, 'aform-validate');
    if(is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->is_necessary ){ $classes[] = 'validate-selection'; }

    $tag = '<select 
        id="'. encode_html($field->parts_id) .'"
        class="'. encode_html(join(' ', $classes)) .'" 
        name="aform-field-'. encode_html($field->id) .'"
        '. ($field->is_necessary ? 'required' : '') .'
        title="'. encode_html(_get_tag_title($field)) .'">';
    if( $field->use_default ){
        $tag .= '<option value="">'. $mt->translate('Please select') .'</option>';
    }
    $values = is_array($value) ? $value : array($value);
    foreach( $field->options as $option ){
        $selected = in_array($option[label], $values);
        $tag .= '<option value="'. encode_html($option[value]) .'"'. ($selected ? ' selected' : '') .'>'. encode_html($option[label]) .'</option>';
    }
    $tag .= '</select>';
    return $tag;
}

# upload
function _make_upload_tag( $field, $additional_class = null ){
    $classes = array('aform-input', 'aform-'. $field->type, $field->parts_id, 'aform-validate');
    if(is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->is_necessary ){ $classes[] = 'required'; }

    $tag = '<input 
        class="'. encode_html(join(' ', $classes)) .'" 
        id="'. encode_html($field->parts_id) .'" 
        name="aform-field-'. encode_html($field->id) .'"
        type="file" 
        size="40" 
        '. ($field->is_necessary ? 'required' : '') .'
        title="'. encode_html(_get_tag_title($field)) .'" />';
    return $tag;
}

# parameter
function _make_parameter_tag( $field, $additional_class = null, $value = null ){
    $classes = array('aform-input', 'aform-'. $field->type, $field->parts_id, 'aform-validate');
    if(is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->is_necessary ){ $classes[] = 'required'; }

    if ($_REQUEST[$field->parameter_name]) {
        $value = $_REQUEST[$field->parameter_name];
    }

    $tag = '<input
        class="'. encode_html(join(' ', $classes)) .'" 
        title="'. encode_html(_get_tag_title($field)) .'"
        type="hidden" 
        id="'. encode_html($field->parts_id) .'" 
        name="aform-field-'. encode_html($field->id) .'"
        '. put_attr_value($value) .' />';
    if( $field->show_parameter ){
        $tag .= '<span id="'. encode_html($field->parts_id) .'-text">'. encode_html($value) .'</span>';
    }
    if (empty($value)) {
      $tag .= '<script type="text/javascript">
        aform.parameters["'. encode_html($field->parts_id) .'"] = "'. encode_html($field->parameter_name) .'";
      </script>';
    }
    return $tag;
}

# calendar
function _make_calendar_tag( $field, $additional_class = null, $value = null ){
    global $mt;

    $classes = array('aform-input', 'aform-'. $field->type, $field->parts_id, 'aform-validate');
    if(is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->is_necessary ){ $classes[] = 'validate-selection'; }

    $default_value = $field->default_value;
    if ($value) {
      list($yy, $mm, $dd) = explode("/", $value);
      $default_value = array("yy" => $yy, "mm" => $mm, "dd" => $dd, "text" => "");
    }
    # year
    $tag = '<select
        class="'. encode_html(join(' ', $classes)) .'" 
        id="'. encode_html($field->parts_id) .'-yy" 
        name="aform-field-'. encode_html($field->id) .'-yy" 
        '. ($field->is_necessary ? 'required' : '') .'
        title="'. encode_html($mt->translate('please select year')) .'">';
    $tag .= '<option value="">----</option>';
    for( $yy = $field->range_from; $yy <= $field->range_to; $yy++ ){
        $selected = ($value && $yy == $default_value["yy"]) ? ' selected' : '';
        $tag .= sprintf('<option value="%d"%s>%d</option>', $yy, $selected, $yy);
    }
    $tag .= '</select><label for="'. encode_html($field->parts_id) .'-yy">'. encode_html($mt->translate('year')) .'</label>';

    # month
    $tag .= '<select
        class="'. encode_html(join(' ', $classes)) .'" 
        id="'. encode_html($field->parts_id) .'-mm" 
        name="aform-field-'. encode_html($field->id) .'-mm" 
        '. ($field->is_necessary ? 'required' : '') .'
        title="'. encode_html($mt->translate('please select month')) .'">';
    $tag .= '<option value="">--</option>';
    for( $mm = 1; $mm <= 12; $mm++ ){
        $selected = ($value && $mm == $default_value["mm"]) ? ' selected' : '';
        $tag .= sprintf('<option value="%d"%s>%d</option>', $mm, $selected, $mm);
    }
    $tag .= '</select><label for="'. encode_html($field->parts_id) .'-mm">'. encode_html($mt->translate('month')) .'</label>';

    # day
    $tag .= '<select
        class="'. encode_html(join(' ', $classes)) .'" 
        id="'. encode_html($field->parts_id) .'-dd" 
        name="aform-field-'. encode_html($field->id) .'-dd" 
        '. ($field->is_necessary ? 'required' : '') .'
        title="'. encode_html($mt->translate('please select day')) .'">';
    $tag .= '<option value="">--</option>';
    for( $dd = 1; $dd <= 31; $dd++ ){
        $selected = ($value && $dd == $default_value["dd"]) ? ' selected' : '';
        $tag .= sprintf('<option value="%d"%s>%d</option>', $dd, $selected, $dd);
    }
    $tag .= '</select><label for="'. encode_html($field->parts_id) .'-dd">'. encode_html($mt->translate('day')) .'</label>';
    $tag .= '<span><input type="hidden" id="'. encode_html($field->parts_id) .'" name="aform-field-'. encode_html($field->id) .'" ></span>';

	# disable dates
    $disable_dates = '';
    foreach ($field->disable_dates as $ymd => $disable_date) {
        $disable_dates .= '"'. $ymd .'": {"title": "'. $disable_date['title'] .'"},';
    }
    $disable_dates = preg_replace("/,$/", "", $disable_dates);

    $tag .= '<script type="text/javascript">
aform.datepickers["'. encode_html($field->parts_id) .'"] = {
  range_from: "'. encode_html($field->range_from) .'",
  range_to: "'. encode_html($field->range_to) .'",
  default_value: "'. encode_html($default_value["text"]) .'",
  disable_dates: {'. $disable_dates .'}
};
</script>';

    if ($field->abs_range_from != '') {
    $tag .= '<script type="text/javascript">
if (typeof aform.range_from === "undefined") {
  aform.range_from = new Object;
  aform.range_from_msg = "'. $mt->translate("Please enter date after [_1].", "%date%") .'";
}
var today = new Date();
var range_from = new Date(today.getFullYear(), today.getMonth(), today.getDate() + '. $field->abs_range_from .');
aform.range_from["'. encode_html($field->parts_id) .'"] = range_from;
</script>';
    }

    return $tag;
}

# text
function _make_password_tag( $field, $additional_class = null ){
    $classes = array('aform-input', 'aform-'. $field->type, $field->parts_id, 'aform-validate');
    if( is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->is_necessary ){ $classes[] = 'required'; }
    if( $field->min_length > 0 || $field->max_length > 0 ){ $classes[] = 'validate-length'; }

	$pattern = _make_field_pattern($field);

    $tag = '<input 
        id="'. encode_html($field->parts_id) .'"
        class="'. encode_html(join(' ', $classes)) .'" 
        name="aform-field-'. encode_html($field->id) .'" 
        type="password" 
        size="40" 
        title="'. encode_html(_get_tag_title($field)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->is_necessary ? 'required' : '') .'
        '. ($field->max_length ? 'maxlength="'. encode_html($field->max_length) .'"' : '') .' />';
    if ($field->require_twice) {
        $tag .= _make_reenter_tag('password', $field, $classes);
    }
    return $tag;
}

# get tag title
function _get_tag_title( $field, $label = null ){
    global $mt;

    $length_msg = "";
    if ($field->only_ascii) {
        $length_msg = $mt->translate('Only ascii characters');
    }
	if ($field->min_length && $field->max_length) {
        $length_msg .= $mt->translate('[_1]-[_2] characters', array($field->min_length, $field->max_length));
    }
	elseif ($field->min_length) {
        $length_msg .= $mt->translate('minimum [_1] characters', $field->min_length);
    }
	elseif ($field->max_length) {
        $length_msg .= $mt->translate('max [_1] characters', $field->max_length);
    }

    $title;
    if( $field->type == 'radio' || $field->type == 'checkbox' || $field->type == 'select' || $field->type == 'prefecture' ){
        $title = $mt->translate('please select');
    }elseif( $field->type == 'email' ){
        if( $length_msg ){
            $title = $mt->translate("please input [_1] (alphabet and numeric only. [_2].)", array($field->label, $length_msg));
        }else{
            $title = $mt->translate("please input [_1] (alphabet and numeric only.)", $field->label);
        }
        $title .= ' ' . $mt->translate('ex) foo@example.com');
    }elseif( $field->type == 'tel' ){
        if( $length_msg ){
            $title = $mt->translate("please input [_1] (numeric and hyphen only. [_2].)", array($field->label, $length_msg));
        }else{
            $title = $mt->translate("please input [_1] (numeric and hyphen only.)", $field->label);
        }
        $title .= ' ' . $mt->translate("ex) 03-1234-5678");
        if ($field->require_hyphen) {
            $title .= ' ' . $mt->translate('(require hyphen)');
        }
    }elseif( $field->type == 'zipcode' ){
        if( $length_msg ){
            $title = $mt->translate("please input [_1] (numeric and hyphen only. [_2].)", array($field->label, $length_msg));
        }else{
            $title = $mt->translate("please input [_1] (numeric and hyphen only.)", $field->label);
        }
        $title .= ' ' . $mt->translate("ex) 123-4567");
        if ($field->require_hyphen) {
            $title .= ' ' . $mt->translate('(require hyphen)');
        }
    }elseif( $field->type == 'url' ){
        if( $length_msg ){
            $title = $mt->translate("please input [_1] (alphabet and numeric only. [_2].)", array($field->label, $length_msg));
        }else{
            $title = $mt->translate("please input [_1] (alphabet and numeric only.)", $field->label);
        }
        $title .= ' ' . $mt->translate("ex) http://www.example.com/");
    }elseif( $field->type == 'privacy' ){
        $title = $mt->translate("please agree to [_1]. put a check to agree.", $field->label);
    }elseif( $field->type == 'upload' ){
        $title = $mt->translate("please choose a file.");
    }elseif( $field->type == 'parameter' ){
        $title = $mt->translate("[_1] is empty", $field->label);
    }elseif( $field->type == 'text' || $field->type == 'textarea' || $field->type == 'password' || $field->type == 'name' ){
        if (empty($label)) {
            $label = $field->label;
        }
        if( $length_msg ){
            $title = $mt->translate("please input [_1] ([_2]).", array($label, $length_msg));
        }else{
            $title = $mt->translate("please input [_1]", $label);
        }
    }elseif( $field->type == 'kana' ){
        if (empty($label)) {
            $label = $field->label;
        }
        if( $length_msg ){
            $title = $mt->translate("please input [_1] ([_2]) in katakana", array($label, $length_msg));
        }else{
            $title = $mt->translate("please input [_1] in katakana", $label);
        }
    }


    return $title;
}

# reserve
function _make_reserve_tag( $field ){
    global $mt;

	require_once(dirname(__FILE__) . '/../../AFormReserve/php/lib/aform_reserve_lib.php');

    if ($_REQUEST['plan_id'] != "") {
      $plan = _get_aform_reserve_plan($_REQUEST['plan_id']);
      if ($plan) {
        $_REQUEST['plan'] = $plan->name;
      }
    }
    elseif ($_REQUEST['plan'] != "") {
      $plan = _get_aform_reserve_plan_by_name($field->aform_id, $_REQUEST['plan']);
      if ($plan) {
        $_REQUEST['plan_id'] = $plan->id;
      }
    }
    if ($_REQUEST['plan_id']) {
      if ($_REQUEST['option_value_id'] != "") {
        $option_value = _get_aform_reserve_option_value($_REQUEST['option_value_id']);
        if ($option_value) {
          $_REQUEST['option_value'] = $option_value->name;
        }
      }
      elseif ($_REQUEST['option_value'] != "") {
        $option_value = _get_aform_reserve_option_value_by_value($_REQUEST['plan_id'], $_REQUEST['option_value']);
        if ($option_value) {
          $_REQUEST['option_value_id'] = $option_value->id;
        }
      }
    }

    if (!empty($_REQUEST['date']) && !empty($_REQUEST['plan'])) {
        $quantity = _get_quantity($_REQUEST['plan'], $_REQUEST['date'], $_REQUEST['option_value'], $field->aform_id);
        if (empty($quantity)) {
            $tag = $mt->translate('There is no remaining quantity.');
            return $tag;
        }
    }

    $use_option = ($plan && $plan->option_name) ? true : false;
    $display_by_hidden = false;
    if( !empty($_REQUEST['date']) && $plan) {
      if ($use_option) {
        if ($option_value) {
          $display_by_hidden = true;
        }
      } else {
        $display_by_hidden = true;
      }
    }

    $tag;
    $required = ($field->is_necessary ? 'required' : '');
    if ($display_by_hidden == false) {
        $data = _get_aform_reservable_data($field->aform_id);
        $tag = '<select 
            class="aform-validate aform-input aform-reserve-date '. $required .' '. $field->parts_id .'" 
            id="'. $field->parts_id .'-date"
            name="aform-field-'. $field->id .'-date"
            '. ($field->is_necessary ? 'required' : '') .'
            title="'. $mt->translate('please select date') .'">';
        $tag .= '<option value="">-</option>';
        foreach( $data as $date => $dmy ){
            $tag .= sprintf('<option value="%s">%s</option>', encode_html($date), encode_html($date));
        }
        $tag .= '</select>';
        $tag .= '<select 
            class="aform-validate aform-input aform-reserve-plan-id '. $required .' '. $field->parts_id .'" 
            id="'. $field->parts_id .'-plan-id"
            name="aform-field-'. $field->id .'-plan-id"
            '. ($field->is_necessary ? 'required' : '') .'
            title="'. $mt->translate('please select plan') .'">';
        $tag .= '<option value="">-</option>';
        $tag .= '</select>';
        $tag .= '<select 
            class="aform-validate aform-input aform-reserve-option-value-id '. $required .' '. $field->parts_id .'" 
            id="'. $field->parts_id .'-option-value-id"
            name="aform-field-'. $field->id .'-option-value-id"
            '. ($field->is_necessary ? 'required' : '') .'
            title="'. $mt->translate('please select option') .'">';
        $tag .= '</select>';
        $tag .= '<script type="text/javascript">
            var aformReserveOptionValues = '. json_encode($data);
        $tag .= '</script>';
    }else{
        $plan = _get_aform_reserve_plan($_REQUEST['plan_id']);
        $option_value = _get_aform_reserve_option_value($_REQUEST['plan_id'], $_REQUEST['option_value_id']);
        $tag = '<div class="aform-validate aform-input aform-reserve '. $required .' '. $field->parts_id .'">';
        $tag .= encode_html($_REQUEST['date'] .' '. $plan->name .' '. $option_value->value);
        $tag .= '</div>';
        $tag .= '<input 
            class="aform-validate aform-input aform-reserve-date '. $required .' '. $field->parts_id .'"
            name="aform-field-'. $field->id .'-date"
            type="hidden"
            value="'. encode_html($_REQUEST['date']) .'" />';
        $tag .= '<input 
            class="aform-validate aform-input aform-reserve-plan-id '. $required .' '. $field->parts_id .'"
            name="aform-field-'. $field->id .'-plan-id"
            type="hidden"
            value="'. encode_html($_REQUEST['plan_id']) .'" />';
        $tag .= '<input 
            class="aform-validate aform-input aform-reserve-option-value-id '. $required .' '. $field->parts_id .'"
            name="aform-field-'. $field->id .'-option-value-id"
            type="hidden"
            value="'. encode_html($_REQUEST['option_value_id']) .'" />';
    }
    return $tag;
}

function _get_aform_reserve_plan( $plan_id ){
    require_once('classes/aform_reserve_plan.class.php');
    $plan_class = new AFormReservePlan;
    $plans = $plan_class->Find("aform_reserve_plan_id = ". (int)$plan_id);
    if( count($plans) ){
        return $plans[0];
    }
    return null;
}

function _get_aform_reserve_plan_by_name($aform_id, $plan_name) {
    require_once('classes/aform_reserve_plan.class.php');
    $plan_class = new AFormReservePlan;
    $plans = $plan_class->Find("aform_reserve_plan_aform_id = '". (int)$aform_id ."' AND aform_reserve_plan_name = '". addslashes($plan_name) ."'");
    if( count($plans) ){
        return $plans[0];
    }
    return null;
}

function _get_aform_reserve_option_value( $plan_id, $option_value_id ){
    require_once('classes/aform_reserve_option_value.class.php');
    $option_value_class = new AFormReserveOptionValue;
    $option_values = $option_value_class->Find("aform_reserve_option_value_plan_id = ". (int)$plan_id ." and aform_reserve_option_value_id = ". (int)$option_value_id);
    if( count($option_values) ){
        return $option_values[0];
    }
    return null;
}

function _get_aform_reserve_option_value_by_value( $plan_id, $option_value_value ){
    require_once('classes/aform_reserve_option_value.class.php');
    $option_value_class = new AFormReserveOptionValue;
    $option_values = $option_value_class->Find("aform_reserve_option_value_plan_id = ". (int)$plan_id ." and aform_reserve_option_value_value = '". addslashes($option_value_value) ."'");
    if( count($option_values) ){
        return $option_values[0];
    }
    return null;
}


function _get_aform_reservable_data($aform_id){
    global $mt;
    $db = $mt->db();

    $res = $db->Execute("
        SELECT DATE(aform_reserve_remaining_quantity_date) as quantity_date,
               aform_reserve_plan_id,
               aform_reserve_plan_name,
               aform_reserve_option_value_id,
               aform_reserve_option_value_value
          FROM mt_aform_reserve_remaining_quantity
        INNER JOIN mt_aform_reserve_plan 
          ON aform_reserve_remaining_quantity_plan_id = aform_reserve_plan_id          AND aform_reserve_plan_aform_id = ". $aform_id ."
        LEFT JOIN mt_aform_reserve_option_value 
          ON aform_reserve_remaining_quantity_option_value_id = aform_reserve_option_value_id
         WHERE aform_reserve_remaining_quantity_quantity > 0
           AND aform_reserve_remaining_quantity_date >= current_date()
         ORDER BY aform_reserve_remaining_quantity_date, aform_reserve_plan_position, aform_reserve_option_value_position");
    $tmp = array();
    while( !$res->EOF ){
        $plan_id = $res->fields['aform_reserve_plan_id'];
        $plan_name = $res->fields['aform_reserve_plan_name'];

        $option_value_id = $res->fields['aform_reserve_option_value_id'];
        $option_value_name = $res->fields['aform_reserve_option_value_value'];

        $date = $res->fields['quantity_date'];

        $tmp[$date][$plan_id]['name'] = $plan_name;
        $tmp[$date][$plan_id]['position'] = $plan_position;
        if (!isset($tmp[$date][$plan_id]['option_values'])) {
            $tmp[$date][$plan_id]['option_values'] = array();
        }
        if ($option_value_id) {
            $tmp[$date][$plan_id]['option_values'][$option_value_id]['name'] = $option_value_name;
            $tmp[$date][$plan_id]['option_values'][$option_value_id]['position'] = $option_value_position;
        }

        $res->MoveNext();
    }

    $data = array();
    foreach ($tmp as $date => $date_data) {
        $plans = array();
        foreach ($date_data as $plan_id => $plan_data) {
            $option_values = array();
            foreach ($plan_data['option_values'] as $option_value_id => $option_value_data) {
                $option_values[] = array('id' => $option_value_id, 'name' => $option_value_data['name']);
            }
            $plans[] = array('id' => $plan_id, 'name' => $plan_data['name'], 'option_values' => $option_values);
        }
        $data[$date] = $plans;
    }

    return $data;
}

function _make_reenter_tag($type, $field, $classes) {
    global $mt;

    $classes[] = 'require-twice aform-validate';
    $tag = '<br />
        <label for="'. encode_html($field->parts_id) .'-confirm" class="aform-twice-note">'. $mt->translate('Please re-enter to confirmation') .'</label>
        <input
        id="'. encode_html($field->parts_id) .'-confirm"
        class="'. encode_html(join(' ', $classes)) .'" 
        name="aform-field-'. encode_html($field->id) .'-confirm" 
        type="'. $type .'" 
        size="40" 
        title="'. encode_html($mt->translate('Please re-enter same value.')) .'"
        '. ($field->max_length ? 'maxlength="'. encode_html($field->max_length) .'"' : '') .' />';
    return $tag;
}


function _make_name_tag($field, $additional_class = null, $value = null) {
    global $mt;

    $classes = array('aform-input', 'aform-'. $field->type, $field->parts_id, 'validate-name', 'aform-validate');
    if( is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->is_necessary ){ $classes[] = 'required'; }
    if( $field->min_length > 0 || $field->max_length > 0 ){ $classes[] = 'validate-length'; }

    list($lastname, $firstname) = explode(" ", $value);

	$pattern = _make_field_pattern($field);

    $title_label = sprintf("%s(%s)", $field->label, $mt->translate('Last name'));
    $tag = '<ul class="aform-name-ul">';
    $tag .= '<li>';
    $tag .= '<label for="'. encode_html($field->parts_id) .'-lastname">'. $mt->translate('Last name') .'</label>
      <input 
        id="'. encode_html($field->parts_id) .'-lastname"
        class="'. encode_html(join(' ', $classes)) .'" 
        name="aform-field-'. encode_html($field->id) .'-lastname" 
        type="text" 
        '. put_attr_value($lastname) .' 
        size="20" 
        title="'. encode_html(_get_tag_title($field, $title_label)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->is_necessary ? 'required' : '') .'
        '. ($field->max_length ? 'maxlength="'. encode_html($field->max_length) .'"' : '') .' />';

    $title_label = sprintf("%s(%s)", $field->label, $mt->translate('First name'));
    $tag .= '<li>';
    $tag .= '<label for="'. encode_html($field->parts_id) .'-firstname">'. $mt->translate('First name') .'</label>
      <input 
        id="'. encode_html($field->parts_id) .'-firstname"
        class="'. encode_html(join(' ', $classes)) .'" 
        name="aform-field-'. encode_html($field->id) .'-firstname" 
        type="text" 
        '. put_attr_value($firstname) .' 
        size="20" 
        title="'. encode_html(_get_tag_title($field, $title_label)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->is_necessary ? 'required' : '') .'
        '. ($field->max_length ? 'maxlength="'. encode_html($field->max_length) .'"' : '') .' />';
    $tag .= '</li>';
    $tag .= '</ul>';
    return $tag;
}


function _make_kana_tag($field, $additional_class = null, $value = null) {
    global $mt;

    $classes = array('aform-input', 'aform-'. $field->type, $field->parts_id, 'validate-name-kana', 'aform-validate');
    if( is_array($additional_class) ){
        $classes = array_merge($classes, $additional_class);
    }
    if( $field->is_necessary ){ $classes[] = 'required'; }
    if( $field->min_length > 0 || $field->max_length > 0 ){ $classes[] = 'validate-length'; }

    list($lastname_kana, $firstname_kana) = explode(" ", $value);

	$pattern = _make_field_pattern($field);

    $title_label = sprintf("%s(%s)", $field->label, $mt->translate('Last name kana'));
    $tag = '<ul class="aform-kana-ul">';
    $tag .= '<li>';
    $tag .= '<label for="'. encode_html($field->parts_id) .'-lastname-kana">'. $mt->translate('Last name(kana)') .'</label>
      <input 
        id="'. encode_html($field->parts_id) .'-lastname-kana"
        class="'. encode_html(join(' ', $classes)) .'" 
        name="aform-field-'. encode_html($field->id) .'-lastname-kana" 
        type="text" 
        '. put_attr_value($lastname_kana) .' 
        size="20" 
        title="'. encode_html(_get_tag_title($field, $title_label)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->is_necessary ? 'required' : '') .'
        '. ($field->max_length ? 'maxlength="'. encode_html($field->max_length) .'"' : '') .' />';
    $tag .= '</li>';

    $title_label = sprintf("%s(%s)", $field->label, $mt->translate('First name kana'));
    $tag .= '<li>';
    $tag .= '<label for="'. encode_html($field->parts_id) .'-firstname">'. $mt->translate('First name(kana)') .'</label>
      <input 
        id="'. encode_html($field->parts_id) .'-firstname-kana"
        class="'. encode_html(join(' ', $classes)) .'" 
        name="aform-field-'. encode_html($field->id) .'-firstname-kana" 
        type="text" 
        '. put_attr_value($firstname_kana) .' 
        size="20" 
        title="'. encode_html(_get_tag_title($field, $title_label)) .'"
        '. ($pattern ? $pattern : '') .'
        '. ($field->is_necessary ? 'required' : '') .'
        '. ($field->max_length ? 'maxlength="'. encode_html($field->max_length) .'"' : '') .' />';
    $tag .= '</li>';
    $tag .= '</ul>';
    return $tag;
}

function _make_field_pattern($field) {
    $chars = '';
    if ($field->only_ascii) {
      $chars = '[\\x21-\\x7E]';
    }
    $length = '';
	if ($field->min_length || $field->max_length) {
        $chars = $chars ? $chars : '.';
		$length = sprintf('{%s,%s}', $field->min_length, $field->max_length);
	}
	$pattern = '';
    if ($chars || $length) {
        $pattern = sprintf('pattern="%s"', htmlspecialchars($chars . $length));
    }
	return $pattern;
}

function put_attr_value($value) {
    return $value != '' ? 'value="'. encode_html($value) .'"' : '';
}
