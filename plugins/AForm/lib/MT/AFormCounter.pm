# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package MT::AFormCounter;

use strict;

use MT::Object;
@MT::AFormCounter::ISA = qw(MT::Object);
__PACKAGE__->install_properties({
	column_defs => {
		'id' => 'integer not null auto_increment',
                'aform_id' => 'integer not null',
		'aform_url' => 'string(255) not null',
		'confirm_pv' => 'integer not null',
		'complete_pv' => 'integer not null',
	},
	indexes => {
		'id' => 1,
                'aform_id' => 1,
                'aform_url' => 1,
	},
        defaults => {
		'confirm_pv' => 0,
		'complete_pv' => 0,
        },
	audit => 1,
	datasource => 'aform_counter',
	primary_key => 'id'
});

1;

