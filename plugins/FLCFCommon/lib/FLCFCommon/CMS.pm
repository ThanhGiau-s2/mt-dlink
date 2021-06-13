package FLCFCommon::CMS;

use strict;
use warnings;
use base qw( Exporter );

use MT::Util qw ( encode_html encode_js remove_html deep_copy );
use FLCFCommon::Util qw( load_asset_types );
use JSON;

our @EXPORT_OK = qw( flcf_types field_html_params_common );

sub flcf_types {
    my $types = {
        text => {
            html => qq{
<input type="text" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="<mt:var name="value" encode_html="1">"<mt:if name="class"> class="<mt:var name="class">"</mt:if><mt:if name="placeholder"> placeholder="<mt:var name="placeholder" encode_html="1">"</mt:if><mt:if name="pattern"> pattern="<mt:var name="pattern" encode_html="1">"</mt:if><mt:if name="minlength"> minlength="<mt:var name="minlength" encode_html="1">"</mt:if><mt:if name="maxlength"> maxlength="<mt:var name="maxlength" encode_html="1">"</mt:if> />
            }
        },
        textarea => {
            html => qq{
<textarea name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">"<mt:if name="class"> class="<mt:var name="class">"</mt:if><mt:if name="placeholder"> placeholder="<mt:var name="placeholder" encode_html="1">"</mt:if><mt:if name="minlength"> minlength="<mt:var name="minlength" encode_html="1">"</mt:if><mt:if name="maxlength"> maxlength="<mt:var name="maxlength" encode_html="1">"</mt:if>><mt:var name="value" encode_html="1"></textarea>
            }
        },
        checkbox => {
            html => qq{
<input type="checkbox" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="1"<mt:if name="value"> checked="checked"</mt:if><mt:if name="class"> class="<mt:var name="class">"</mt:if> />
            }
        },
        radio => {
            html => qq{
<ul class="flcf-radio-list">
<mt:getvar name="value" setvar="c_value">
<mt:loop name="options">
    <li><input type="radio" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">r<mt:var name="__counter__">" value="<mt:var name="value" encode_html="1">"<mt:if name="value" eq="\$c_value"> checked="checked"</mt:if><mt:if name="class"> class="<mt:var name="class">"</mt:if>> <label for="<mt:var name="id" encode_html="1">r<mt:var name="__counter__">"><mt:var name="label"></label></li>
</mt:loop>
</ul>
            }
        },
        select => {
            html => qq{
<select name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">"<mt:if name="class"> class="<mt:var name="class">"</mt:if>>
<mt:getvar name="value" setvar="c_value">
<mt:loop name="options">
    <option value="<mt:var name="value" encode_html="1">"<mt:if name="value" eq="\$c_value"> selected="selected"</mt:if>><mt:var name="label"></option>
</mt:loop>
</select>
            }
        },
        optgroup => {
            html => qq{
<select name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">"<mt:if name="class"> class="<mt:var name="class">"</mt:if>>
<mt:getvar name="value" setvar="c_value">
<mt:loop name="options">
    <mt:if name="group_first">
        <optgroup label="<mt:var name="group" encode_html="1">">
    </mt:if>
        <option value="<mt:var name="value" encode_html="1">"<mt:if name="value" eq="\$c_value"> selected="selected"</mt:if>><mt:var name="label"></option>
    <mt:if name="group_last">
        </optgroup>
    </mt:if>
</mt:loop>
</select>
            }
        },
        datetime => {
            html => qq{
<input type="hidden" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="<mt:var name="value" encode_html="1">" />
<span class="date-time-fields<mt:if name="class"> <mt:var name="class"></mt:if>">
    <input type="text" name="<mt:var name="name" encode_html="1">_d" id="<mt:var name="id" encode_html="1">_d"<mt:if name="d_value"> value="<mt:var name="d_value" encode_html="1">"</mt:if> class="entry-date text-date" />
    <input type="text" name="<mt:var name="name" encode_html="1">_t" id="<mt:var name="id" encode_html="1">_t"<mt:if name="t_value"> value="<mt:var name="t_value" encode_html="1">"</mt:if> class="entry-date" />
</span>
            }
        },
        date => {
            html => qq{
<input type="hidden" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="<mt:var name="value" encode_html="1">" />
<span class="date-time-fields<mt:if name="class"> <mt:var name="class"></mt:if>">
    <input type="text" name="<mt:var name="name" encode_html="1">_d" id="<mt:var name="id" encode_html="1">_d"<mt:if name="d_value"> value="<mt:var name="d_value" encode_html="1">"</mt:if> class="entry-date text-date" />
    <input type="hidden" name="<mt:var name="name" encode_html="1">_t" id="<mt:var name="id" encode_html="1">_t" value="00:00:00" />
</span>
            }
        },
        time => {
            html => qq{
<input type="hidden" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="<mt:var name="value" encode_html="1">" />
<span class="date-time-fields<mt:if name="class"> <mt:var name="class"></mt:if>">
    <input type="hidden" name="<mt:var name="name" encode_html="1">_d" id="<mt:var name="id" encode_html="1">_d" value="1970-01-01" />
    <input type="text" name="<mt:var name="name" encode_html="1">_t" id="<mt:var name="id" encode_html="1">_t"<mt:if name="t_value"> value="<mt:var name="t_value" encode_html="1">"</mt:if> class="entry-date" />
</span>
            }
        },
        number => {
            html => qq{
<input type="number" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="<mt:var name="value" encode_html="1">"<mt:if name="class"> class="<mt:var name="class">"</mt:if><mt:if name="placeholder"> placeholder="<mt:var name="placeholder" encode_html="1">"</mt:if><mt:if name="min" ne="undef"> min="<mt:var name="min">"</mt:if><mt:if name="max" ne="undef"> max="<mt:var name="max">"</mt:if><mt:if name="step"> step="<mt:var name="step">"</mt:if> />
            }
        },
        range => {
            html => qq{
<input type="range" name="<mt:var name="name" encode_html="1">" id="<mt:var name="id" encode_html="1">" value="<mt:var name="value" encode_html="1">"<mt:if name="class"> class="<mt:var name="class">"</mt:if><mt:if name="min" ne="undef"> min="<mt:var name="min">"</mt:if><mt:if name="max" ne="undef"> max="<mt:var name="max">"</mt:if><mt:if name="step"> step="<mt:var name="step">"</mt:if> />
            }
        },
    };

    # define asset htmls
    my %asset_types = load_asset_types();
    foreach my $asset_type (keys %asset_types) {
        my $asset_type_label = encode_html(MT->translate($asset_type));
        $types->{$asset_type} = {
            html => qq{
<input name="<mt:var name="name" escape="html">" id="<mt:var name="id" escape="html">" type="hidden" value="<mt:var name="value" escape="html">" />
<div id="<mt:var name="id">_preview" class="flcf-preview">
    <mt:var name="preview_html">
</div>
<div class="actions-bar" style="clear: none;">
    <div class="actions-bar-inner pkg actions">
        <a href="<mt:var name="script_url">?__mode=list_asset&amp;_type=asset&amp;blog_id=<mt:var name="blog_id">&amp;dialog_view=1&amp;<mt:if name="asset_type" ne="asset">filter=class&amp;filter_val=<mt:var name="asset_type">&amp;require_type=<mt:var name="asset_type">&amp;</mt:if>edit_field=<mt:var name="pseudo_id">&amp;asset_select=1'" class="btn btn-default mt-modal-open" data-mt-modal-large><__trans phrase="Choose [_1]" params="${asset_type_label}"></a>
        <mt:unless var="required">
        <a href="#" id="<mt:var name="id" escape="html">_remove_asset"
            class="btn btn-default<mt:unless var="value"> hidden</mt:unless>"
            type="submit"
            onclick="flcfInsertCustomFieldAsset('', '<mt:var name="id" escape="JS">'); return false;"
            ><__trans_section component="FLCFCommon"><__trans phrase="Remove [_1]" params="${asset_type_label}"></__trans_section></a>
        </mt:unless>
    </div>
</div>
            },
        };
    }

    return $types;
}

