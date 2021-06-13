package MT::Plugin::custumSort5;

use strict;
use warnings;

use MT;
use base qw(MT::Plugin);

my $plugin = MT::Plugin::custumSort5->new({
    id => 'custumSort5',
    name => 'custumSort5',
    author_name => 'Kazuma Nishihata',
    author_url => 'http://www.to-r.net/',
    description => 'Sort Custum Field by Base Name',
    doc_link => 'http://blog.webcreativepark.net/2010/06/21-202238.html',
    version => '1.00',
    registry => {
        callbacks => {
             'template_source.edit_entry' => {
                 handler => \&_app_template_source_custumSort5,
                 priority => 10,
            },
        },
    }
});

MT->add_plugin($plugin);

sub _app_template_source_custumSort5 {
	my ($eh, $app, $tmpl_ref) = @_;
	my $custumSort= <<HTML;
<mt:setvarblock name="jq_js_include" append="1">
var custumSort5_sort_filed = new Array;
for(var key in customizable_fields){
	if(customizable_fields[key]=="tags" || customizable_fields[key]=='excerpt' || customizable_fields[key]=='keywords')continue
	if(customizable_fields[key]=="category" || customizable_fields[key]=="publishing")break
	custumSort5_sort_filed.push(customizable_fields[key]+"-field")
}
custumSort5_sort_filed.sort()

var custumSort5_cus = document.getElementById("customfield_beacon");
for(var key in custumSort5_sort_filed){
	var custumSort5_e = document.getElementById(custumSort5_sort_filed[key])
	if(custumSort5_e){
		custumSort5_cus.parentNode.insertBefore(custumSort5_e,custumSort5_cus)
	}
}


</mt:setvarblock>
HTML
	
	$$tmpl_ref = $custumSort . $$tmpl_ref;
	
}

1;