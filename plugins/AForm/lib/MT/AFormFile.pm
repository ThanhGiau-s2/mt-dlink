# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package MT::AFormFile;

use strict;

use MT::Object;
@MT::AFormFile::ISA = qw(MT::Object);
__PACKAGE__->install_properties({
	column_defs => {
		'id' => 'integer not null auto_increment',
                'aform_id' => 'integer not null',
                'field_id' => 'integer not null',
                'aform_data_id' => 'integer not null',
		'upload_id' => 'string(255) not null',
		'orig_name' => 'string(255) not null',
		'size' => 'integer not null',
		'size_text' => 'string(255) not null',
                'ext' => 'string(255)',
	},
	indexes => {
		'id' => 1,
                'aform_id' => 1,
                'field_id' => 1,
                'aform_data_id' => 1,
                'upload_id' => 1,
		'orig_name' => 1,
                'ext' => 1,
	},
        defaults => {
        },
	audit => 1,
	datasource => 'aform_file',
	primary_key => 'id'
});

sub get_path {
    my $obj = shift;

    return sprintf("%03d/%0d-%0d-%s%s", 
        $obj->aform_id, 
        $obj->aform_data_id, 
        $obj->field_id, 
        $obj->upload_id, 
        $obj->ext);
}

1;

