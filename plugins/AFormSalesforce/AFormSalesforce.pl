package MT::Plugin::AFormSalesforce;

use strict;
use utf8;
use MT;
use MT::AFormSalesforce;

use vars qw( $VERSION $SCHEMA_VERSION);
$VERSION = '1.2.2';
$SCHEMA_VERSION = '1.007';

use base qw( MT::Plugin );

###################################### Init Plugin #####################################

my $plugin = new MT::Plugin::AFormSalesforce({
    id => 'AFormSalesforce',
    name => 'AFormSalesforce',
    author_name => 'ARK-Web\'s MT Plugin Developers',
    author_link => 'http://www.ark-web.jp/',
    version => $VERSION,
    schema_version => $SCHEMA_VERSION,
    description => 'This plugin adds functions to send salesforce web-to-lead api from posted data for A-Form.',
	l10n_class => 'AFormSalesforce::L10N',
    object_classes => [
        'MT::AFormSalesforce',
    ],
    system_config_template => 'system_config.tmpl',
    settings => new MT::PluginSettings([
      ['salesforce_web_to_lead_oid', { Default => '', Scope => 'system' }],
    ]),
});
MT->add_plugin($plugin);


sub init_registry {
    my $plugin = shift;
    $plugin->registry({
        'backup_instructions' => {
            'aform_salesforce' => { 'skip' => 1 },
        },
        'object_types' => {
            'aform_salesforce' => 'MT::AFormSalesforce',
        },
        callbacks => {
            'aform_salesforce_template_source_edit_aform' => {
                callback => 'MT::App::CMS::template_source.edit_aform',
                handler => \&hdlr_template_source_edit_aform,
            },
            'aform_salesforce_aform_after_save_aform' => {
                callback => 'aform_after_save_aform',
                handler => \&hdlr_aform_after_save_aform,
            },
            'aform_salesforce_aform_after_store' => {
                callback => 'aform_after_store',
                handler => \&hdlr_aform_after_store,
            },
            'aform_salesforce_aform_post_remove' => {
                callback => 'MT::AForm::post_remove',
                handler => \&hdlr_aform_post_remove,
            },
        },
    });
}

