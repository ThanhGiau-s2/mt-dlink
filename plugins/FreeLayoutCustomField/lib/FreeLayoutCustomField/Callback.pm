package FreeLayoutCustomField::Callback;

use strict;
use warnings;
use MT::Util qw( encode_html encode_js );
use MT::Util::YAML;
use FLCFCommon::Callback qw( create_default_value );
use FLCFCommon::Util qw( load_asset_types check_used_ctrls );
use JSON;

sub edit_field {
    my ($cb, $app, $param, $tmpl) = @_;
    my $plugin = MT->component('FreeLayoutCustomField');
    my $c_plugin = MT->component('FLCFCommon');

    # initialize
    my ($innerHTML, $flcf_def, $flcf_html, $flcf_css,$flcf_init_js, $flcf_js, $flcf_validator);
    if ($app->param('id')) {
        my $id = $app->param('id') + 0;
        my $field = MT->model('field')->load($id);
        die $plugin->translate('Can\'t find customfield.')
            if (!$field);
        $flcf_def     = encode_html($field->flcf_def) || '';
        $flcf_html    = encode_html($field->flcf_html) || '';
        $flcf_css     = encode_html($field->flcf_css) || '';
        $flcf_init_js = encode_html($field->flcf_init_js) || '';
        $flcf_js      = encode_html($field->flcf_js) || '';
        $flcf_validator = encode_html($field->flcf_validator) || '';
        if ($field->type eq 'flcf' && $flcf_def ne '') {
            my $flcf_dec;
            eval {
                $flcf_dec = MT::Util::YAML::Load($flcf_def);
            };
            if ($@) {
                my $err = $plugin->translate('[_1] Field (ID = [_2]) definition YAML parse error. [_3]', $field->name, $field->id, $@);
                my $sysmsg_node;
                my $elements = $tmpl->getElementsByTagName('setvarblock');
                for my $element (@$elements) {
                    if($element->attributes->{name} eq 'system_msg') {
                        $sysmsg_node = $element;
                        last;
                    }
                }
                if ($sysmsg_node) {
                    my $node = $tmpl->createElement('setvarblock', { name => 'system_msg', append => 1 });
                    my $innerHTML = <<HERE;
<mtapp:statusmsg
    id="generic-error"
    class="error"
    can_close="0">
    $err
</mtapp:statusmsg>
HERE
                    $node->innerHTML($innerHTML);
                    $tmpl->insertAfter($node, $sysmsg_node);
                }
            }
        }
    }
    else {
        $flcf_def = '';
        $flcf_html = '';
        $flcf_css = '';
        $flcf_init_js = '';
        $flcf_js = '';
        $flcf_validator = '';
    }

    # field definition field
    my $host = $tmpl->getElementById('required');
    my $def_element = $tmpl->createElement('app:setting');
    $def_element->setAttribute('id', 'flcf_def');
    $def_element->setAttribute('label', $c_plugin->translate('Field definition'));
    $innerHTML = <<HERE;
<textarea name="flcf_def" id="flcf_def" class="form-control text high" rows="10">${flcf_def}</textarea>
HERE
    $def_element->innerHTML($innerHTML);
    $tmpl->insertAfter($def_element, $host);

    # layout html field
    my $html_element = $tmpl->createElement('app:setting');
    $html_element->setAttribute('id', 'flcf_html');
    $html_element->setAttribute('label', $c_plugin->translate('Layout HTML'));
    $innerHTML = <<HERE;
<textarea name="flcf_html" id="flcf_html" class="form-control text high" rows="10">${flcf_html}</textarea>
HERE
    $html_element->innerHTML($innerHTML);
    $tmpl->insertAfter($html_element, $def_element);

    # layout css field
    my $css_element = $tmpl->createElement('app:setting');
    $css_element->setAttribute('id', 'flcf_css');
    $css_element->setAttribute('label', $c_plugin->translate('Layout CSS'));
    $innerHTML = <<HERE;
<textarea name="flcf_css" id="flcf_css" class="form-control text high" rows="10">${flcf_css}</textarea>
HERE
    $css_element->innerHTML($innerHTML);
    $tmpl->insertAfter($css_element, $html_element);

    # custom JS (init) field
    my $js_init_element = $tmpl->createElement('app:setting');
    $js_init_element->setAttribute('id', 'flcf_init_js');
    $js_init_element->setAttribute('label', $c_plugin->translate('Custom JavaScript (for initialize)'));
    $innerHTML = <<HERE;
<textarea name="flcf_init_js" id="flcf_init_js" class="form-control text high" rows="10">${flcf_init_js}</textarea>
HERE
    $js_init_element->innerHTML($innerHTML);
    $tmpl->insertAfter($js_init_element, $css_element);

    # custom JS field
    my $js_element = $tmpl->createElement('app:setting');
    $js_element->setAttribute('id', 'flcf_js');
    $js_element->setAttribute('label', $c_plugin->translate('Custom JavaScript'));
    $innerHTML = <<HERE;
<textarea name="flcf_js" id="flcf_js" class="form-control text high" rows="10">${flcf_js}</textarea>
HERE
    $js_element->innerHTML($innerHTML);
    $tmpl->insertAfter($js_element, $js_init_element);

    # validator field
    my $v_element = $tmpl->createElement('app:setting');
    $v_element->setAttribute('id', 'flcf_validator');
    $v_element->setAttribute('label', $c_plugin->translate('Validator'));
    $innerHTML = <<HERE;
<textarea name="flcf_validator" id="flcf_validator" class="form-control text high" rows="10">${flcf_validator}</textarea>
HERE
    $v_element->innerHTML($innerHTML);
    $tmpl->insertAfter($v_element, $js_element);

    # add js
    my $incl_node;
    my $elements = $tmpl->getElementsByTagName('include');
    for my $element (@$elements) {
        if($element->attributes->{name} eq 'layout/default.tmpl') {
            $incl_node = $element;
            last;
        }
    }
    if ($incl_node) {
        my $node = $tmpl->createElement('setvarblock', { name => 'jq_js_include', append => 1 });
        $innerHTML = <<HERE;
jQuery('#type').on('change', function() {
  flcf_change_type();
});
setTimeout(flcf_change_type, 500);

function flcf_change_type() {
  var type = jQuery('#type').val();
  if (type == 'flcf') {
    jQuery('#flcf_def-field, #flcf_html-field, #flcf_css-field, #flcf_init_js-field, #flcf_js-field, #flcf_validator-field').show();
    jQuery('#default-field').hide();
  }
  else {
    jQuery('#flcf_def-field, #flcf_html-field, #flcf_css-field, #flcf_init_js-field, #flcf_js-field, #flcf_validator-field').hide();
  }
}
HERE
        $node->innerHTML($innerHTML);
        $tmpl->insertBefore($node, $incl_node);
    }

}

