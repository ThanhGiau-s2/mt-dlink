# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package MT::AFormSalesforce;

use strict;

use MT::Object;
@MT::AFormSalesforce::ISA = qw(MT::Object);
__PACKAGE__->install_properties({
    column_defs => {
        'id' => 'integer not null auto_increment',
        'form_id' => 'integer',
        'enable'  => 'integer',
        'enable_case' => 'integer',
        'checkbox_fields' => 'text',
        'send_to_sandbox' => 'integer',
    },
    indexes => {
        'id' => 1,
        'form_id' => 1,
        'enable'  => 1,
        'enable_case' => 1,
        'send_to_sandbox' => 1,
    },
    defaults => {
        'enable' => 0,
        'enable_case' => 0,
        'send_to_sandbox' => 0,
    },
    audit => 1,
    datasource => 'aform_salesforce',
    primary_key => 'id'
});

1;