sub hdlr_template_source_edit_aform {
    my ($cb, $app, $tmpl_ref) = @_;

    my $aform_salesforce = MT::AFormSalesforce->load({form_id => $app->param('id')});
    my $checked = ($aform_salesforce && $aform_salesforce->enable) ? "checked" : "";
    my $setting_title = $plugin->translate("Salesforce Setting");
    my $setting_label = $plugin->translate("To add posted datas as the lead in Salesforce");
    my $case_checked = ($aform_salesforce && $aform_salesforce->enable_case) ? "checked" : "";
    my $case_setting_label = $plugin->translate("To add posted datas as the case in Salesforce");
    my $checkbox_fields = ($aform_salesforce && $aform_salesforce->checkbox_fields) ? $aform_salesforce->checkbox_fields : "emailOptOut,faxOptOut,doNotCall";
    my $checkbox_fields_label = $plugin->translate("Send as type of checkbox");
    my $checkbox_fields_description = $plugin->translate("Please input parts IDs by CSV format.");
    my $send_to_title = $plugin->translate("Post to");
    my $send_to_sandbox_0_label = $plugin->translate("Post to Production enviroment");
    my $send_to_sandbox_1_label = $plugin->translate("Post to Sandbox enviroment");
    my $send_to_sandbox_0_checked = ($aform_salesforce && $aform_salesforce->send_to_sandbox) ? '' : 'checked="checked"';
    my $send_to_sandbox_1_checked = ($aform_salesforce && $aform_salesforce->send_to_sandbox) ? 'checked="checked"' : '';

    my $mtml =<<EOF;
<fieldset>
  <h3>$setting_title</h3>
  <div>
  <mtapp:setting
    id="aform_salesforce_send_to_sandbox"
    label="$send_to_title">
    <input type="radio" class="mt-switch" name="aform_salesforce_send_to_sandbox" id="check_aform_salesforce_send_to_sandbox_0" value="0" $send_to_sandbox_0_checked />
    <label for="check_aform_salesforce_send_to_sandbox_0"><__trans phrase="$send_to_sandbox_0_label"></label>
    &nbsp;
    <input type="radio" class="mt-switch" name="aform_salesforce_send_to_sandbox" id="check_aform_salesforce_send_to_sandbox_1" value="1" $send_to_sandbox_1_checked />
    <label for="check_aform_salesforce_send_to_sandbox_1"><__trans phrase="$send_to_sandbox_1_label"></label>
  </mtapp:setting>
  <mtapp:setting
    id="aform_salesforce_enable"
    label="$setting_label"
    label_for="check_aform_salesforce_enable">
    <input type="checkbox" class="mt-switch" name="aform_salesforce_enable" id="check_aform_salesforce_enable" value="1" $checked />
    <label for="check_aform_salesforce_enable"><__trans phrase="$setting_label"></label>
  </mtapp:setting>
  <mtapp:setting
    id="aform_salesforce_enable_case"
    label="$case_setting_label"
    label_for="check_aform_salesforce_enable_case">
    <input type="checkbox" class="mt-switch" name="aform_salesforce_enable_case" id="check_aform_salesforce_enable_case" value="1" $case_checked />
    <label for="check_aform_salesforce_enable_case"><__trans phrase="$case_setting_label"></label>
  </mtapp:setting>
  <mtapp:setting
    id="aform_salesforce_checkbox_fields"
    label="$checkbox_fields_label"
    hint="$checkbox_fields_description" 
    show_hint="1">
    <input type="text" class="form-control" name="aform_salesforce_checkbox_fields" value="$checkbox_fields" />
  </mtapp:setting>
  </div>
</fieldset>
EOF
    my $pattern = quotemeta('<mt:include name="include/actions_bar.tmpl" bar_position="bottom" hide_pager="1" settings_bar="1">');
    $$tmpl_ref =~ s/($pattern)/$mtml$1/;
}

sub hdlr_aform_after_save_aform {
    my ($cb, $app, $aform_id) = @_;

    my $aform_salesforce = MT::AFormSalesforce->load({form_id => $aform_id});
    if (!$aform_salesforce) {
        $aform_salesforce = MT::AFormSalesforce->new;
    }
    $aform_salesforce->set_values({
        'form_id' => $aform_id,
        'enable'  => $app->param('aform_salesforce_enable') || 0,
        'enable_case' => $app->param('aform_salesforce_enable_case') || 0,
        'checkbox_fields' => $app->param('aform_salesforce_checkbox_fields') || '',
        'send_to_sandbox' => $app->param('aform_salesforce_send_to_sandbox') || 0,
    });
    $aform_salesforce->save
        or return $app->error($aform_salesforce->errstr);

    return 1;
}

sub hdlr_aform_after_store {
    my ($cb, $aform_id, $fields, $app, $aform_data) = @_;

    my $aform_salesforce = MT::AFormSalesforce->load({form_id => $aform_id});
    if (!$aform_salesforce || (!$aform_salesforce->enable && !$aform_salesforce->enable_case)) {
        return 1;
    }
    my $oid = $plugin->get_config_value('salesforce_web_to_lead_oid');
    if ($oid eq "") {
        MT->log({message => 'salesforce_web_to_lead_oid is null'});
        return 0;
    }

    # checkbox fields
    my @checkbox_fields = split(",", $aform_salesforce->checkbox_fields);

    # post to salesforce
    my %form_data;
    my @values = _csv_to_array($aform_data->values);
    my $data_id = shift @values;	# skip data_id
    shift @values;	# skip datetime
    my @fields = MT::AFormField->load({'aform_id' => $aform_id}, {sort => 'sort_order'});
    foreach my $field (@fields) {
        if( $field->type eq 'label' || $field->type eq 'note' ){
            next;
        }
        my $val = shift @values;
        if (grep {$_ eq $field->parts_id} @checkbox_fields) {
            $form_data{$field->parts_id} = $val ne '' ? 1 : 0;
        } else {
            $form_data{$field->parts_id} = $val;
        }
    }

    if ($aform_salesforce->enable) {
        &_post_to_salesforce_lead($oid, $aform_data, $data_id, $aform_salesforce->send_to_sandbox, %form_data);
    }
    if ($aform_salesforce->enable_case) {
        &_post_to_salesforce_case($oid, $aform_data, $data_id, $aform_salesforce->send_to_sandbox, %form_data);
    }

    return 1;
}