sub edit_entry {
    my ($cb, $app, $param, $tmpl) = @_;
    my $plugin = MT->component('FreeLayoutCustomField');

=for comment
    my $incl_node = $tmpl->getElementById('footer_include');
    if ($incl_node) {
        my $node = $tmpl->createElement('setvarblock', { name => 'jq_js_include', append => 1 });
        my $innerHTML = <<HERE;
setTimeout(function() {
  jQuery('.flcf input[type="text"]').removeClass('text');
}, 100);
HERE
        $node->innerHTML($innerHTML);
        $tmpl->insertBefore($node, $incl_node);
    }
=cut

    my $req = MT->request;
    if ($req->stash('FreeLayoutCustomField::EntryFilterError')) {
        my $node = $tmpl->getElementById('generic-error');
        my $children = $node->childNodes;
        for my $child (@$children) {
            if (lc($child->[0]) eq 'var') {
                delete $child->[1]->{escape};
                last;
            }
        }
    }
}

sub add_header {
    my ($cb, $app, $param, $tmpl) = @_;
    my $plugin = MT->component('FreeLayoutCustomField');

    my $blog_id = $app->param('blog_id') || 0;
    my $static_uri = encode_js($param->{static_uri});
    my $mt_url = encode_js($param->{mt_url});

    # check mode and form name
    my $mode = $app->param('__mode') || '';
    my $type = $app->param('_type') || '';
    my $form_names = $app->registry('flcf_form_names');
    if ($mode eq 'view') {
        if ($type ne 'website') {
            return unless (defined($form_names->{$type}));
        }
    }
    elsif ($mode eq 'save_entry' || $mode eq 'save') {
        return unless (defined($form_names->{$app->param('_type')}));
    }
    elsif ($mode ne 'cfg_prefs') {
        return;
    }

    # search <mt:var name="html_head">
    my $elements = $tmpl->getElementsByTagName('var');
    my ($css_node, $js_node);
    for my $element (@$elements) {
        if ($element->attributes->{name} eq 'css_include') {
            $css_node = $element;
        }
        if ($element->attributes->{name} eq 'js_include') {
            $js_node = $element;
        }
    }

    my $req = MT->request;
    my $cb_used_ctrls = $req->stash('FreeLayoutCustomField::JS_USED_CTRLS') || {};
    my $cb_field_defs = $req->stash('FreeLayoutCustomField::FIELD_DEFS') || {};

    if ($css_node) {
        my $node = $tmpl->createElement('setvarblock', { name => 'css_include', append => 1 });
        my $req = MT->request;
        my $append_css = $req->stash('FreeLayoutCustomField::CSS') || '';
        my $css_ext = MT->config->DebugMode ? 'css' : 'min.css';
        my $innerHTML = <<HERE;
<link rel="stylesheet" href="<mt:var name="static_uri">plugins/FLCFCommon/css/jquery-ui.min.css" type="text/css" />
<link rel="stylesheet" href="<mt:var name="static_uri">plugins/FLCFCommon/css/flcf.${css_ext}" type="text/css" />
$append_css
HERE
        my $ex_csses = $app->registry('flcf_ext_css');
        for my $ex_css (@$ex_csses) {
            if (ref $ex_css ne 'CODE') {
                $ex_css = $app->handler_to_coderef($ex_css);
            }
            $innerHTML .= $ex_css->($cb_used_ctrls, $cb_field_defs);
#            if (ref $ex_css ne 'ARRAY') {
#                $ex_css = [ $ex_css ];
#            }
#            for my $css (@$ex_css) {
#                $innerHTML .= <<HERE;
#<link rel="stylesheet" href="<mt:var name="static_uri">plugins/${css}" type="text/css" />
#HERE
#            }
        }

        $node->innerHTML($innerHTML);
        $tmpl->insertBefore($node, $css_node);
    }

    if ($js_node) {
        my $node = $tmpl->createElement('setvarblock', { name => 'js_include', append => 1 });
        my %asset_types = load_asset_types();
        my $asset_types = to_json(\%asset_types);
        my $field_names = to_json($req->stash('FreeLayoutCustomField::FIELD_NAMES') || {});
        my $unit_names = to_json($req->stash('FreeLayoutCustomField::UNIT_NAMES') || {});
        my $field_options = to_json($req->stash('FreeLayoutCustomField::FIELD_OPTIONS') || {});
        my $field_defs = to_json($req->stash('FreeLayoutCustomField::FIELD_DEFS') || {});
        my $unit_groups = to_json($req->stash('FreeLayoutCustomField::UNIT_GROUPS') || {});
        my $unit_defs = to_json($req->stash('FreeLayoutCustomField::UNIT_DEFS') || {});
        my $used_ctrls = to_json($req->stash('FreeLayoutCustomField::USED_CTRLS') || {});
        my $unused_ctrls = to_json($req->stash('FreeLayoutCustomField::UNUSED_CTRLS') || {});
        my $tabs = to_json($req->stash('FreeLayoutCustomField::Tab') || {});
        my $accs = to_json($req->stash('FreeLayoutCustomField::Accordion') || {});
        my $norms = to_json($req->stash('FreeLayoutCustomField::Normal') || {});
        my $js_tmpl = $req->stash('FreeLayoutCustomField::JS_TMPL' || {});
        my $next_num = $req->stash('FreeLayoutCustomField::NEXT_NUM' || {});
        my $group_labels = $req->stash('FreeLayoutCustomField::GROUP_LABELS' || {});
        my $delete_labels = $req->stash('FreeLayoutCustomField::DELETE_LABELS' || {});
        my $field_unit_names = $req->stash('FreeLayoutCustomField::FIELD_UNIT_NAMES' || {});
        my $used_flcf_types = $req->stash('FreeLayoutCustomField::USED_FLCF_TYPES' || {});
        my $unit_change_msg1_en = 'If you change unit group, all data in this customfield will be lost.';
        my $unit_change_msg1 = $plugin->translate($unit_change_msg1_en);
        my $unit_change_msg2_en = 'Are you ok ?';
        my $unit_change_msg2 = $plugin->translate($unit_change_msg2_en);
        my $delete_group_msg_en = 'Delete [_1] ?';
        my $delete_group_msg = $plugin->translate($delete_group_msg_en);
        $delete_group_msg =~ s/\{\{/[/;
        $delete_group_msg =~ s/\}\}/]/;
        my $open_all_msg_en = 'Open all fields';
        my $open_all_msg = $plugin->translate($open_all_msg_en);
        my $fold_all_msg_en = 'Fold all fields';
        my $fold_all_msg = $plugin->translate($fold_all_msg_en);

        my $js_ext = MT->config->DebugMode ? 'js' : 'min.js';
        my $innerHTML = <<HERE;
<script type="text/javascript" src="<mt:var name="static_uri">plugins/FLCFCommon/js/flcf.${js_ext}"></script>
HERE
        my $ex_jss = $app->registry('flcf_ext_js');
        for my $ex_js (@$ex_jss) {
            if (ref $ex_js ne 'CODE') {
                $ex_js = $app->handler_to_coderef($ex_js);
            }
            $innerHTML .= $ex_js->($cb_used_ctrls, $cb_field_defs);
#            if (ref $ex_js ne 'ARRAY') {
#                $ex_js = [ $ex_js ];
#            }
#            for my $js (@$ex_js) {
#                $innerHTML .= <<HERE;
#<script type="text/javascript" src="<mt:var name="static_uri">plugins/${js}"></script>
#HERE
#            }
        }
        if ($req->stash('FreeLayoutCustomField::IS_USE_ASSET')) {
            my $ext = MT->config->DebugMode ? 'js' : 'min.js';
            $innerHTML .= <<HERE;
<script type="text/javascript" src="<mt:var name="static_uri">plugins/FLCFCommon/js/asset.${ext}"></script>
HERE
}

        my $day_names = MT->translate('_LOCALE_CALENDAR_HEADER_');
        my $user_lang = $app->user->preferred_language;
        $innerHTML .= <<HERE;
<script type="text/javascript">
Lexicon['${unit_change_msg1_en}'] = '${unit_change_msg1}';
Lexicon['${unit_change_msg2_en}'] = '${unit_change_msg2}';
Lexicon['${delete_group_msg_en}'] = '${delete_group_msg}';
Lexicon['${open_all_msg_en}'] = '${open_all_msg}';
Lexicon['${fold_all_msg_en}'] = '${fold_all_msg}';

FLCFCommon.blog_id = ${blog_id};
FLCFCommon.static_uri = '${static_uri}';
FLCFCommon.mt_url = '${mt_url}';
FLCFCommon.asset_types = ${asset_types};
FLCFCommon.day_names = [ ${day_names} ];
FLCFCommon.fields = ${field_names};
FLCFCommon.field_defs = ${field_defs};
FLCFCommon.field_options = ${field_options};
FLCFCommon.units = ${unit_names};
FLCFCommon.unit_groups = ${unit_groups};
FLCFCommon.unit_defs = ${unit_defs};
FLCFCommon.unused_ctrls = ${unused_ctrls};
FLCFCommon.used_ctrls = ${used_ctrls};
FLCFCommon.tabs = ${tabs};
FLCFCommon.accordions = ${accs};
FLCFCommon.normals = ${norms};
FLCFCommon.language = '${user_lang}';
HERE
        for my $field_name (keys %$js_tmpl) {
            if (ref $js_tmpl->{$field_name} eq 'HASH') {
                $innerHTML .= <<HERE;
FLCFCommon.templates['$field_name'] = {};
HERE
                for my $key (keys %{$js_tmpl->{$field_name}}) {
                    my $t = encode_js($js_tmpl->{$field_name}->{$key});
                    $innerHTML .= <<HERE;
FLCFCommon.templates['$field_name']['$key'] = '$t';
HERE
                }
            }
            else {
                my $t = encode_js($js_tmpl->{$field_name});
                $innerHTML .= <<HERE;
FLCFCommon.templates['$field_name'] = '$t';
HERE
            }
            my $n = $next_num->{$field_name};
            my $g = encode_js($group_labels->{$field_name});
            my $d = encode_js($delete_labels->{$field_name});
            $innerHTML .= <<HERE;
FLCFCommon.next_num['$field_name'] = $n;
FLCFCommon.group_labels['$field_name'] = '$g';
FLCFCommon.delete_labels['$field_name'] = '$d';

HERE
        }

        for my $key (keys %$field_unit_names) {
            my $value = encode_js($field_unit_names->{$key});
            $innerHTML .= <<HERE;
FLCFCommon.field_unit_names['$key'] = '$value';
HERE
        }

        if (scalar(keys %$used_flcf_types)) {
            my $flcf_types = MT->registry('flcf_types');
            my $js_set_values = {};
            for my $t_name (keys %$used_flcf_types) {
                my $flcf_type = $flcf_types->{$t_name};
                # add js set values
                if ($flcf_type->{js_set_value}) {
                    $js_set_values->{$t_name} = 1;
                }
            }
            $js_set_values = to_json($js_set_values);
            $innerHTML .= <<HERE;
FLCFCommon.js_set_values = $js_set_values;
HERE
        }

        $innerHTML .= <<HERE;
</script>

HERE
        my $append_init_js = $req->stash('FreeLayoutCustomField::CUSTOM_INIT_JS') || '';
        $innerHTML .= $append_init_js;


        $node->innerHTML($innerHTML);
        $tmpl->insertBefore($node, $js_node);
    }
}

