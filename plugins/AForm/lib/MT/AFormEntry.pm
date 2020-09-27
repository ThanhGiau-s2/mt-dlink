# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package MT::AFormEntry;

use strict;

use MT::Object;
@MT::AFormEntry::ISA = qw(MT::Object);
__PACKAGE__->install_properties({
	column_defs => {
                'id' => 'integer not null auto_increment',
		'aform_id' => 'integer not null',
		'blog_id' => 'integer not null',
		'entry_id' => 'integer not null',
        'type' => 'string(255)',
	},
	indexes => {
		'aform_id' => 1,
		'blog_id' => 1,
		'entry_id' => 1,
        'type' => 1,
	},
        defaults => {
            'type' => 'entry',
        },
	audit => 1,
	datasource => 'aform_entry',
	primary_key => 'id'
});

1;