sub _post_to_salesforce_lead {
    my ($oid, $aform_data, $data_id, $send_to_sandbox, %form_data) = @_;

    use LWP::UserAgent;
    use HTTP::Request::Common qw(POST);

    $form_data{"oid"} = $oid;
    my $domain = $send_to_sandbox ? 'test.salesforce.com' : 'webto.salesforce.com';
    my $url = 'https://'. $domain .'/servlet/servlet.WebToLead?encoding=UTF-8';
    my $request = POST($url, [%form_data]);
    my $ua = LWP::UserAgent->new;
    if (!( eval{ require Mozilla::CA; 1 } )) {
#        MT->log('AFormSalesforce required Mozilla::CA.');
        $ua->ssl_opts(verify_hostname => 0);
    }
    else {
        $ua->ssl_opts(
            verify_hostname => 1,
            SSL_version => 'SSLv23:!SSLv3:!SSLv2',
            SSL_ca_file => Mozilla::CA::SSL_ca_file(),
        );
    }
    my $res = $ua->request($request);
    if (!$res || !$res->is_success) {
        MT->log({message => 'failed to post salesforce lead. ' . $res->as_string});
        return 0;
    }
    MT->log({message => 'AFormSalesforce: web_to_lead success. ' . "POST to $url\n AFormID:". $aform_data->aform_id . " DataID:". $data_id});
    return 1;
}

sub _post_to_salesforce_case {
    my ($oid, $aform_data, $data_id, $send_to_sandbox, %form_data) = @_;

    use LWP::UserAgent;
    use HTTP::Request::Common qw(POST);

    $form_data{"orgid"} = $oid;
    my $domain = $send_to_sandbox ? 'test.salesforce.com' : 'webto.salesforce.com';
    my $url = 'https://'. $domain .'/servlet/servlet.WebToCase?encoding=UTF-8';
    my $request = POST($url, [%form_data]);
    my $ua = LWP::UserAgent->new;
    if (!( eval{ require Mozilla::CA; 1 } )) {
#        MT->log('AFormSalesforce required Mozilla::CA.');
        $ua->ssl_opts(verify_hostname => 0);
    }
    else {
        $ua->ssl_opts(
            verify_hostname => 1,
            SSL_version => 'SSLv23:!SSLv3:!SSLv2',
            SSL_ca_file => Mozilla::CA::SSL_ca_file(),
        );
    }
    my $res = $ua->request($request);
    if (!$res || !$res->is_success) {
        MT->log({message => 'failed to post salesforce case. ' . $res->as_string});
        return 0;
    }
    MT->log({message => 'AFormSalesforce: web_to_case success. ' . "POST to $url\n AFormID:". $aform_data->aform_id . " DataID:". $data_id});
    return 1;
}

sub hdlr_aform_post_remove {
  my( $eh, $aform ) = @_;

  my @aform_salesforces = MT::AFormSalesforce->load({
        form_id => $aform->id,
  });
  foreach my $aform_salesforce ( @aform_salesforces ){
    $aform_salesforce->remove;
  }
  return 1;
}

sub _csv_to_array {
  my $csv = shift;

  $csv .= ',';
  my @values = map {/^"(.*)"$/s ? scalar($_ = $1, s/""/"/g, $_) : $_}
                ($csv =~ /("[^"]*(?:""[^"]*)*"|[^,]*),/g);

  return @values;
}

1;

