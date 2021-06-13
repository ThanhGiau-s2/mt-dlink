package GoogleMapsCustomFields::Callback;

use strict;
use MT;

use constant MAP_WIDTH => 80;
use constant MAP_HEIGHT => 80;

sub field_html_params {
    my ($key, $tmpl_key, $tmpl_param) = @_;
    my $app = MT->instance;
    my $plugin = MT->component('GoogleMapsCustomFields');

    $tmpl_param->{fjgmcf_address_msg} = $plugin->translate('Address');
    $tmpl_param->{fjgmcf_button_msg} = $plugin->translate('Search location by address');
    $tmpl_param->{fjgmcf_div_msg} = $plugin->translate('Now loading Google Maps...');
    $tmpl_param->{fjgmcf_default_msg} = $plugin->translate('Please enter default width and height on blog and admin screen of Google Map with separating by comma');
    $tmpl_param->{fjgmcf_showmap_msg} = $plugin->translate('Show map');
    $tmpl_param->{fjgmcf_map_width} =
        $tmpl_param->{option_loop}->[2]->{option} ||
        $tmpl_param->{option_loop}->[0]->{option} || 500;
    $tmpl_param->{fjgmcf_map_height} =
        $tmpl_param->{option_loop}->[3]->{option} ||
        $tmpl_param->{option_loop}->[1]->{option} || 200;
    $tmpl_param->{fjgmcf_map_height_hide} = $tmpl_param->{fjgmcf_map_height} + 200;
    my @values = split '|', $tmpl_param->{field_value};
    $tmpl_param->{fjgmcf_showmap} = $values[0];

    require MT::Request;
    my $req = MT::Request->instance;
    my $fields = $req->stash('fjgmcf::fields');
    if ($fields) {
        push @$fields, $tmpl_param->{field_name};
    }
    else {
        $fields = [ $tmpl_param->{field_name} ];
    }
    $req->stash('fjgmcf::fields', $fields);
}

sub add_js {
    my ($cb, $app, $param, $tmpl) = @_;

    my $host_node;
    my $elements = $tmpl->getElementsByTagName('include');
    for my $element (@$elements) {
        if($element->attributes->{name} eq 'layout/default.tmpl') {
            $host_node = $element;
            last;
        }
    }
    if ($host_node) {
        my $js_node = $tmpl->createElement('setvarblock', { name => 'js_include', append => 1 });
        $js_node->innerHTML(_gmap_js($app));
        $tmpl->insertBefore($js_node, $host_node);

        my $css_node = $tmpl->createElement('setvarblock', { name => 'css_include', append => 1 });
        my $innerHTML = q{
<link rel="stylesheet" href="<mt:var name="static_uri">plugins/GoogleMapsCustomFields/css/style.css" type="text/css" media="screen" charset="utf-8" />
};
        $css_node->innerHTML($innerHTML);
        $tmpl->insertBefore($css_node, $host_node);
    }
}

sub footer {
    my ($cb, $app, $param, $tmpl) = @_;
    my $plugin = MT->component('GoogleMapsCustomFields');

    require MT::Request;
    my $req = MT::Request->instance;
    my $fields = $req->stash('fjgmcf::fields');
    return unless(defined($fields));

    # search <mt:var name="jq_js_include">
    my $elements = $tmpl->getElementsByTagName('var');
    my $host_node;
    for my $element (@$elements) {
        if($element->attributes->{name} eq 'jq_js_include') {
            $host_node = $element;
            last;
        }
    }

    # append js
    if ($host_node) {
        my %fields;
        map { $fields{$_} = 1; } @$fields;
        my @fields = keys %fields;
        my $node = $tmpl->createElement('setvarblock', { 'name' => 'jq_js_include', 'append' => 1 });
        my $fields_js = "     [\n" . join (",\n", map { "        '" . $_ . "'" } @fields) . '    ]';
        my $add_tmpl = <<HERE;
if (typeof(FJGoogleMapsCustomFieldsInit) != 'undefined') {
    FJGoogleMapsCustomFieldsInit(
$fields_js
    );
}
HERE
        $add_tmpl = $plugin->translate_templatized($add_tmpl);
        $node->innerHTML($add_tmpl);
        $tmpl->insertBefore($node, $host_node);
    }
}

