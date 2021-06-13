package CSVDataImExporter::CMS;

use strict;
use warnings;

use CSVDataImExporter::ContentData qw(make_content_actions);

sub add_script {
    my ($cb, $app, $tmpl) = @_;

    my $old = <<HERE;
  </mtapp:settinggroup>
</form>
HERE

    my $new .= <<HERE;
  </mtapp:settinggroup>
</form>
<div style="margin-top:20px">
<mt:var name="rest_day">
</div>
HERE

    $$tmpl =~ s/$old/$new/;

    $old = <<HERE;
</script>
HERE
    $old = quotemeta($old);

    $new = <<HERE;
jQuery(function(){
    change_form();
    jQuery('select[name=import_type]').change(function(){
        change_form();
    });

    jQuery('select[name=import_type] option[value=import_csv_cd]').css('display', 'none');

});
function change_form() {
    if ( jQuery('select[name=import_type] option:selected').val() == 'import_csv' ) {
        jQuery('#import_as_me-field').hide();
        jQuery('#convert_breaks-field').hide();
        jQuery('#encoding-field').hide();
        jQuery('#default_cat_id-field').hide();
    } else {
        jQuery('#import_as_me-field').show();
        jQuery('#convert_breaks-field').show();
        jQuery('#encoding-field').show();
        jQuery('#default_cat_id-field').show();
    }
}
</script>
HERE

    $$tmpl =~ s/$old/$new/;

}

sub add_param {
    my ($cb, $app, $param, $tmpl) = @_;

    my $plugin = MT->component("CSVDataImExporter");
    $param->{rest_day} = $plugin->translate('can use [_1]', rest_day());

    1;
}

sub init_request {
    make_content_actions();
}

1;
