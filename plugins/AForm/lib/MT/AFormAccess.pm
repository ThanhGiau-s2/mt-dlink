# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package MT::AFormAccess;

use strict;

use MT::Object;
@MT::AFormAccess::ISA = qw(MT::Object);
__PACKAGE__->install_properties({
	column_defs => {
		'id' => 'integer not null auto_increment',
                'aform_id' => 'integer not null',
		'aform_url' => 'string(255) not null',
		'session' => 'integer not null',
		'pv' => 'integer not null',
        'cv' => 'integer not null',
	},
	indexes => {
		'id' => 1,
                'aform_id' => 1,
                'aform_url' => 1,
	},
        defaults => {
		'session' => 0,
		'pv' => 0,
        'cv' => 0,
        },
	audit => 1,
	datasource => 'aform_access',
	primary_key => 'id'
});

1;

