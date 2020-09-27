# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package MT::AFormInputError;

use strict;

use MT::Object;
@MT::AFormInputError::ISA = qw(MT::Object);
__PACKAGE__->install_properties({
	column_defs => {
		'id' => 'integer not null auto_increment',
		'type' => 'string(20) not null',
                'aform_id' => 'integer not null',
		'aform_url' => 'string(255) not null',
		'field_id' => 'integer not null',
		'field_label' => 'text',
                'error_value' => 'text',
		'error_ip' => 'string(30)',
	},
	indexes => {
		'id' => 1,
		'type' => 1,
                'aform_id' => 1,
                'aform_url' => 1,
	},
        defaults => {
        },
	audit => 1,
	datasource => 'aform_input_error',
	primary_key => 'id'
});

1;

