package GoogleMapsCustomFields::FLCF;

use strict;
use MT;

use constant TOKYO_STATION_LAT => 35.6815;
use constant TOKYO_STATION_LNG => 139.7662;
use constant DEFAULT_ZOOM => 15;

sub flcf_types {
    my $types = {
        googlemaps => {
            html => q{
      <p><input type="checkbox" id="<mt:var name="name">_fjgmcf_showmap" name="<mt:var name="name">_fjgmcf_showmap" value="1"<mt:if name="fjgmcf_showmap"> checked="checked"</mt:if> /> <mt:var name="fjgmcf_showmap_msg"></p>
      <div id="<mt:var name="name">_fjgmcf_gmap_main"<mt:unless name="fjgmcf_showmap"> style="position : absolute; left : -10000px; "</mt:unless>>
      <div id="<mt:var name="name">_fjgmcf_gmap" style="width : <mt:var name="fjgmcf_map_width">px; height : <mt:var name="fjgmcf_map_height">px; border : 1px solid #cccccc;"><mt:var name="fjgmcf_div_msg"></div>
      <mt:var name="fjgmcf_address_msg"> <input type="text" id="<mt:var name="name">_fjgmcf_search" name="<mt:var name="name">_fjgmcf_search" size="30" style="width : 300px;" /> <input type="button" name="<mt:var name="name">_fjgmcf_search_btn" id="<mt:var name="name">_fjgmcf_search_btn" value="<mt:var name="fjgmcf_button_msg">" />
      <input type="hidden" name="<mt:var name="name">" id="<mt:var name="id">" value="<mt:var name="value">" class="full-width" autocomplete="off" mt:watch-change="1" />
      </div>
            },
            set_params => \&set_params,
            js_set_value => 1,
        },
    };
    return $types;
}

sub set_params {
    my ($field_data, $field_name, $group_no, $field_def, $value) = @_;

    my $app = MT->instance;
    my $plugin = MT->component('GoogleMapsCustomFields');
    $field_data->{fjgmcf_address_msg} = $plugin->translate('Address');
    $field_data->{fjgmcf_button_msg} = $plugin->translate('Search location by address');
    $field_data->{fjgmcf_div_msg} = $plugin->translate('Now loading Google Maps...');
    $field_data->{fjgmcf_default_msg} = $plugin->translate('Please enter default width and height on blog and admin screen of Google Map with separating by comma');
    $field_data->{fjgmcf_showmap_msg} = $plugin->translate('Show map');
    $field_data->{fjgmcf_map_width} =  $field_def->{admin_width} || 500;
    $field_data->{fjgmcf_map_height} = $field_def->{admin_height} || 200;
    $field_data->{fjgmcf_map_height_hide} = $field_data->{fjgmcf_map_height} + 200;
    my @values = split '|', $value;
    $field_data->{fjgmcf_showmap} = $values[0];
    require MT::Request;
    my $req = MT::Request->instance;
    my $fields = $req->stash('fjgmcf::fields');
    if ($group_no) {
        if ($fields) {
            push @$fields, $field_name;
        }
        else {
            $fields = [ $field_name ];
        }
        $req->stash('fjgmcf::fields', $fields);
    }
}

1;
