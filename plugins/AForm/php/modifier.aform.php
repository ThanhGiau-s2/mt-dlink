<?php
require_once('classes/aform.class.php');
require_once('classes/aform_field.class.php');
require_once('classes/aform_data.class.php');
require_once('lib/aform_lib.php');


function smarty_modifier_aform( $entry_text ) {
    $entry_text = _replace_form($entry_text, '<\!--', '-->');
    $entry_text = _replace_form($entry_text, '\[\[', '\]\]');

    return $entry_text;
}


function _replace_form( $entry_text, $pattern_pre, $pattern_post ) {
    global $mt;
    $ctx =& $mt->context();
    $blog = $ctx->stash('blog');

    preg_match_all("/${pattern_pre}aform(\d+)${pattern_post}/", $entry_text, $matches);
    foreach ( $matches[1] as $match_no ){
        $aform_id = (int)$match_no;

        # get aform
        $aform_class = new Aform();
        $aforms = $aform_class->Find("aform_id = " . $aform_id);
        if( empty($aforms) ){
            $entry_text = preg_replace("/${pattern_pre}aform${match_no}${pattern_post}/i", "", $entry_text);
            continue;
        }
        $aform = $aforms[0];
        if ($aform->lang != "" && $aform->lang != "en_us") {
            require_once("lib/l10n_". $aform->lang .".php");
        } else {
            require_once("lib/l10n_en.php");
        }

        if( $aform->blog_id && $aform->blog_id != $blog->id ){
            $entry_text = preg_replace("/${pattern_pre}aform${match_no}${pattern_post}/i", $mt->translate('The Form [_1] does not have permission for Blog [_2].', array(sprintf("%03d",$aform_id), $blog->name)), $entry_text);
            continue;
        }

        # generate form
        $buf = _generate_form_view($aform);

        # replace
        $entry_text = preg_replace("/${pattern_pre}aform${match_no}${pattern_post}/i", $buf, $entry_text);
    }
    return $entry_text;
}


function _generate_form_view( $aform ) {

    global $mt;
    $ctx =& $mt->context();

    if( $aform->status != 2 ){	# published
      return '';
    }

    list( $status, $message ) = check_aform_is_active($aform);

    # get plugin path
    $plugin_paths = $mt->config('PluginPath');
    if( count($plugin_paths) == 0 ){
        return '';
    }

    $static_uri = _get_static_uri();

    # get script url dir
    $script_url_dir = _get_script_url_dir();

    $plugin_config = $mt->db()->fetch_plugin_config('A-Form');
    $for_business = is_business();
    $checked_sn = (int)$plugin_config['checked_sn'];
    $parsed_url = parse_url($ctx->tag('EntryPermalink'));
    $fields = _get_fields($aform->id);
    $recaptcha_site_key = $plugin_config['recaptcha_site_key'];
    $pages = _get_page_info($fields);
    $count_page = count($pages);

    # set vars
    $vars =& $ctx->__stash['vars'];
    $vars['blog_id'] = $ctx->stash('blog_id');
    $vars['id'] = $aform->id;
    $vars['title'] = $aform->title;
    $vars['fields'] = $fields;
    $vars['action_url'] = $script_url_dir . 'aform_engine.cgi';
    $vars['logger_url'] = $script_url_dir . 'aform_logger.cgi';
    $vars['checker_url'] = $script_url_dir . 'aform_checker.cgi';
    $vars['upload_script_url'] = $script_url_dir . 'aform_uploader.cgi';
    $vars['aform_url'] = $ctx->tag('EntryPermalink');
    $vars['aform_path'] = $parsed_url['path'];
    $vars['charset'] = strtoupper($mt->config('publishcharset'));
    $vars['preview'] = 0;
    $vars['static_uri'] = $static_uri;
    $vars['aform_is_active'] = $status;
    $vars['aform_message'] = $message;
    $vars['hide_demo_warning'] = (!$for_business || $checked_sn);
    $vars['hide_powered_by'] = ($for_business || $checked_sn);
    $vars['check_immediate'] = $aform->check_immediate;
    $vars['hidden_params'] = "";
    $vars['entry_id'] = $ctx->tag('EntryID');
    $vars['require_ajaxzip'] = _require_ajaxzip($fields);
    $vars['is_installed_mtml'] = class_exists('DynamicMTML');
    $vars['aform_lang'] = $aform->lang;
    $vars['enable_recaptcha'] = $aform->enable_recaptcha;
    $vars['recaptcha_site_key'] = $recaptcha_site_key;
    $vars['aform_pages'] = json_encode($pages);
    $vars['aform_page_max'] = $count_page;

    aform_callback('aform_before_build_form_view', array('ctx' => $ctx, 'aform' => $aform));

    $tmp_caching = $ctx->caching;
    $ctx->caching = false;
    $html = $ctx->fetch('file:' . _get_tmpl_file_path($plugin_paths[0], $aform->id, 'aform_form.tmpl'));
    $html = $mt->translate_templatized($html);
    $ctx->caching = $tmp_caching;
    return $html;
}

function check_aform_is_active($aform) {
  global $mt;

  $aform->set_auto_status(0);
  $status = 'closed';
  $message = '';
  if( $aform->status == 2 ){
    $status = 'published';
    $start_at = $mt->db()->db2ts($aform->start_at);
    $end_at = $mt->db()->db2ts($aform->end_at);
	if( $start_at == '19700101000000' ){
		$start_at = '00000000000000';
	}
	if( $end_at == '19700101000000' ){
		$end_at = '00000000000000';
	}
    if( $start_at > 0 || $end_at > 0 || $aform->receive_limit > 0 ){
      if( $start_at > 0 && $start_at > date('YmdHis') ){
        $status = 'before start';
        $message = $aform->msg_before_start;
      }elseif( $end_at > 0 && $end_at < date('YmdHis') ){
        $status = 'after end';
        $message = $aform->msg_after_end;
      }elseif( $aform->receive_limit > 0 ){
        $aform_data_class = new AformData();
        $received_count = $aform_data_class->count(array("where" => "aform_data_aform_id = ". (int)$aform->id));
        if( $received_count >= $aform->receive_limit ){
          $status = 'limit over';
          $message = $aform->msg_limit_over;
        }
      }else{
        $status = 'published';
        $aform->set_auto_status(1);
      }
    }else{
      $status = 'published';
      $aform->set_auto_status(1);
    }
  }
  return array($status, $message);
}

function _get_page_info($fields) {
  $pages = array();
  $current_page = 1;
  $parts_ids = array();
  foreach ($fields as $field) {
    if ($field['type'] == 'label' || $field['type'] == 'note') {
      continue;
    }
    if ($field['type'] == 'pagebreak') {
      $my_parts_ids = $parts_ids;
      $pages[] = array(
        'prev' => ($current_page > 1) ? array(
                'btn' => sprintf('aform_button_prev_%0d', $current_page),
                'page' => sprintf('aform_page_%0d', $current_page - 1),
            ) : null,
        'next' => array(
                'btn' => sprintf('aform_button_next_%0d', $current_page),
                'page' => sprintf('aform_page_%0d', $current_page + 1),
            ),
        'parts_ids' => $my_parts_ids,
      );
      $current_page++;
      $parts_ids = array();
    } else {
      $parts_ids[] = $field['parts_id'];
    }
  }

  $pages[] = array(
    'prev' => ($current_page > 1) ? array(
            'btn' => sprintf('aform_button_prev_%0d', $current_page),
            'page' => sprintf('aform_page_%0d', $current_page - 1),
        ) : null,
    'next' => null,
    'parts_ids' => $parts_ids,
  );

  return $pages;
}

?>
