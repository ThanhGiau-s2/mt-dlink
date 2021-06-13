package GoogleMapsCustomFields::ACF;

use strict;
use MT;
use GoogleMapsCustomFields::ContextHandlers;
use GoogleMapsCustomFields::Callback;

use constant TOKYO_STATION_LAT => 35.6815;
use constant TOKYO_STATION_LNG => 139.7662;
use constant DEFAULT_ZOOM => 15;

sub load_acf_field_types {
    my $field_types = {
        googlemaps => {
            html => q{
      <p><input type="checkbox" id="<mt:var name="field_name">_fjgmcf_showmap" name="<mt:var name="field_name">_fjgmcf_showmap" value="1"<mt:if name="fjgmcf_showmap"> checked="checked"</mt:if> /> <mt:var name="fjgmcf_showmap_msg"></p>
      <div id="<mt:var name="field_name">_fjgmcf_gmap_main"<mt:unless name="fjgmcf_showmap"> style="position : absolute; top : -<mt:var name="fjgmcf_map_height_hide">px;"</mt:unless>>
      <div id="<mt:var name="field_name">_fjgmcf_gmap" style="width : <mt:var name="fjgmcf_map_width">px; height : <mt:var name="fjgmcf_map_height">px; border : 1px solid #cccccc;"><mt:var name="fjgmcf_div_msg"></div>
      <mt:var name="fjgmcf_address_msg"> <input type="text" id="<mt:var name="field_name">_fjgmcf_search" name="<mt:var name="field_name">_fjgmcf_search" size="30" style="width : 300px;" /> <input type="button" name="<mt:var name="field_name">_fjgmcf_search_btn" id="<mt:var name="field_name">_fjgmcf_search_btn" value="<mt:var name="fjgmcf_button_msg">" />
      <input type="hidden" name="<mt:var name="field_name">" id="<mt:var name="field_id">" value="<mt:var name="field_value">" class="full-width" autocomplete="off" mt:watch-change="1" />
      </div>
            },
            html_params => \&gmap_acf_html_params,
            tag_installer => \&GoogleMapsCustomFields::ContextHandlers::gmap_acf_tag_installer,
            set_default => \&set_default,
            init_listing => \&init_listing,
        },
    };
    return $field_types;
}

sub gmap_acf_html_params {
    my ($field_data, $field, $param, $ext) = @_;

    my $app = MT->instance;
    my $plugin = MT->component('GoogleMapsCustomFields');
    my $field_name = $field_data->{field_name};
    $field_data->{fjgmcf_address_msg} = $plugin->translate('Address');
    $field_data->{fjgmcf_button_msg} = $plugin->translate('Search location by address');
    $field_data->{fjgmcf_div_msg} = $plugin->translate('Now loading Google Maps...');
    $field_data->{fjgmcf_default_msg} = $plugin->translate('Please enter default width and height on blog and admin screen of Google Map with separating by comma');
    $field_data->{fjgmcf_showmap_msg} = $plugin->translate('Show map');
    my @field_options = split ',', $field->{field_options};
    $field_data->{fjgmcf_map_width} =
        $field_options[2] || $field_options[0] || 500;
    $field_data->{fjgmcf_map_height} =
        $field_options[3] || $field_options[1] || 200;
    $field_data->{fjgmcf_map_height_hide} = $field_data->{fjgmcf_map_height} + 200;
    my @values = split '|', $field_data->{field_value};
    $field_data->{fjgmcf_showmap} = $values[0];
    require MT::Request;
    my $req = MT::Request->instance;
    my $fields = $req->stash('fjgmcf::fields');
    if ($fields) {
        push @$fields, $field_data->{field_name};
    }
    else {
        $fields = [ $field_data->{field_name} ];
    }
    $req->stash('fjgmcf::fields', $fields);
}

sub set_default {
    my ($field_data, $field, $param, $ext) = @_;
    my $plugin = MT->component('GoogleMapsCustomFields');
    if (ref $field->{field_default} eq 'HASH') {
        my ($def, $def_str, $field_plugin);
        $def = $field->{field_default};
        $def_str .= defined($def->{show}) ? $def->{show} : 1;
        $field_plugin = $field->{field_plugin};
        $def_str .= '|';
        $def_str .= defined($def->{lat}) ? $def->{lat} : TOKYO_STATION_LAT;
        $def_str .= '|';
        $def_str .= defined($def->{lng}) ? $def->{lng} : TOKYO_STATION_LNG;
        $def_str .= '|';
        $def_str .= defined($def->{zoom}) ? $def->{zoom} : DEFAULT_ZOOM;
        $def_str .= '|';
        $def_str .= defined($def->{address})
                  ? $field_plugin->translate($def->{address})
                  : $plugin->translate('Tokyo Station');
        $field_data->{field_value} = $def_str;
    }
    elsif ($field->{field_default}) {
        $field_data->{field_value} = $field->{field_default};
    }
}

sub init_listing {
    my ($field) = @_;

    my $plugin = MT->component('GoogleMapsCustomFields');
    return {
        sub_fields => [
            {
                class => 'map_detail_data_' . $field->{field_name},
                label => $field->{field_label} . '(' . $plugin->translate('Detail') . ')',
                display => 'optional',
            },
        ],
        col_class => 'map_detail',
        html => \&GoogleMapsCustomFields::Callback::html,
    };
}

1;