sub add_footer {
    my ($cb, $app, $param, $tmpl) = @_;
    my $plugin = MT->component('FreeLayoutCustomField');
    my $req = MT->request;

    # check mode and form name
    my $mode = $app->param('__mode') || '';
    my $form_names = $app->registry('flcf_form_names');
    my $type = $app->param('_type') || '';
    my $form_name;
    if ($mode eq 'view') {
        if ($type ne 'website') {
            $form_name = $form_names->{$type};
            return unless $form_name;
        }
        else {
            $form_name = "jQuery('#new_website_form')";
        }
    }
    elsif ($mode eq 'save_entry' || $mode eq 'save') {
        return unless (defined($form_names->{$type}));
        $form_name = $form_names->{$type};
    }
    elsif ($mode ne 'cfg_prefs') {
        return;
    }
    else {
        $form_name = "jQuery('#cfg_form')";
    }

    # search <mt:var name="jq_js_include">
    my $elements = $tmpl->getElementsByTagName('var');
    my $host_node;
    for my $element (@$elements) {
        if ($element->attributes->{name} eq 'jq_js_include') {
            $host_node = $element;
            last;
        }
    }
    if ($host_node) {
        my $node = $tmpl->createElement('setvarblock', { name => 'jq_js_include', append => 1 });
        my $innerHTML = '';

        # add flcfex javascript
        my $flcf_types = $app->registry('flcf_types');
        my $used_flcf_types = $req->stash('FreeLayoutCustomField::USED_FLCF_TYPES') || {};
        for my $flcf_type (keys %$used_flcf_types) {
            my $ext_pre_init_js = $flcf_types->{$flcf_type}->{pre_init_js};
            if ($ext_pre_init_js) {
                $innerHTML .= $ext_pre_init_js->();
            }
        }

        # set fields
        $innerHTML .= <<HERE;
jQuery.each(FLCFCommon.group_labels, function(field_name) {
    FLCFCommon.renewValue(field_name);
});
jQuery.each(FLCFCommon.field_unit_names, function(field_name, unit_name) {
    var sel_elm = jQuery('#' + field_name).find('select.flcf-change-unit');
    if (sel_elm.length) {
        sel_elm.val(unit_name);
        sel_elm.on('change', FLCFCommon.changeUnit);
    }
});
HERE

        $innerHTML .= <<HERE;
${form_name}.on('submit', FLCFCommon.fieldsToJSON);
${form_name}.append('<input type="hidden" name="flcf_reedit" id="flcf_reedit" value="1">');
${form_name}.append('<input type="hidden" name="flcf_unused_ctrls" id="flcf_unused_ctrls">');
${form_name}.append('<input type="hidden" name="flcf_used_ctrls" id="flcf_used_ctrls">');
jQuery('#flcf_unused_ctrls').val(jQuery.toJSON(FLCFCommon.unused_ctrls));
jQuery('#flcf_used_ctrls').val(jQuery.toJSON(FLCFCommon.used_ctrls));
jQuery('.flcf_add_button button.flcf-add-one').on('click', FLCFCommon.addGroup);
jQuery('.flcf_add_button button.flcf-add-group').on('click', FLCFCommon.addUnitGroup);
jQuery('.flcf_add_button button.flcf-change-group').on('click', FLCFCommon.changeUnitGroup);
HERE

        my $sortable = $req->stash('FreeLayoutCustomField::Sortable');
        my @field_names_a = map { '#' . $_ . '_flcfg' } @$sortable;
        my $field_names = join ',', @field_names_a;
        if ($field_names) {
            $innerHTML .= <<HERE;
FLCFCommon.setSortable('${field_names}');
HERE
        }

        my $float = $req->stash('FreeLayoutCustomField::Float');
        @field_names_a = map { '#' . $_ . '_flcfg' } @$float;
        $field_names = join ',', @field_names_a;
        if ($field_names) {
                $innerHTML .= <<HERE;
FLCFCommon.setFloat('${field_names}');
HERE
        }

        my $custom_js = $req->stash('FreeLayoutCustomField::CUSTOM_JS') || '';
        $innerHTML .= $custom_js;
        $innerHTML .= <<HERE;
FLCFCommon.initFields();
setTimeout(function() {
  jQuery('.flcf input[type="text"]').removeClass('text');
}, 100);
HERE
=for comment
        $innerHTML .= <<HERE;
setTimeout(function() {
  var fields = jQuery('.field');
  jQuery.each(fields, function() {
    var cf_field = jQuery(this);
    var cf_id = cf_field.prop('id');
    var cf_m = cf_id.match(/^(customfield_.*?)-field\$/);
    if (cf_m && FLCFCommon.field_defs[cf_m[1]]) {
      var value = jQuery('#' + cf_m[1]).val();
      value = jQuery.parseJSON(value);
      jQuery.each(cf_field.find('.flcf-block'), function() {
        var d = jQuery(this);
        var id = d.prop('id');
        var matches = id.match(/^(customfield_.*?)_flcfg(\\d+)\$/);
        var cf_name = matches[1];
        var group_no = matches[2];
        var unit_name;
        var unit_sel = d.find('select.flcf-change-unit');
        if (unit_sel) {
          unit_name = unit_sel.val();
        }
        FLCFCommon.post_add_callback(cf_name, group_no);
        // set tabs and accordions
        FLCFCommon.setTabsAndAccordions(d);
        // js set value to field
        jQuery.each(FLCFCommon.field_defs[cf_name], function(field_name, f_def) {
          var f_type = FLCFCommon.field_defs[cf_name][field_name].type;
          if (FLCFCommon.js_set_values[f_type]) {
            FLCFCommon.callbacks[f_type].set_value(cf_name, group_no, field_name, value[group_no - 1][field_name]);
          }
        });
        jQuery(this).trigger('flcf_add', unit_name);
      });
    }
  });
}, 100);
HERE
=cut

        my $unit_defaults = $req->stash('FreeLayoutCustomField::UNIT_DEFAULTS') || {};
        for my $unit_fname (keys %$unit_defaults) {
            my $unit_default = $unit_defaults->{$unit_fname};
            my $uf = encode_js($unit_fname);
            my $ud = encode_js($unit_default);
            $innerHTML .= <<HERE;
setTimeout(function() {
  jQuery('#${uf}-field .flcf').trigger('flcf_add_unit_group', '${ud}');
}, 100);
HERE
        }
        $innerHTML .= <<HERE;
jQuery('#sortable').on('sortstop', FLCFCommon.renewAccordionHeight);
HERE
        $node->innerHTML($innerHTML);
        $tmpl->insertBefore($node, $host_node);
    }
}

sub pre_save_field {
    my ($eh, $app, $field, $old_field) = @_;

    # set field value
    $field->flcf_def($app->param('flcf_def') || '');
    $field->flcf_html($app->param('flcf_html') || '');
    $field->flcf_css($app->param('flcf_css') || '');
    $field->flcf_init_js($app->param('flcf_init_js') || '');
    $field->flcf_js($app->param('flcf_js') || '');
    if ($field->type eq 'flcf') {
        check_used_ctrls($field, 1);
    }
    else {
        $field->flcf_used_ctrls('');
        $field->flcf_unused_ctrls('');
    }
    return 1 if ($field->type ne 'flcf');

    # set default value
    $field->default(create_default_value($field->flcf_def));

    return 1;
}

1;