sub install_tags {
    my $app = shift;
    my $cmpnt = MT->component('commercial');
    return if (!$cmpnt);
    my $tags = $cmpnt->registry('tags');
    my $fields = $cmpnt->{customfields};
    my @gmap_fields = grep { $_->type eq 'googlemaps' } @$fields;
    for my $gmap_field (@gmap_fields) {
        $tags->{block}->{$gmap_field->tag . 'block'} = '$GoogleMapsCustomFields::GoogleMapsCustomFields::ContextHandlers::gmap_block';
    }
}

sub list_properties {
    my ($eh, $app, $fields, $field_map) = @_;

    return unless(defined($field_map->{googlemaps}));

    my $plugin = MT->component('GoogleMapsCustomFields');
    for my $key (@{$field_map->{googlemaps}}) {
        my $field = $fields->{$key}->{field};
        delete $fields->{$key}->{sort};
        delete $fields->{$key}->{bulk_sort};
        delete $fields->{$key}->{terms};
        $fields->{$key}->{sub_fields} =  [
            {
                class => 'map_detail_data_' . $field->{name},
                label => $field->name . '(' . $plugin->translate('Detail') . ')',
                display => 'optional',
            },
        ];
        $fields->{$key}->{col_class} = 'map_detail';
        $fields->{$key}->{html} = \&html;
    }
}

sub html {
    my ($prop, $obj) = @_;

    my ($value, $fld_class);
    if ($prop->field->{acf}) {
        $value = $obj->column($prop->col);
    }
    else {
        $value = $obj->meta($prop->col);
    }
    $fld_class = $prop->field->{field_name};
    return '-' unless (defined($value));
    my $map_width = MAP_WIDTH;
    my $map_height = MAP_HEIGHT;
    my $plugin = MT->component('GoogleMapsCustomFields');
    my @params = split '\|', $value;
    return '' if (scalar @params == 0 || !$params[0]);
    my $name = $params[4] || $plugin->translate('No name');
    my $link_url = "http://maps.google.co.jp/maps?f=q&amp;source=s_q&amp;hl=ja&amp;q=$params[1],$params[2]&amp;z=$params[3]&amp;&ie=UTF8";
    my $url = "http://maps.google.com/maps/api/staticmap?center=$params[1],$params[2]&amp;zoom=$params[3]&amp;size=${map_width}x${map_height}&amp;markers=$params[1],$params[2]&amp;sensor=false";
    $params[1] =~ /(\d+.\d{6})/;
    my $lat = $1;
    $params[2] =~ /(\d+.\d{6})/;
    my $lng = $1;
    my $plc_msg = $plugin->translate('Place');
    my $lat_msg = $plugin->translate('Latitude');
    my $lng_msg = $plugin->translate('Longitude');
    my $title = "[$plc_msg]$name, [$lat_msg]$lat, [$lng_msg]$lng";
    return qq{<a href="$link_url" title="$title" target="_blank"><img src="$url" title="$title" alt="$name" width="${map_width}" height="${map_height}"></a><br /><span class="map_detail_data_${fld_class}">[$plc_msg]$name<br />[$lat_msg]$lat<br />[$lng_msg]$lng</span>};
}

sub _gmap_js {
    my $app = shift;

    my $static_uri = $app->static_path;
    my $plugin = MT->component('GoogleMapsCustomFields');
    my $cur_pos_msg = $plugin->translate('Current position');
    my $geocode_error_msg = $plugin->translate('Geocode was not successful for the following reason: ');
    my $path = '';
    my $api_key = $plugin->get_config_value('fjgmcf_api_key', 'system');
    if ($app->config->CGIPath =~ /^(https?:)/) {
        $path = $1;
    }
    my $html = <<HERE;
<script type="text/javascript">
var FJGoogleMapsCustomFieldsI18N = {
    cur_pos_msg : '$cur_pos_msg',
    geocode_error_msg : '$geocode_error_msg'
};
</script>
<script type="text/javascript" src="${path}//maps.googleapis.com/maps/api/js?key=${api_key}"></script>
<script type="text/javascript" src="${static_uri}plugins/GoogleMapsCustomFields/js/gmap.js"></script>
HERE
    return $html;
}

1;