sub field_html_params_common {
    my ($app, $tmpl_param) = @_;

    my $blog = $app->blog;
    my $plugin = MT->component('FLCFCommon');
    my $req = MT->request;

    # load asset_types
    my %asset_types = load_asset_types;

    # load flcf_types and field definition
    my $flcf_types = MT->registry('flcf_types');
    my ($flcf_def, $field_def, $field_options, $field_units, $field_unit_groups);
    eval {
        $flcf_def = MT::Util::YAML::Load($tmpl_param->{flcf_def}) || {};
    };
    if ($@) {
        if ($app->param('_type') eq 'field') {
            return;
        }
        else {
            $tmpl_param->{field_flcf_html} = $plugin->translate('Malformed field definition YAML string. [_1]', $@);
            return;
        }
    }

    $field_def = $flcf_def->{fields} || {};
    if (!scalar(keys(%$field_def))) {
        if ($app->param('_type') eq 'field') {
            return;
        }
        else {
            $tmpl_param->{field_flcf_html} = $plugin->translate('No field in field definition YAML string.');
            return;
        }
    }
    $field_options = $flcf_def->{options} || {};
    $field_units = $flcf_def->{units};
    $field_unit_groups = $flcf_def->{unit_groups};
    my $field_unit_defs = {};
    my @field_uns = defined($field_units) && defined($field_units->{names})
                  ? @{$field_units->{names}} : ();
    for my $field_un (@field_uns) {
        my $unit_name = $field_un->{name};
        $field_unit_defs->{$unit_name}->{label} = $field_un->{label};
        if (defined($field_un->{required}) &&
            ref($field_un->{required}) eq 'ARRAY') {
            my @required = @{$field_un->{required}};
            $field_unit_defs->{$unit_name}->{required} = {};
            map { $field_unit_defs->{$unit_name}->{required}->{$_} = 1 } @required;
        }
        else {
            $field_unit_defs->{$unit_name}->{required} = {};
        }
    }

    # initialize field_template and field_values
    my $field_values;
    eval {
        if ($app->param('_preview_file')) {
            $field_values = from_json($app->param($tmpl_param->{field_name}));
        }
        else {
            $field_values = from_json($tmpl_param->{field_value});
        }
    };
    if ($@) {
        $field_values = [];
    }
    my $field_tmpl = {};
    for my $key (keys %$field_def) {
        $field_tmpl->{$key} = defined($field_def->{$key}->{default})
                            ? $field_def->{$key}->{default}
                            : '';
    }
    if (defined($field_units)) {
        $field_tmpl->{flcf_unit_name} = defined($field_units->{default})
                                      ? $field_units->{default}
                                      : $field_units->{names}->[0]->{name};
    }
    if (!scalar @$field_values) {
        push @$field_values, $field_tmpl;
        $tmpl_param->{field_value} = encode_html(to_json([ $field_tmpl ]));
    }
    unshift @$field_values, $field_tmpl;

    # split units
    my $unit_htmls = {};
    if (defined($field_units)) {
        my @lines = split /\r?\n/, $tmpl_param->{flcf_html};
        my $unit_name = '';
        for my $line (@lines) {
            if ($line =~ /<\!--\s*?\{\{unit\s*?:\s*?([^-]*?)\}\}\s*?-->/) {
                $unit_name = $1;
            }
            elsif ($unit_name) {
                $unit_htmls->{$unit_name} .= $line;
            }
        }
    }
    else {
        $unit_htmls->{main} = $tmpl_param->{flcf_html};
    }

    # check unused controls
    my $unused_ctrls = {};
    my $used_ctrls = {};
    for my $unit_name (keys %$unit_htmls) {
        my (%ctrls, %u_ctrls);
        map { $ctrls{$_} = 1 } keys %$field_tmpl;
        for my $ctrl (keys %ctrls) {
            if ($unit_htmls->{$unit_name} =~ /\{\{$ctrl\}\}/) {
                delete $ctrls{$ctrl};
                $u_ctrls{$ctrl} = 1;
            }
        }
        $unused_ctrls->{$unit_name} = \%ctrls;
        $used_ctrls->{$unit_name} = \%u_ctrls;
        for my $unused_ctrl (keys %ctrls) {
            $unit_htmls->{$unit_name} .= "\n{{" . $unused_ctrl . '_hidden}}';
        }
    }

    # create html
    my $html = '';
    my $cf_name = $tmpl_param->{field_name};
    my $cf_id = $tmpl_param->{field_id};
    my @field_class_a = ();
    my %field_unit_names_h = ();
    my $pre_html = '';
    my $post_html = '';
    my $unit_chg_html = '';
    my $is_use_asset = 0;
    my $used_flcf_types = $req->stash('FreeLayoutCustomField::USED_FLCF_TYPES') || {};
    my $cf_pseudo_id = ($cf_id =~ /^content-field/) ? "customfield_${cf_id}" : $cf_id;
    
    # create unit selector
    if ($field_units) {
        $unit_chg_html = '<select class="flcf-change-unit">';
        for my $unit (@{$field_units->{names}}) {
            $unit_chg_html .= '<option value="' . encode_html($unit->{name}) . '">';
            $unit_chg_html .= remove_html($unit->{label});
            $unit_chg_html .= '</option>';
        }
        $unit_chg_html .= '</select>'
    }

    # pre field html
    push @field_class_a, 'flcf-block';
    if ($field_options->{multiple}) {
        $pre_html = <<HERE;
<div class="flcf-field-header"><span class="flcf-field-label"></span>${unit_chg_html}</div>
<div class="flcf-field-content">
HERE
        $post_html = '</div>';
        if ($field_options->{sortable} &&
            !$field_options->{tab} &&
            !$field_options->{accordion}) {
            push @field_class_a, 'flcf-sort-enabled';
        }
        else {
            push @field_class_a, 'flcf-multiple';
        }
    }
    if ($field_options->{div_class}) {
        push @field_class_a, $field_options->{div_class};
    }
    my $field_class = join ' ', @field_class_a;
    $field_class = " class=\"${field_class}\"" if ($field_class);
    my $i;
    my %js_tmpls = %$unit_htmls;
    for ($i = 0; $i < scalar @$field_values; $i++) {
        my $field_value = $field_values->[$i];
        my $f_html;
        if ($i) {
            if (defined($field_units)) {
                unless (defined($field_values->[$i]->{flcf_unit_name})) {
                    $field_values->[$i]->{flcf_unit_name}
                        = ($field_units->{default})
                        ? $field_units->{default}
                        : $field_units->{names}->[0]->{name};
                }
                $f_html = $unit_htmls->{$field_values->[$i]->{flcf_unit_name} || 'main'} || '';
            }
            else {
                $f_html = $tmpl_param->{flcf_html} || '';
            }
        }
        for my $key (keys %$field_tmpl) {
            # create field
            my $flcf_type = $field_def->{$key}->{type} || '';
            $used_flcf_types->{$flcf_type} = 1 if ($flcf_type);
            my $flcf_tmpl_text = $flcf_types->{$flcf_type}->{html} || '';
            my $flcf_tmpl = MT->model('template')->new;
            $flcf_tmpl->text($flcf_tmpl_text);
            my $val;
            if (defined($field_value->{$key})) {
                $val = defined($field_value->{$key})
                     ? $field_value->{$key} : '';
            }
            else {
                $val = defined($field_def->{$key}->{default})
                     ? $field_def->{$key}->{default} : '';
            }

            my @opts;
            if ($flcf_types->{$flcf_type}->{set_options}) {
                # set option callback
                my $code = $flcf_types->{$flcf_type}->{set_options};
                if (!ref $code) {
                    $code = $app->handler_to_coderef($code);
                }
                my $field_name = "${cf_name}_flcfg${i}_${key}_";
                $code->(\@opts, $field_name, $i, $field_def->{$key}, $val);
            }
            else {
                if ($field_def->{$key}->{options} &&
                    ref($field_def->{$key}->{options}) eq 'ARRAY') {
                    @opts = @{$field_def->{$key}->{options}};
                }
                if (scalar(@opts)) {
                    my $last_group = '';
                    my $count = scalar(@opts);
                    for (my $opt_c = 0; $opt_c < $count; $opt_c++) {
                        if ($flcf_type eq 'optgroup') {
                            if ($opts[$opt_c]->{group} &&
                                $opts[$opt_c]->{group} ne $last_group
                            ) {
                                $opts[$opt_c]->{group_first} = 1;
                                $last_group = $opts[$opt_c]->{group};
                            }
                            if ($opt_c == $count - 1 ||
                                ($opts[$opt_c + 1]->{group} &&
                                     (!defined($opts[$opt_c]->{group}) ||
                                      $opts[$opt_c]->{group} ne
                                      $opts[$opt_c + 1]->{group})
                                )
                            ) {
                                $opts[$opt_c]->{group_last} = 1;
                            }
#                            $opts[$opt_c]->{group} = $last_group || $no_group;
                        }
                        if (!defined($opts[$opt_c]->{label})) {
                            $opts[$opt_c]->{label} = $opts[$opt_c]->{value};
                        }
                    }
                }
            }

            my %param_options;

            # create asset thumbnail
            my $preview_html;
            if ($asset_types{$flcf_type}) {
                # load asset
                my $asset;
                if ($val) {
                    $asset = MT->model('asset')->load($val);
                }

                # create asset link
                if ($asset) {
                    my $t = MT::Template->new(
                        type => 'scalarref',
                    );
                    my $ctx = $t->context;
                    $ctx->stash('asset', $asset);
                    if ($asset->class_type eq 'image') {
                        my $view = $app->translate("View image");
                        my $text = <<HERE;
<a href="<mt:asseturl>" target="_blank" title="$view"><img src="<mt:assetthumbnailurl width="240" height="240">" alt="" /></a>
HERE
                        $t->text($text);
                        $preview_html = $t->output()
                            or return $app->error('Edit asset error : [_1]', $field_def->{$key}->{label});
                    }
                    else {
                        $preview_html = $asset->as_html;
                    }
                }
                $param_options{preview_html} = $preview_html if $preview_html;
                $param_options{asset_type} = $flcf_type;
            }

            # set placeholder to text based field
            if ($flcf_type eq 'text' || $flcf_type eq 'textarea' ||
                $flcf_type eq 'number') {
                $param_options{placeholder} = $field_def->{$key}->{placeholder}
                    if ($field_def->{$key}->{placeholder});
            }

            # set pattern to text field
            if ($flcf_type eq 'text') {
                $param_options{pattern} = $field_def->{$key}->{pattern}
                    if ($field_def->{$key}->{pattern});
            }

            # set minlength / maxlength to text and textareafield
            if ($flcf_type eq 'text' || $flcf_type eq 'textarea') {
                $param_options{minlength} = $field_def->{$key}->{minlength}
                    if ($field_def->{$key}->{minlength});
                $param_options{maxlength} = $field_def->{$key}->{maxlength}
                    if ($field_def->{$key}->{maxlength});
            }

            # html5 number / range field
            if ($flcf_type eq 'number' || $flcf_type eq 'range') {
                $param_options{min} = defined($field_def->{$key}->{min})
                                    ? $field_def->{$key}->{min} : 'undef';
                $param_options{max} = defined($field_def->{$key}->{max})
                                    ? $field_def->{$key}->{max} : 'undef';
                $param_options{step} = $field_def->{$key}->{step} || 0;
            }

            # create datetime
            if ($flcf_type eq 'datetime' ||
                $flcf_type eq 'date' ||
                $flcf_type eq 'time') {
                if ($val =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/) {
                    $param_options{d_value} = "$1-$2-$3";
                    $param_options{t_value} = "$4:$5:$6";
                }
                elsif ($val =~ /error/) {
                    my $dt = from_json($val);
                    $param_options{d_value} = $dt->{date};
                    $param_options{t_value} = $dt->{time};
                }
            }

            # set param options
            if ($flcf_types->{$flcf_type}->{set_params}) {
                my $code = $flcf_types->{$flcf_type}->{set_params};
                if (!ref $code) {
                    $code = $app->handler_to_coderef($code);
                }
                my $field_name = "${cf_name}_flcfg${i}_${key}_";
                $code->(\%param_options, $field_name, $i, $field_def->{$key}, $val);
            }
            # encode json to string
            if (ref $val eq 'HASH' || ref $val eq 'ARRAY') {
                $val = to_json($val);
            }

            # set param
            $flcf_tmpl->param({
                blog_id => ($blog) ? $blog->id : 0,
                name => "${cf_name}_flcfg${i}_${key}_",
                id => "${cf_id}_flcfg${i}_${key}_",
                pseudo_id => "${cf_pseudo_id}_flcfg${i}_${key}_",
                value => $val,
                class => $field_def->{$key}->{class} || '',
                options => \@opts,
                is_unit => defined($field_units),
                %param_options
            });
            my $flcf_html = $flcf_tmpl->build || '';
            my $search = '\{\{' . $key . '\}\}';
            if ($i) {
                $f_html =~ s/$search/$flcf_html/;
            }
            else {
                for my $unit_name (keys %js_tmpls) {
                    $js_tmpls{$unit_name} =~ s/$search/$flcf_html/;
                }
            }

            # create label
            my $label_id  = "${cf_id}_flcfg${i}_${key}_";
            my $label_text = $field_def->{$key}->{label} || '';
            my $un = $field_value->{flcf_unit_name};
            my $req_flag = 0;
            if ($field_def->{$key}->{required} ||
                (
                    $un &&
                    $field_unit_defs->{$un} &&
                    $field_unit_defs->{$un}->{required}->{$key}
                )
            ) {
                $req_flag = 1;
            }
            my @label_classes = ();
            my $label_required = '';
            if ($req_flag) {
#                push @label_classes, 'flcf-required';
                 $label_required = ' <span class="badge badge-danger">' . $plugin->translate('required') . '</span>';
            }
            if ($field_def->{$key}->{label_class}) {
                push @label_classes, encode_html($field_def->{$key}->{label_class});
            }
            my $label_class = scalar(@label_classes)
                            ? ' class="' . join(' ', @label_classes) . '"'
                            : '';
            my $label_html = <<HERE;
<label for="${label_id}"${label_class}>${label_text}${label_required}</label>
HERE
            my $l_search = '\{\{' . $key . '_label\}\}';
            if ($i) {
                $f_html =~ s/$l_search/$label_html/;
            }
            else {
                for my $unit_name (keys %js_tmpls) {
                    $js_tmpls{$unit_name} =~ s/$l_search/$label_html/;
                }
            }

            # create hidden
            my $hidden_search = '\{\{' . $key . '_hidden\}\}';
            my $hidden_id = encode_html("${cf_id}_flcfg${i}_${key}_");
            my $hidden_name = encode_html("${cf_name}_flcfg${i}_${key}_");
            my $hidden_value = encode_html($field_value->{$key} || '');
            my $hidden_html = <<HERE;
<input type="hidden" name="${hidden_name}" id="${hidden_id}" value="${hidden_value}" />
HERE
            if ($i) {
                $f_html =~ s/$hidden_search/$hidden_html/;
            }
            else {
                for my $unit_name (keys %js_tmpls) {
                    $js_tmpls{$unit_name} =~ s/$hidden_search/$hidden_html/;
                }
            }

            # set asset flag
            $is_use_asset = 1 if ($asset_types{$flcf_type});
        }

        # out tmplate or html
        if ($i == 0) {
            for my $unit_name (keys %js_tmpls) {
                my $u_html = $js_tmpls{$unit_name};
                $js_tmpls{$unit_name} = <<HERE;
    <div id="${cf_name}_flcfg${i}"${field_class}>${pre_html}${u_html}${post_html}</div>
HERE
                $js_tmpls{$unit_name} = $plugin->translate_templatized($js_tmpls{$unit_name});
            }
        }
        else {
            $html .= <<HERE;
    <div id="${cf_name}_flcfg${i}"${field_class}>${pre_html}${f_html}${post_html}</div>
HERE
        }

        # set unit name
        if (defined($field_units) && $i) {
            $field_unit_names_h{"${cf_name}_flcfg${i}"} = $field_value->{flcf_unit_name};
        }
    }

    # set used ctrls for js
    my $js_used_ctrls = $req->stash('FreeLayoutCustomField::JS_USED_CTRLS') || {};
    $js_used_ctrls->{$tmpl_param->{field_name}} = $used_ctrls;
    $req->stash('FreeLayoutCustomField::JS_USED_CTRLS', $js_used_ctrls);

    # set field names
    my $field_names = $req->stash('FreeLayoutCustomField::FIELD_NAMES');
    $field_names->{$tmpl_param->{field_name}} = [ keys %$field_tmpl ];
    $req->stash('FreeLayoutCustomField::FIELD_NAMES', $field_names);

    # set field definition
    my $field_defs = $req->stash('FreeLayoutCustomField::FIELD_DEFS') || {};
    $field_defs->{$cf_name} = $field_def;
    $req->stash('FreeLayoutCustomField::FIELD_DEFS', $field_defs);

    # set field options
    my $field_opts = $req->stash('FreeLayoutCustomField::FIELD_OPTIONS') || {};
    $field_opts->{$cf_name} = $field_options;
    $req->stash('FreeLayoutCustomField::FIELD_OPTIONS', $field_opts);

    # set unit names / unit defs / field unit names
    if (defined($field_units)) {
        $tmpl_param->{field_flcf_units} = $field_units->{names};
        my $unit_names = $req->stash('FreeLayoutCustomField::UNIT_NAMES');
        $unit_names->{$tmpl_param->{field_name}} = 1;
        $req->stash('FreeLayoutCustomField::UNIT_NAMES', $unit_names);
        my $field_unit_names = $req->stash('FreeLayoutCustomField::FIELD_UNIT_NAMES') || {};
        $field_unit_names = { %$field_unit_names, %field_unit_names_h };
        $req->stash('FreeLayoutCustomField::FIELD_UNIT_NAMES', $field_unit_names);
        my $unit_defs = $req->stash('FreeLayoutCustomField::UNIT_DEFS') || {};
        $unit_defs->{$tmpl_param->{field_name}} = $field_unit_defs;
        $req->stash('FreeLayoutCustomField::UNIT_DEFS', $unit_defs);
        if (defined($field_unit_groups)) {
            $tmpl_param->{field_flcf_unit_groups} = $field_unit_groups->{groups};
            my $unit_groups = $req->stash('FreeLayoutCustomField::UNIT_GROUPS') || {};
            $unit_groups->{$tmpl_param->{field_name}} = {};
            for my $group (@{$field_unit_groups->{groups}}) {
                $unit_groups->{$tmpl_param->{field_name}}->{$group->{name}} = $group;
            }
            $req->stash('FreeLayoutCustomField::UNIT_GROUPS', $unit_groups);
            my $unit_defaults = $req->stash('FreeLayoutCustomField::UNIT_DEFAULTS') || {};
            $unit_defaults->{$tmpl_param->{field_name}} =
                $field_unit_groups->{default}
                    ? $field_unit_groups->{default}
                    : $field_unit_groups->{groups}->[0]->{name};
            $req->stash('FreeLayoutCustomField::UNIT_DEFAULTS', $unit_defaults);
        }
    }

    # append css / custom init js / custom js
    my $static_path = $app->static_path;
    if ( $static_path =~ m!^/! ) {
        $static_path = $app->base . $static_path;
    }
    my $append_css = $req->stash('FreeLayoutCustomField::CSS') || '';
    my $flcf_css = $tmpl_param->{flcf_css};
    $flcf_css =~ s/\{\{static_uri\}\}/$static_path/g;
    if ($cf_id =~ /^content-field/) {
        my $field_id = '.flcf-' . $tmpl_param->{field_id} . '-container';
        $flcf_css =~ s/\{\{field_id\}\}/$field_id/g;
    }
    $append_css .= $flcf_css . "\n";
    $req->stash('FreeLayoutCustomField::CSS', $append_css);
    my $append_init_js = $req->stash('FreeLayoutCustomField::CUSTOM_INIT_JS') || '';
    my $flcf_init_js = $tmpl_param->{flcf_init_js};
    $flcf_init_js =~ s/\{\{static_uri\}\}/$static_path/g;
    $append_init_js .= $flcf_init_js . "\n";
    $req->stash('FreeLayoutCustomField::CUSTOM_INIT_JS', $append_init_js);
    my $append_js = $req->stash('FreeLayoutCustomField::CUSTOM_JS') || '';
    my $flcf_js = $tmpl_param->{flcf_js};
    $flcf_js =~ s/\{\{static_uri\}\}/$static_path/g;
    if ($cf_id =~ /^content-field/) {
        my $field_id = '.flcf-' . $tmpl_param->{field_id} . '-container';
        $flcf_js =~ s/\{\{field_id\}\}/$field_id/g;
    }
    $append_js .= $flcf_js . "\n";
    $req->stash('FreeLayoutCustomField::CUSTOM_JS', $append_js);

    # append js template and next number
    my $js_tmpl = $req->stash('FreeLayoutCustomField::JS_TMPL') || {};
    if (defined($field_units)) {
        $js_tmpl->{$tmpl_param->{field_name}} = \%js_tmpls;
    }
    else {
        $js_tmpl->{$tmpl_param->{field_name}} = $js_tmpls{main};
    }
    $req->stash('FreeLayoutCustomField::JS_TMPL', $js_tmpl);
    my $next_num = $req->stash('FreeLayoutCustomField::NEXT_NUM') || {};
    $next_num->{$tmpl_param->{field_name}} = $i;
    $req->stash('FreeLayoutCustomField::NEXT_NUM', $next_num);

    # add button and add sortable field flag
    if ($field_options->{multiple}) {
        $tmpl_param->{field_flcf_addable} = !$field_options->{fixed};
        my $group_label;
        if ($field_options->{group_label}) {
            $group_label = $field_options->{group_label};
        }
        else {
            $group_label = ($tmpl_param->{field_label} || '') . ' {{number}}';
        }
        my $group_labels = $req->stash('FreeLayoutCustomField::GROUP_LABELS') || {};
        $group_labels->{$tmpl_param->{field_name}} = $group_label;
        $req->stash('FreeLayoutCustomField::GROUP_LABELS', $group_labels);

        my $delete_label;
        if ($field_options->{delete_button_label}) {
            $delete_label = $field_options->{delete_button_label};
        }
        else {
            $delete_label = $plugin->translate('Delete [_1] {{number}}', $tmpl_param->{field_label});
        }
        my $delete_labels = $req->stash('FreeLayoutCustomField::DELETE_LABELS') || {};
        $delete_labels->{$tmpl_param->{field_name}} = $delete_label;
        $req->stash('FreeLayoutCustomField::DELETE_LABELS', $delete_labels);

        if ($field_options->{tab}) {
            my $tabs = $req->stash('FreeLayoutCustomField::Tab') || {};
            $tabs->{$tmpl_param->{field_name}} = 1;
            $req->stash('FreeLayoutCustomField::Tab', $tabs);
        }
        elsif ($field_options->{accordion}) {
            my $accs = $req->stash('FreeLayoutCustomField::Accordion') || {};
            $accs->{$tmpl_param->{field_name}} = 1;
            $req->stash('FreeLayoutCustomField::Accordion', $accs);
        }
        else {
            my $norms = $req->stash('FreeLayoutCustomField::Normal') || {};
            $norms->{$tmpl_param->{field_name}} = 1;
            $req->stash('FreeLayoutCustomField::Normal', $norms);
        }
        if ($field_options->{sortable}) {
            if ($field_options->{float}) {
                my $float = $req->stash('FreeLayoutCustomField::Float') || [];
                push @$float, $tmpl_param->{field_name};
                $req->stash('FreeLayoutCustomField::Float', $float);
            }
            else {
                my $sortable = $req->stash('FreeLayoutCustomField::Sortable') || [];
                push @$sortable, $tmpl_param->{field_name};
                $req->stash('FreeLayoutCustomField::Sortable', $sortable);
            }
        }
    }

    #set used flcf types
    $req->stash('FreeLayoutCustomField::USED_FLCF_TYPES', $used_flcf_types);

    # set asset flag
    if ($is_use_asset) {
        $req->stash('FreeLayoutCustomField::IS_USE_ASSET', 1);
    }

    # set field order
    $tmpl_param->{field_order} = ($i - 1) . '|' . (join ',', (1..$i - 1));

    # set used / unused ctrls in unit
    if (defined($field_units)) {
        for my $unit_name (keys %$unused_ctrls) {
            delete $unused_ctrls->{$unit_name}->{flcf_unit_name};
        }
        my $s_unused_ctrls = $req->stash('FreeLayoutCustomField::UNUSED_CTRLS') || {};
        $s_unused_ctrls->{$tmpl_param->{field_name}} = $unused_ctrls;
        $req->stash('FreeLayoutCustomField::UNUSED_CTRLS', $s_unused_ctrls);
        my $s_used_ctrls = $req->stash('FreeLayoutCustomField::USED_CTRLS') || {};
        $s_used_ctrls->{$tmpl_param->{field_name}} = $used_ctrls;
        $req->stash('FreeLayoutCustomField::USED_CTRLS', $s_used_ctrls);
    }

    # out html
    if ($field_options->{add_button_label}) {
        $tmpl_param->{field_button_label} = $field_options->{add_button_label};
    }
    else {
        $tmpl_param->{field_button_label} = $plugin->translate('Add [_1]', $tmpl_param->{field_label});
    }
    if ($field_options->{add_group_button_label}) {
        $tmpl_param->{field_add_group_button_label} = $field_options->{add_group_button_label};
    }
    else {
        $tmpl_param->{field_add_group_button_label} = $plugin->translate('Add group of [_1]', $tmpl_param->{field_label});
    }
    if ($field_options->{change_group_button_label}) {
        $tmpl_param->{field_change_group_button_label} = $field_options->{change_group_button_label};
    }
    else {
        $tmpl_param->{field_change_group_button_label} = $plugin->translate('Change to selected group');
    }

    $tmpl_param->{field_flcf_id} = $tmpl_param->{field_name} . '_flcfg';
    $tmpl_param->{field_flcf_html} = $html;

}

1;
