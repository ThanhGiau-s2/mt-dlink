<?php
require_once('classes/aform.class.php');
require_once('classes/aform_field.class.php');
require_once('classes/aform_data.class.php');


function _get_tmpl_file_path( $plugin_path, $aform_id, $filename ) {
    $plugin_tmpl_dir = $plugin_path . '/AForm/tmpl/';
    $tmpl = sprintf("%s%03d/%s", $plugin_tmpl_dir, $aform_id, $filename);
    if( ! file_exists($tmpl) ){
        // use default template if custom template not exists
        $tmpl = $plugin_tmpl_dir . $filename;
    }
    return $tmpl;
}


function _get_fields( $aform_id ) {

    $aform_field_class = new AformField();
    $ary_aform_fields = $aform_field_class->Find("aform_field_aform_id = " . $aform_id . " order by aform_field_sort_order");

    $fields = array();
    foreach( $ary_aform_fields as $aform_field ){
        $param = array(
          id => $aform_field->id,
          type => $aform_field->type,
          label => $aform_field->label,
          is_necessary =>  $aform_field->is_necessary,
          options => $aform_field->options,
          use_default => $aform_field->use_default,
          default_label => $aform_field->default_label,
          privacy_link => $aform_field->privacy_link,
          is_replyed => $aform_field->is_replyed,
          only_ascii => $aform_field->only_ascii,
          allow_ascii_chars => $aform_field->allow_ascii_chars,
          input_example => $aform_field->input_example,
          max_length => $aform_field->max_length,
          upload_type => $aform_field->upload_type,
          upload_size => $aform_field->upload_size,
          upload_size_numeric => $aform_field->upload_size_numeric,
          parameter_name => $aform_field->parameter_name,
          show_parameter => $aform_field->show_parameter,
          parts_id => $aform_field->parts_id,
          use_ajaxzip => $aform_field->use_ajaxzip,
          ajaxzip_prefecture_parts_id => $aform_field->ajaxzip_prefecture_parts_id,
          ajaxzip_city_parts_id => $aform_field->ajaxzip_city_parts_id,
          ajaxzip_area_parts_id => $aform_field->ajaxzip_area_parts_id,
          ajaxzip_street_parts_id => $aform_field->ajaxzip_street_parts_id,
          next_text => $aform_field->next_text,
        );
        if( $aform_field->type == 'parameter' ){
          $param['parameter_value'] = $_REQUEST[$aform_field->parameter_name];
        }
        array_push($fields, $param);
    }
    return $fields;
}


function _get_script_url_dir() {
    global $mt;

    $plugin_config = $mt->db()->fetch_plugin_config('A-Form');
    $script_url_dir = $plugin_config['script_url_dir'];
    if( !preg_match("#\/$#", $script_url_dir) ){
        $script_url_dir .= '/';
    }
    if( ! _url_check($script_url_dir) ){
        $script_url_dir = $mt->config('cgipath') . 'plugins/AForm/';
        $script_url_dir = preg_replace('#https?://[^:/]+(:\d+)?#', '', $script_url_dir);
    }
    return $script_url_dir;
}

function _get_cgi_path() {
    global $mt;

    $path = $mt->config('CGIPath');
    if (substr($path, strlen($path) - 1, 1) != '/')
        $path .= '/';
    return $path;
}

function _get_static_uri() {
    global $mt;

    $path = $mt->config('staticwebpath');
    if (!$path) {
        $path .= _get_cgi_path() . 'mt-static/';
    }
    $path = preg_replace('#https?://[^:/]+(:\d+)?#', '', $path);
    if (substr($path, strlen($path) - 1, 1) != '/')
        $path .= '/';
    return $path;
}

function _get_plugin_static_uri() {
    $path = _get_static_uri() . 'plugins/AForm/';
    return $path;
}

function _url_check( $url ) {
    # http:// or https://
    return preg_match("#^https?://[^/].*#i", $url);
}

function is_business() {
    global $mt;

    $plugin_paths = $mt->config('PluginPath');
    $key_file = $plugin_paths[0] . '/AForm/key/aform_nonprofitkey.txt';
    if( file_exists($key_file) ){
        return 0;
    }else{
        return 1;
    }
}

function aform_callback($name, $args) {
    global $aform_callbacks;

    if( is_array($aform_callbacks) && is_array($aform_callbacks[$name]) ){
        foreach( $aform_callbacks[$name] as $callback ){
            $callback($args);
        }
    }
}

function _require_ajaxzip($fields) {
    foreach ($fields as $field) {
        if ($field['type'] == 'zipcode' && $field['use_ajaxzip']) {
            return true;
        }
    }
    return false;
}

function _get_aform_field_by_parts_id($aform_id, $parts_id) {
    $field_class = new AFormField();
    $fields = $field_class->Find("aform_field_aform_id=".$aform_id." AND aform_field_parts_id='".$parts_id."'");
    if( empty($fields) ){
         return null;
    }else{
         return $fields[0];
    }
}

function aform_payment_path() {
    global $mt;

    $plugin_paths = $mt->config('PluginPath');
    return $plugin_paths[0]. '/AFormPayment/';
}

function aform_payment_installed() {
    return file_exists(aform_payment_path());
}
?>
