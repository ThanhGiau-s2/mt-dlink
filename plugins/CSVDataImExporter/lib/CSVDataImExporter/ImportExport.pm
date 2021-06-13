package CSVDataImExporter::ImportExport;
use strict;

use base qw(MT::ErrorHandler);

use utf8;
use Devel::Peek;
use Encode;
use Encode::Guess;
use MT::I18N qw( encode_text guess_encoding );
use MT::I18N qw( const encode_text );
use MT::Placement;
use MT::Tag;
use MT::ImportExport;
use MT::ContentData;
use MT::Serialize;

use Data::Dumper;

my $SEPARATOR_NAMES = [
    { 'name' => 'comma', 'separator_name' => 'CAMMA' },
    { 'name' => 'tab', 'separator_name' => 'TAB' },
    { 'name' => 'semicolon', 'separator_name' => 'SEMICOLON' },
    { 'name' => 'space', 'separator_name' => 'SPACE' },
];


my $separator = ',';
my $category_separator = '--';

my $same_data = {
    1 => 'basename',
    2 => 'title'
};

my $same_data_cd = {
    1 => 'identifier',
    2 => 'label'
};

sub SEPARATOR_NAMES () {
    return $SEPARATOR_NAMES;
}

sub get_param {
    my ($blog_id) = shift;
    my $blog = MT::Blog->load($blog_id)
        or return;

    my $param;
    my $plugin = MT->component("CSVDataImExporter");
    my $imexport_character = get_imexport_character( $plugin, $blog_id );
    $param->{imexport_character} = $plugin->translate( $imexport_character );
    $param;
}

sub get_imexport_character {
    my $plugin = shift;
    my $blog_id = shift;
    my $imexport_character = $plugin->get_config_value('imexport_character', 'blog:' . $blog_id);
    if ( $imexport_character eq 'system' ) {
        $imexport_character = $plugin->get_config_value('imexport_character_system', 'system') || 0;
    }
    return $imexport_character;
}

sub get_line_feed_code {
    my $plugin = shift;
    my $blog_id = shift;
    my $line_feed_code = $plugin->get_config_value('line_feed_code', 'blog:' . $blog_id);
    if ( $line_feed_code == 2 ) {
        $line_feed_code = $plugin->get_config_value('line_feed_code_system', 'system') || 0;
    }
    return $line_feed_code;
}

sub get_asset_upload {
    my $plugin = shift;
    my $blog_id = shift;
    my $asset_upload = $plugin->get_config_value('asset_upload', 'blog:' . $blog_id);
    if ( $asset_upload eq 'system' ) {
        $asset_upload = $plugin->get_config_value('asset_upload_system', 'system') || 0;
    }
    return $asset_upload;
}

sub get_is_revision {
    my $plugin = shift;
    my $blog_id = shift;
    my $is_revision = $plugin->get_config_value('is_revision', 'blog:' . $blog_id);
    if ( $is_revision eq 'system' ) {
        $is_revision = $plugin->get_config_value('is_revision_system', 'system') || 0;
    }
    return $is_revision;
}

sub is_value {
    my $plugin = shift;
    my $blog_id = shift;
    my $type = shift;
    my $is_value = $plugin->get_config_value($type, 'blog:' . $blog_id);
    if ( $is_value == 2 ) {
        $is_value = $plugin->get_config_value($type . '_system', 'system') || 0;
    }
    return $is_value;
}

sub import_contents {
    my $class = shift;
    my %param = @_;

    ## Init error buffer.
    __PACKAGE__->error();

    my $plugin = MT->component("CSVDataImExporter");

    my $iter = $param{Iter};
    my $blog = $param{Blog}
        or return __PACKAGE__->error( MT->translate("No Blog") );
    my $cb = $param{Callback} || sub { };
    my $encoding = $param{Encoding};

    my $blog_id = $blog->id;

    my $import_result = eval {
        while ( my $stream = $iter->() ) {
            my $result = eval { $class->start_csv_import( $stream, %param ); };
            $cb->($@) unless $result;
        }
        $class->errstr ? undef : 1;
    };

    $import_result;
}

sub import_contents_cd {
    my $class = shift;
    my %param = @_;

    ## Init error buffer.
    __PACKAGE__->error();

    my $plugin = MT->component("CSVDataImExporter");

    my $iter = $param{Iter};
    my $blog = $param{Blog}
        or return __PACKAGE__->error( MT->translate("No Blog") );
    my $cb = $param{Callback} || sub { };
#    my $encoding = $param{Encoding};

    my $blog_id = $blog->id;

    my $import_result = eval {
        while ( my $stream = $iter->() ) {
            my $result = eval { $class->start_csv_import_cd( $stream, %param ); };
            $cb->($@) unless $result;
        }
        $class->errstr ? undef : 1;
    };

    $import_result;
}

sub start_csv_import {
    my $class = shift;
    my ( $stream, %param ) = @_;

my $app = MT->instance;

my $blog_id = $param{Blog}->id;

    my $plugin = MT->component("CSVDataImExporter");
    my $imexport_character = get_imexport_character( $plugin, $blog_id );
    my $is_cloud = $plugin->get_config_value('is_cloud', 'system') || 0;
    my $is_revision = get_is_revision( $plugin, $blog_id );

my $req = MT::Request->instance() unless $is_cloud;

    my $line_feed_code = get_line_feed_code( $plugin, $blog_id );
    my @data;
    if ( $line_feed_code ) {
        my $content = do { local $/; <$stream> };
        $content =~ s/\r/\r\n/g;
        @data = split(/\r\n/, $content);
    }

    my $buf;
    my @file;
    my $counter = 0;

    if ( $line_feed_code ) {
        foreach my $tmp (@data) {
            $tmp = encode_text($tmp, $imexport_character, 'utf-8');
            $buf .= $tmp;
            next if ($buf =~ s/"/"/g) % 2;
            chomp $buf;
            $buf =~ s/^\xef\xbb\xbf// unless $counter;
            push( @file, $buf );
            $buf = "";
            $counter++;
        }
    } else {
        foreach my $tmp (<$stream>) {
            $tmp = encode_text($tmp, $imexport_character, 'utf-8');
            $buf .= $tmp;
            next if ($buf =~ s/"/"/g) % 2;
            chomp $buf;
            $buf =~ s/^\xef\xbb\xbf// unless $counter;
            push( @file, $buf );
            $buf = "";
            $counter++;
        }
    }

    my @customfields;
    my $meta;
    my $header = 0;
    my %flag;
    my %pos;

    my @values = _get_data(shift(@file), $separator);
    $values[$#values] =~ s/\\//;

#    my $plugin = MT->component("CSVDataImExporter");

    my $error = 0;
    my $warning = 0;
    my $counter = 2;
    $param{Callback}->( $plugin->translate('The check of the number of CSV columns is started...') . "\n" );

    foreach my $tmp (@file) {
        my @data = _get_data($tmp, $separator);
        if ($#data != $#values) {
            $param{Callback}->( '*** ' . $counter . $plugin->translate('The number of items of CSV data([_1]) does not suit the number of items of a header([_2]). This error is outputted also when there is no data in the last column.', $#data, $#values) . "\n" );
        }
        for my $i (0 .. $#data) {
#            $error |= _check( $values[$i], $data[$i], $counter, $param{Callback} );
        }
        $counter++;
    }
    if ($error) {
        $param{Callback}->( $plugin->translate('Import is stopped because CSV data has an error.') . "\n" );
        return $class->error( $plugin->translate('Import is stopped because CSV data has an error.') );
    }
    $param{Callback}->( $plugin->translate('The check of CSV data was completed normally.') . "\n" );

    $param{Callback}->( $plugin->translate('Import of CSV data is started...') . "\n" );

    foreach my $tmp (@file) {
        my @data = _get_data($tmp, $separator);
        $data[$#data] =~ s/\\$//;

        # get data
        my $buf = '';
        my @categories;
        my @assets;
        my $fieldcount = 0;

        my $entry;
        my $class;
        my $class_type;
        my $author_name;
        my $col;
        my $new = 0;
        my $skip = 0;
        my @asset_ids;

        # for cf_image
        my $cf_assets;
        my $cf_asset_basename;

        for my $i (0 .. $#data) {
            if ($values[$i] eq 'class') {
                $class = $data[$i] eq 'entry' ? $app->model('entry') : $app->model('page');
                next;
            }

            if ($values[$i] eq 'id') {
                if (!$data[$i]) {
                    if ($param{null_id_process}) {
                        my $same = $same_data->{$param{null_id_process}};
                        for my $j (0 .. $#data) {
                            if ($values[$j] eq $same) {
                                $entry = $class->load( { blog_id => $blog_id, $same => $data[$j] } );
                                if (!$entry) {
                                    $entry = $class->new;
                                    $new = 1;
                                }
                                last;
                            }
                        }
                    } else {
                        $entry = $class->new;
                        $new = 1;
                    }
                } else {
                    $entry = $class->load( { blog_id => $blog_id, id => $data[$i] } );
                    if (!$entry) {
                        if (!$param{no_id_process}) {
                            $param{Callback}->( "ID:$data[$i] " . $plugin->translate('Processing is skipped because there is no applicable entry.') . "\n" );
                            $skip = 1;
                            last;
                        } else {
                            $entry = $class->new;
                            $new = 1;
                        }
                    } else {
                        if ($param{same_id_process}) {
                            my $id = $entry->id;
                            $param{Callback}->( "ID:$data[$i] " . $plugin->translate('Update is skipped because there is applicable entry.') . "\n" );
                            $skip = 1;
                            last;
                        }
                    }
                }
                $class_type = $entry->class;
                next;
            }

            if ($values[$i] eq 'title' ||
                $values[$i] eq 'status' ||
                $values[$i] eq 'text' ||
                $values[$i] eq 'text_more' ||
                $values[$i] eq 'excerpt' ||
                $values[$i] eq 'keywords' ||
                $values[$i] eq 'allow_comments' ||
                $values[$i] eq 'allow_pings' ||
                $values[$i] eq 'basename') {

                $data[$i] = 1 if ($values[$i] eq 'status' && !$data[$i]);
                $data[$i] = 1 if ($values[$i] eq 'allow_comments' && !$data[$i]);
                $data[$i] = 1 if ($values[$i] eq 'allow_pings' && !$data[$i]);

                $col = $values[$i];
                if ($data[$i]) {
                    $entry->$col($data[$i]);
                }
                next;

            } elsif ($values[$i] eq 'convert_breaks') {
                $entry->convert_breaks( scalar $data[$i] );
                next;

            } elsif ($values[$i] eq 'author') {
                $author_name = $data[$i];
                next;
            } elsif ($values[$i] eq 'authored_on') {
                $entry->authored_on(_convert_date($data[$i]));
                next;
            } elsif ($values[$i] eq 'modified_on') { # Only update
                $entry->modified_on(_convert_date($data[$i])) if !$new;
                next;
            } elsif ($values[$i] eq 'unpublished_on') { # Only update
                if ( $data[$i] ) {
                    $entry->unpublished_on(_convert_date($data[$i]));
                } else {
                    $entry->unpublished_on( undef );
                }
                next;
            } elsif ($values[$i] eq 'tags') {
                if ($data[$i]) {
                    my @tags = split(/,/, $data[$i]);
                    $entry->remove_tags();
                    $entry->tags(@tags);
                }
                next;
            } elsif ($values[$i] eq 'categories') {
                if ($data[$i]) {
                    @categories = split(/,/, $data[$i]);
                }
                next;
            } elsif ($values[$i] eq 'assets') {
                if ($data[$i]) {
                    @assets = split(/,/, $data[$i]);
                }
                next;
            } else {

                my $field_basename = $values[$i];
                my $val = $data[$i];

                my $field;
                if ($is_cloud) {
                    $field = MT->model('field')->load(
                        {   basename => $field_basename,
                            blog_id  => [ 0, $blog_id ]
                        }
                    );
                } else {
                    $field = $req->cache( $field_basename . $blog_id );
                    unless ($field) {
                        $field = MT->model('field')->load(
                            {   basename => $field_basename,
                                blog_id  => [ 0, $blog_id ]
                            }
                        );
                        $req->cache( $field_basename . $blog_id, $field )
                            if $field;
                    }
                }

                my $field_name = 'field.' . $field_basename;
                next unless $entry->has_meta($field_name);
                if ( $field->type eq 'datetime' ) {
                    if ( $val ) {
                        $val = _convert_date($val);
                    } else {
                        undef $val;
                    }
                } else {
                    if ($field->type eq 'file' || 
                        $field->type eq 'image' ||
                        $field->type eq 'audio' ||
                        $field->type eq 'video') {
                        (my $asset_id = $val) =~ s/.*asset-id="(\d+)".*/$1/;

                        if ($asset_id =~ /^\d+$/) {
                            push(@asset_ids, $asset_id);
                        } else {

                            # for cf_image
                            $cf_assets->{$field_basename}->{data} = $val;
                            $cf_assets->{$field_basename}->{type} = $field->type;
                        }
                    }
                }
                $entry->$field_name($val);
            }
        }

        unless ($skip) {

            # new entry
            if ($new) {
#                my $author = MT::Author->load( { name => $author_name } );

                my $author;
                if ($is_cloud) {
                    $author = MT->model('author')->load(
                        { name => $author_name }
                    );
                } else {
                    $author = $req->cache( "author" . $author_name );
                    unless ($author) {
                        $author = MT->model('author')->load(
                            { name => $author_name }
                        );
                        $req->cache("author" . $author_name, $author )
                            if $author;
                    }
                }

                unless ($author) {
                    $param{Callback}->( $plugin->translate('Import is stopped because the user([_1]) is not registered.', $author_name) . "\n" );
                    return $class->error( $plugin->translate('Import is stopped because the user([_1]) is not registered.', $author_name) );
                }
                $entry->author_id($author->id);

                my $blog;
                if ($is_cloud) {
                    $blog = MT->model('blog')->load(
                        { id => $blog_id }
                    );
                } else {
                    $blog = $req->cache( "blog" . $blog_id );
                    unless ($blog) {
                        $blog = MT->model('blog')->load(
                            { id => $blog_id }
                        );
                        $req->cache("blog" . $blog_id, $blog )
                            if $blog;
                    }
                }

                unless ($blog) {
                    $param{Callback}->( $plugin->translate('Import is stopped because blog_id([_1]) is not registered.', $blog_id ) . "\n" );
                    return $class->error( $plugin->translate('Import is stopped because blog_id([_1]) is not registered.', $blog_id ) );
                }
                $entry->blog_id( $blog_id );
            } else {
                my $author = MT::Author->load( { name => $author_name } );
                if ($author) {
                    $entry->author_id($author->id);
                }
            }

            # for cf_image
            if ( $cf_assets ) {
                for my $cf_asset ( keys %{$cf_assets} ) {
                    my ( $asset_id, $url ) = _add_cf_asset_to_entry($blog_id, $entry->id, $cf_assets->{$cf_asset}->{data}, $param{Callback});
                    next if !$asset_id;
                    my $form;
                    my $asset = MT->model('asset')->load($asset_id);
                    my $filename = $asset->file_name;
                    if ( $cf_assets->{$cf_asset}->{type} eq 'image' ) {
                        my $message = $plugin->translate('display');
                        $form = qq{<form mt:asset-id="$asset_id" class="mt-enclosure mt-enclosure-image" style="display: inline;"><a href="$url">$message</a></form>};
                    } elsif ( $cf_assets->{$cf_asset}->{type} eq 'audio' ) {
                        $form = qq{<form mt:asset-id="$asset_id" class="mt-enclosure mt-enclosure-audio" style="display: inline;"><a href="$url">$filename</a></form>};
                    } elsif ( $cf_assets->{$cf_asset}->{type} eq 'video' ) {
                        $form = qq{<form mt:asset-id="$asset_id" class="mt-enclosure mt-enclosure-video" style="display: inline;"><a href="$url">$filename</a></form>};
                    } else {
                        $form = qq{<form mt:asset-id="$asset_id" class="mt-enclosure mt-enclosure-image" style="display: inline;"><a href="$url">$filename</a></form>};
                    }
                    my $field_name = 'field.' . $cf_asset;
                    $entry->$field_name($form);
                    $param{Callback}->( $plugin->translate('Entry([_1]) and CF Asset([_2]) are associated.', $entry->id, $asset_id) . '<br />' );
                }
            }

            $entry->save or $param{Callback}->( $entry->errstr . "\n" ); #die $entry->errstr;

            if ( $is_revision ) {
                my $changed_cols = $entry->{changed_revisioned_cols};
                push @$changed_cols, 'for csv';
                $entry->{changed_revisioned_cols} = $changed_cols;
                _mt_postsave_obj( $plugin, $entry );
            }

            my $type = $entry->class eq 'entry' ? MT->translate('Entry') : MT->translate('Page');
            if ($new) {
                 $param{Callback}->( $plugin->translate('Added [_1](ID:[_2])', $type, $entry->id) . "\n" );
            } else {
                 $param{Callback}->( $plugin->translate('Updated [_1](ID:[_2])', $type, $entry->id) . "\n" );
            }
            my $result = _add_category_to_entry( $app, $req, \%param, $entry->id, \@categories, $class_type, $param{Callback} );
            $result = _add_asset_to_entry( $blog_id, $entry->id, \@assets, $param{Callback} );
        }
        undef $entry;
    }
    1;
}

sub _create_category {
    my ($blog_id, $category_label, $category_basename, $parent_category_id, $class_type) = @_;

    my $category_class = MT->model($class_type eq 'entry' ? 'category' : 'folder');

    my $cat = $category_class->new;
    $cat->blog_id($blog_id);
    $cat->label($category_label);
    $cat->basename($category_basename) if $category_basename;
    $cat->parent($parent_category_id);
    $cat->save
      or die $cat->errstr;
    my $cat_id = $cat->id;

    require MT::Blog;
    my $blog = MT::Blog->load($blog_id)
        or return;
    my $meta = $class_type eq 'entry' ? 'category_order' : 'folder_order';
    my @order = split ',', ( $blog->meta( $meta ) || '' );
    unshift @order, $cat->id;
    my $new_order = join ',', @order;
    $blog->meta( $meta, $new_order );
    $blog->save;    # Ignore error.

    undef $cat;

    return $cat_id;
}

sub _add_category_to_entry {
    my ($app, $req, $param, $entry_id, $categories, $class_type, $cb) = @_;

    my $blog_id = $param->{Blog}->id;
    my $category_class = MT->model($class_type eq 'entry' ? 'category' : 'folder');

    # collect current placement
    my $placements = ();
    my @list = MT::Placement->load({ blog_id => $blog_id, entry_id => $entry_id });
    foreach my $obj_asset (@list) {
        my $category_id = $obj_asset->category_id;
        $placements->{$category_id} = 1;
    }
undef @list;

    my $is_primary;
    my $cat;
    my $cat_id;
    my $count = 0;
    my $seen = ();

    my $plugin = MT->component("CSVDataImExporter");

    for my $category_tmp (@{$categories}) {
        my @category_list = ();
        if ($category_tmp =~ /$category_separator/) {
           @category_list = split($category_separator, $category_tmp);
        } else {
           push(@category_list, $category_tmp);
        }
        my $category_count = 0;
        my $parent_categories;
        my $parent_category_id = 0;

        my $message_class = $class_type eq 'entry' ? MT->translate('Category') : MT->translate('Folder');
        for my $category_label (@category_list) {

            my $create = 0;
            my $category_id = '';

            my $category_basename = '';
            if ($category_label =~ /(.*)\((\d+):(.*)\)/) {
                $category_label = $1;
                $category_id = $2;
                $category_basename = $3;

                if($app->param('no_id_process')){
                    $create = 1;
                }
            } elsif ($category_label =~ /(.*)\((\d+)\)/) {
                $category_label = $1;
                $category_id = $2;

                if($app->param('no_id_process')){
                    $create = 1;
                }
            } elsif ($category_label =~ /(.*)\(\:(.*)\)/) {
                $category_label = $1;
                $category_basename = $2;
                $create = 1;
            } elsif ($category_label =~ /(.*)/) {
                $category_label = $1;
                $create = 1;
            }
#            $cat = $req->cache( "cat" . $category_id . $blog_id );

            if (!$create) {
                if (!$category_count) {
                    $cat = $category_class->load({ id => $category_id, blog_id => $blog_id, category_set_id => 0 });
                } else {
                    $cat = $category_class->load( { id => $category_id, parent => $parent_category_id, blog_id => $blog_id, category_set_id => 0 } );
                }
            }

            if ($create) {
                if ($category_basename) {
                    if ($category_count) {
                        $cat = $category_class->load({ label => $category_label, basename => $category_basename, parent => $parent_category_id, blog_id => $blog_id, category_set_id => 0 });
                    } else {
                        $cat = $category_class->load({ label => $category_label, basename => $category_basename, blog_id => $blog_id, category_set_id => 0 });
                    }
                } else {
                    if ($category_count) {
                        $cat = $category_class->load({ label => $category_label, parent => $parent_category_id, blog_id => $blog_id, category_set_id => 0 });
                    } else {
                        $cat = $category_class->load({ label => $category_label, blog_id => $blog_id, category_set_id => 0 });
                    }
                }
                $create = 0 if $cat;
            }

            # カテゴリ作成
            if(!$cat) {
                $category_id = _create_category($blog_id, $category_label, $category_basename, $parent_category_id, $class_type);
                if (!$create) {
                    if ($category_count) {
                        $cb->( $plugin->translate('sub [_1]([_2]) is created.', $message_class , Encode::decode_utf8($category_label)) . "\n" );
                    } else {
                        $cb->( $plugin->translate('\[_1]([_2]) is created.', $message_class , Encode::decode_utf8($category_label)) . "\n" );
                    }
                } else {
                    if ($category_count) {
                        $cb->( $plugin->translate('sub [_1]([_2]) is created.', $message_class , Encode::decode_utf8($category_label)) . "\n" );
                    } else {
                        $cb->( $plugin->translate('\[_1]([_2]) is created.', $message_class , Encode::decode_utf8($category_label)) . "\n" );
                    }
                }
            } else {
                $category_id = $cat->id;
            }

            if (!$category_count) {
                $parent_categories = $category_label;
#                $cb->( $plugin->translate('set category [_1]', $category_label) . "\n" ) if $category_id;
            } else {
                $parent_categories .= '->'.$category_label;
#                $cb->( $plugin->translate('set subcategory [_1] parent category[_2]', $category_label, $parent_categories) . "\n" ) if $category_id;
            }

            # 最下層のサブカテゴリの場合
            if ($category_count == $#category_list) {
                my $place = MT::Placement->load( { entry_id => $entry_id, category_id => $category_id } );
                unless ($place) {
                    use MT::Placement;
                    my $place = MT::Placement->new;
                    $place->entry_id($entry_id);
                    $place->blog_id($blog_id);
                    $place->category_id($category_id);
                    $is_primary = $category_count == $count ? 1 : 0;
                    $is_primary = 1 if $class_type eq 'page'; # for folder
                    $place->is_primary($is_primary);
                    $place->save
                        or die $place->errstr;
                    $cb->( $plugin->translate('Entry([_1]) and [_2]([_3]) are associated.', $entry_id, $message_class, Encode::decode_utf8($parent_categories)) . "\n" );
                } else {
                    $cb->( $plugin->translate('Association of Entry([_1]) and [_2]([_3]) is skipped.', $entry_id, $message_class, $category_id) . "\n" );
                }
                $seen->{$category_id} = 1;
undef $place;
            }
            $parent_category_id = $category_id;
            $count++;
            $category_count++;
undef $cat;
        }
    }

    # clean placement
    foreach my $category_id (keys %{$placements}) {
        unless ($seen->{$category_id}) {
            my $placement = MT::Placement->load({ category_id => $category_id, entry_id => $entry_id });
            $placement->remove;
            $cb->( $plugin->translate('Association of Entry([_1]) and Catgory([_2]) is canceled.', $entry_id, $category_id) . "\n" );
undef $placement;
        }
    }

    return 1;
}

sub _add_asset_to_entry {
    my ($blog_id, $id, $assets, $cb) = @_; # no nessesary class_type

    my $plugin = MT->component("CSVDataImExporter");

    my $obj_assets = ();
    my @obj_assets = MT::ObjectAsset->load({ object_ds => 'entry', object_id => $id });
    foreach my $obj_asset (@obj_assets) {
        my $asset_id = $obj_asset->asset_id;
        $obj_assets->{$asset_id} = 1;
    }
    my $seen = ();
    foreach my $asset_id (@{$assets}) {
        if ($asset_id =~ /.*\((\d+)\)/) {
            $asset_id = $1;
        } else {
            $asset_id = upload($blog_id, $asset_id, $cb);
            next if !$asset_id;
        }
        my $obj_asset = MT::ObjectAsset->load({ asset_id => $asset_id, object_ds => 'entry', object_id => $id });
        unless ($obj_asset) {
            my $obj_asset = new MT::ObjectAsset;
            $obj_asset->blog_id($blog_id);
            $obj_asset->asset_id($asset_id);
            $obj_asset->object_ds('entry');
            $obj_asset->object_id($id);
            $obj_asset->save;
#            $cb->( $plugin->translate('Entry([_1]) and Asset([_2]) are associated.', $id, $asset_id) . "\n" );
        } else {
#            $cb->( $plugin->translate('Association of Entry([_1]) and Asset([_2]) is skipped.', $id, $asset_id) . "\n" );
        }
        $seen->{$asset_id} = 1;
undef $obj_asset;
    }
    foreach my $asset_id (keys %{$obj_assets}) {
        unless ($seen->{$asset_id}) {
            my $obj_asset = MT::ObjectAsset->load({ asset_id => $asset_id, object_ds => 'entry', object_id => $id });
            $obj_asset->remove;
undef $obj_asset;
        }
    }
    return 1;
}

# for cf_image
sub _add_cf_asset_to_entry {
    my ($blog_id, $id, $path, $cb) = @_; # no nessesary class_type

    my $plugin = MT->component("CSVDataImExporter");

    my $asset_id = upload($blog_id, $path, $cb);
    return ( 0, '' ) if !$asset_id;

    my $obj_asset = MT::ObjectAsset->load({ asset_id => $asset_id, object_ds => 'entry', object_id => $id });
    unless ($obj_asset) {
        my $obj_asset = new MT::ObjectAsset;
        $obj_asset->blog_id($blog_id);
        $obj_asset->asset_id($asset_id);
        $obj_asset->object_ds('entry');
        $obj_asset->object_id($id);
        $obj_asset->save;
        $cb->( $plugin->translate('Entry([_1]) and Asset([_2]) are associated.', $id, $asset_id) . "\n" );
    } else {
        $cb->( $plugin->translate('Association of Entry([_1]) and Asset([_2]) is skipped.', $id, $asset_id) . "\n" );
    }
    my $asset = MT::Asset->load( $asset_id );
    return ( $asset_id, $asset->url );
}

sub upload {
    my ($blog_id, $file_path, $cb) = @_;

    return 0 if !$file_path;

    my $plugin = MT->component("CSVDataImExporter");

    my $obj = MT->model('asset')->new();
    $obj->blog_id( $blog_id );

    $file_path =~ s/\\/\//g;
    ( my $file_name = $file_path ) =~ s/^.*\/([^\/]+)$/$1/;

    $obj->file_name( $file_name );

    my $asset_upload = get_asset_upload( $plugin, $blog_id );
    if ( $asset_upload ) {
        $obj->file_path( '%r/assets/' . $file_name );
        $obj->url( '%r/assets/' . $file_name );
    } else {
        $obj->file_path( $file_path );
        my $blog = MT::Blog->load( $blog_id );
        my $site_path = $blog->site_path;
        (my $asset_file = $file_path) =~ s/$site_path\/(.*)/$1/;
        my $url = $blog->site_url . $asset_file;
        utf8::decode($url);
        $obj->url( $url );
    }

    $obj->label( $file_name );

    ( my $ext = $file_path ) =~ s/^.*\.([^.]+)$/$1/;

    $obj->file_ext( $ext );

    if ( $ext =~ /jpg|gif|jpe|jpeg|png|bmp|tif|tiff|ico/i) {
        $obj->class('image');
    } elsif ( $ext =~ /mp3|ogg|aif|aiff|wav|wma|aac|flac|m4a/i) {
        $obj->class('audio');
    } elsif ( $ext =~ /mov|avi|3gp|asf|mp4|qt|wmv|asx|mpg|flv|mkv|ogm/i) {
        $obj->class('video');
    } else {
        $obj->class('file');
    }

    my $mime_type = 'image/' . lc $ext if $obj->class eq 'image';
    $obj->mime_type( $mime_type );

    $obj->save or die $obj->errstr;

    if ( $asset_upload ) {
        require MT::FileMgr;
        my $fmgr = MT::FileMgr->new('Local');

        my $app = MT->instance;

        my $blog = MT::Blog->load({ id => $blog_id });
        my $outdir = File::Spec->catdir( $blog->site_path, 'assets' );
        undef $blog;
        $fmgr->mkpath( $outdir )
            or return $app->error(
                $app->translate(
                    'Failed to make assets directory [_1]',
                    $fmgr->errstr,
            ));

        my $path = File::Spec->catfile( $outdir, $file_name );
        utf8::decode($path);
        utf8::decode($file_path);

        unless (defined $fmgr->put( $file_path, $path, 'upload')) {
            $cb->( $plugin->translate('Registration failure of Asset([_1]).', $file_path) . "\n" );
            $app->log(
                    $app->translate(
                        'Failed to publish asset file [_1]',
                        $fmgr->errstr,
                ));
            return 0;
        }
        undef $fmgr;
    }
    $cb->( $plugin->translate('Asset([_1]) is registered.', $file_path) . "\n" );

    my $id = $obj->id;
    undef $obj;
    return $id;
}

sub _check {
    my ($value, $data, $counter, $cb) = @_;
    my $plugin = MT->component("CSVDataImExporter");
    if ($value eq 'class') {
        if (!($data eq 'page' || $data eq 'entry')) {
        $cb->( '*** ' . $counter . ':' . $plugin->translate('wrong class specification ([_1])', $data) . "\n" );
            return 1;
        }
    }
    elsif ($value eq 'id') {
        if ($data && ($data !~ /\d+/)) {
            $cb->( '*** ' . $counter . ':' . $plugin->translate('character([_1]) which is not a number is specified as id.', $data) . "\n" );
            return 1;
        }
    }
    elsif ($value eq 'author') {
        my $author = MT::Author->load( { name => $data } );
        unless ($author) {
            $cb->( '*** ' . $counter . ':' . $plugin->translate('user who specified it as author([_1]) is not registered.', $data) . "\n" );
            return 1;
        }
    }
    elsif ($value eq 'status') {
        if (!($data == 1 || $data == 2 || $data == 4)) {
            $cb->( '*** ' . $counter . ':' . $plugin->translate('wrong value([_1]) of status.', $data) . "\n" );
            return 1;
        }
    }
    elsif ($value eq 'authored_on') {
        if (!($data =~ /\d{14}|\d{4}-\d+-\d+T\d+:\d+:\d+\.\d{3}|\d{4}-\d+-\d+\s\d+:\d+:\d+|\d{4}\/\d+\/\d+\s\d+:\d{2}|\d{4}\.\d+\.\d+\s\d+:\d{2}/)) {
            $cb->( '*** ' . $counter . ':' . $plugin->translate('wrong value([_1]) of authored_on.', $data) . "\n" );
            return 1;
        }
    }
    elsif ($value eq 'modified_on') {
        if (!($data =~ /\d{14}|\d{4}-\d+-\d+T\d+:\d+:\d+\.\d{3}|\d{4}-\d+-\d+\s\d+:\d+:\d+|\d{4}\/\d+\/\d+\s\d+:\d{2}|\d{4}\.\d+\.\d+\s\d+:\d{2}/)) {
            $cb->( '*** ' . $counter . ':' . $plugin->translate('wrong value([_1]) of modified_on.', $data) . "\n" );
            return 1;
        }
    }
    elsif ($value eq 'unpublished_on') {
        if (!($data =~ /\d{14}|\d{4}-\d+-\d+T\d+:\d+:\d+\.\d{3}|\d{4}-\d+-\d+\s\d+:\d+:\d+|\d{4}\/\d+\/\d+\s\d+:\d{2}|\d{4}\.\d+\.\d+\s\d+:\d{2}/)) {
            $cb->( '*** ' . $counter . ':' . $plugin->translate('wrong value([_1]) of unpublished_on.', $data) . "\n" );
            return 1;
        }
    }
    elsif ($value eq 'convert_breaks') {
        if (!($data eq '0' || $data eq '1' || $data eq '__default__' || $data eq 'richtext' ||
              $data eq 'markdown' || $data eq 'markdown_with_smartypants' || $data eq 'textile_2')) {
            $cb->( '*** ' . $counter . ':' . $plugin->translate('wrong value([_1]) of convert_breaks.', $data) . "\n" );
            return 1;
        }
    }
    return 0;
}
sub _convert_date {
    my $date = shift;
    unless ($date) {
        my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
        return sprintf("%04d%02d%02d%02d%02d%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
    }
    $date =~ s/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.\d{3}/$1$2$3$4$5$6/;
    $date =~ s/(\d{4})-(\d{2})-(\d{2})\s(\d{2}):(\d{2}):(\d{2})/$1$2$3$4$5$6/;
    $date =~ s!/(\d)/!/0$1/!;
    $date =~ s!/(\d)\s!/0$1 !;
    $date =~ s/\s(\d):/ 0$1:/;
    $date =~ s!(\d{4})/(\d{1,2})/(\d{1,2})\s(\d{1,2}):(\d{1,2})!$1$2$3$4${5}00!;
    $date =~ s!(\d{4})\.(\d{1,2})\.(\d{1,2})\s(\d{1,2}):(\d{1,2})!$1$2$3$4${5}00!;
    return $date;
}

sub _get_data {
    my ($line, $separator) = @_;

    $line =~ s/(?:\x0D\x0A|[\x0D\x0A])?$/$separator/;
    my @values = map {/^"(.*)"\\?$/s ? scalar($_ = $1, s/""/"/g, $_) : $_} 
           ($line =~ /("[^"]*(?:""[^"]*)*"|[^$separator]*)$separator/g);

    return @values;
}

sub _convert_date_and_time_cd {
    my $date = shift;
    return unless $date;

    $date =~ s/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.\d{3}/$1$2$3$4$5$6/;
    $date =~ s/(\d{4})-(\d{2})-(\d{2})\s(\d{2}):(\d{2}):(\d{2})/$1$2$3$4$5$6/;
    $date =~ s!/(\d)/!/0$1/!;
    $date =~ s!/(\d)\s!/0$1 !;
    $date =~ s/\s(\d):/ 0$1:/;
    $date =~ s!(\d{4})/(\d{1,2})/(\d{1,2})\s(\d{1,2}):(\d{1,2})!$1$2$3$4${5}00!;
    $date =~ s!(\d{4})\.(\d{1,2})\.(\d{1,2})\s(\d{1,2}):(\d{1,2})!$1$2$3$4${5}00!;
    return $date;
}

sub _convert_date_cd {
    my $date = shift;
    return unless $date;

    $date =~ s/(\d{4})-(\d{2})-(\d{2})/$1$2${3}000000/;
    $date =~ s/(\d{4})-(\d{2})-(\d{2})/$1$2${3}000000/;
    $date =~ s!/(\d)/!/0$1/!;
    $date =~ s!/(\d)\s!/0$1 !;
    $date =~ s/\s(\d):/ 0$1:/;
    $date =~ s!(\d{4})/(\d{1,2})/(\d{1,2})!$1$2${3}000000!;
    $date =~ s!(\d{4})\.(\d{1,2})\.(\d{1,2})!$1$2${3}000000!;
    return $date;
}

sub _convert_time_cd {
    my $date = shift;
    return unless $date;

    $date =~ s/(\d{2}):(\d{2}):(\d{2})\.\d{3}/19700101$1$2$3/;
    $date =~ s/(\d{2}):(\d{2}):(\d{2})/19700101$1$2$3/;
    $date =~ s!/(\d)/!/0$1/!;
    $date =~ s!/(\d)\s!/0$1 !;
    $date =~ s/\s(\d):/ 0$1:/;
    $date =~ s!(\d{1,2}):(\d{1,2})!19700101$1${2}00!;
    $date =~ s!(\d{1,2}):(\d{1,2})!19700101$1${2}00!;
    return $date;
}

sub start_import_with_excel_cd {
    my $app = shift;

    return $app->permission_denied()
        unless $app->can_do('open_start_import_screen');

    my %param;
    my $q = $app->param;
    my $blog_id = $q->param('blog_id');
    my $content_type_id = $q->param('content_type_id');

    $param{encoding_names} = const('ENCODING_NAMES');
    $param{separator_names} = SEPARATOR_NAMES();
    $param{ content_type_id } = $content_type_id;

    if ($blog_id) {
        $param{blog_id} = $blog_id;
        my $blog = $app->model('blog')->load($blog_id)
            or return $app->error($app->translate('Can\'t load blog #[_1].', $blog_id));
        $param{text_filters} = $app->load_text_filters( $blog->convert_paras );
    }

    $param{ page_title } = MT->translate('Import Excel Data');

    my $plugin = MT->component("CSVDataImExporter");
    my $imexport_character = $plugin->get_config_value('imexport_character', 'blog:' . $blog_id);
    if ( $imexport_character eq 'system' ) {
        $imexport_character = $plugin->get_config_value('imexport_character_system', 'system') || 0;
    }
    $param{imexport_character} = $plugin->translate( $imexport_character );

    $app->add_breadcrumb(
        $app->translate('Import CSV'),
    );

    my $tmpl = 'import_excel.tmpl';
    return $app->build_page($tmpl, \%param);
}

sub start_csv_import_cd {
    my $class = shift;
    my ( $stream, %param ) = @_;

    my $app = MT->instance;

    my $blog_id = $param{Blog}->id;
    my $content_type_id = $param{ContentTypeID};

    my $plugin = MT->component("CSVDataImExporter");
    my $imexport_character = get_imexport_character( $plugin, $blog_id );
    my $is_cloud = $plugin->get_config_value('is_cloud', 'system') || 0;
    my $is_revision = get_is_revision( $plugin, $blog_id );

    my $req = MT::Request->instance() unless $is_cloud;

    my $line_feed_code = get_line_feed_code( $plugin, $blog_id );
    my @data;
    if ( $line_feed_code ) {
        my $content = do { local $/; <$stream> };
        $content =~ s/\r/\r\n/g;
        @data = split(/\r\n/, $content);
    }

    my $buf;
    my @file;
    my $counter = 0;

    if ( $line_feed_code ) {
        foreach my $tmp (@data) {
            $tmp = encode_text($tmp, $imexport_character, 'utf-8');
            $buf .= $tmp;
            next if ($buf =~ s/"/"/g) % 2;
            chomp $buf;
            $buf =~ s/^\xef\xbb\xbf// unless $counter;
            push( @file, $buf );
            $buf = "";
            $counter++;
        }
    } else {
        foreach my $tmp (<$stream>) {
            $tmp = encode_text($tmp, $imexport_character, 'utf-8');
            $buf .= $tmp;
            next if ($buf =~ s/"/"/g) % 2;
            chomp $buf;
            $buf =~ s/^\xef\xbb\xbf// unless $counter;
            push( @file, $buf );
            $buf = "";
            $counter++;
        }
    }

    my @customfields;
    my $meta;
    my $header = 0;
    my %flag;
    my %pos;

    my @headers = _get_data(shift(@file), $separator);
    $headers[$#headers] =~ s/\\//;

    # 1行目の名前からコンテンツタイプIDを取得
    my $content_type = MT::ContentType->load($content_type_id)
        or return $app->errtrans('Invalid request.');
    my $content_type_name = $content_type->name;
utf8::encode($content_type_name); # utf8フラグ対処
    my $field_data = $content_type->fields;

    my @ids;
    my @types;
    my @options;
    my @cat_set_ids;

    my @check_header = ( 'status', 'unpublished_on', 'modified_on', 'authored_on', 'identifier', 'author_id', 'content_type', 'label', 'id' );
    my $check_counter = 0;

    for my $header (@headers) {

        # デコード
        my $decoder = Encode::Guess->guess($header);
        ref($decoder) || die $param{Callback}->( $plugin->translate('Can not guess') . "\n" );

        my $string = $decoder->decode($header);

        $check_counter++ if grep { $_ eq $string } @check_header;

        for my $field (@{$field_data}) {
            encode_text($header, 'utf-8', $imexport_character);
            if ( $field->{options}->{label} eq $string ) {

                # CSVと対応するようconvert_breaks分を追加
                if ( $field->{type} eq 'multi_line_text' ) {
                    push( @ids, $field->{id} );
                    push( @types, $field->{type}.'_convert_breaks' );
                    push( @options, '' );
                    push( @cat_set_ids, 0 );
                }

                push( @ids, $field->{id} );
                push( @types, $field->{type} );
                push( @options, $field->{options}->{values} ); # カラム位置をあわせる対処
                push( @cat_set_ids, $field->{options}->{category_set} || 0 );
            }
        }
    }

    # CSVと対応するよう空のデータを挿入
    for (my $i=0; $i<$check_counter; $i++) {
        unshift( @ids, 0 );
        unshift( @types, '' );
        unshift( @options, '' );
    }

    my $error = 0;
    my $warning = 0;
    my $counter = 2;
    $param{Callback}->( $plugin->translate('The check of the number of CSV columns is started...') . "\n" );

    foreach my $tmp (@file) {
        my @data = _get_data($tmp, $separator);
        if ($#data != $#headers) {
            $param{Callback}->( '*** ' . $counter . $plugin->translate('The number of items of CSV data([_1]) does not suit the number of items of a header([_2]). This error is outputted also when there is no data in the last column.', $#data, $#headers) . "\n" );
        }
        for my $i (0 .. $#data) {
#            $error |= _check( $headers[$i], $data[$i], $counter, $param{Callback} );
        }
        $counter++;
    }
    if ($error) {
        $param{Callback}->( $plugin->translate('Import is stopped because CSV data has an error.') . "\n" );
        return $app->error( $plugin->translate('Import is stopped because CSV data has an error.') );
    }
    $param{Callback}->( $plugin->translate('The check of CSV data was completed normally.') . "\n" );
    $param{Callback}->( $plugin->translate('Import of CSV data is started...') . "\n" );


    my $imexport_character = $plugin->get_config_value('imexport_character', 'blog:' . $param{Blog}->id);
    if ( $imexport_character eq 'system' ) {
        $imexport_character = $plugin->get_config_value('imexport_character_system', 'system') || 0;
    }

    my $content_field_types = $app->registry('content_field_types');
    my $line = 2;

    # 1行ずつ解析
    foreach my $tmp (@file) {
        my @values = _get_data($tmp, $separator);
        $values[$#values] =~ s/\\$//;

        my $counter = 0;

        # フィールド単位でコンテンツタイプIDに対応
        my $skip = 0;
        my $new = 0;
        my $content_data;

        my $status;
        my $unique_id;
        my $unpublished_on;
        my $modified_on;
        my $authored_on;
        my $label;
        my $identifier;
        my $author_id;
        my $id = 'new';

        my @assets;

        my $data = {};
        my $convert_breaks = {};

        foreach my $value (@values) {
#$param{Callback}->($ids[$counter] . " header:" . $headers[$counter] . "/value:" .  $value . "\n");

            if ( $headers[$counter] eq 'content_type' ) {
                if ( $content_type_name ne $value ) {
                    $param{Callback}->( "Line:" . $line . ":" . $plugin->translate('Content type is different.') . "\n" );
                    $skip = 1;
                    last;
                }
            }

            if ( $headers[$counter] eq 'id' ) {

                # idなし
                if (!$value) {

                     # 記事ID指定なしの処理:同一ベースネーム/同一タイトルの記事を上書き
                    if ($param{null_id_process}) {
                        my $same = $same_data_cd->{$param{null_id_process}};
                        for my $j (0 .. $#values) {
                            if ($headers[$j] eq $same) {
                                $content_data = MT::ContentData->load( { blog_id => $blog_id, $same => $values[$j] } );
                                if (!$content_data) {
                                    $content_data = MT::ContentData->new;
                                    $new = 1;
                                } else {
                                    $data = $content_data->data;
                                }
                                last;
                            }
                        }
                     # 記事ID指定なしの処理:新規作成
                    } else {
                        $content_data = MT::ContentData->new;
                        $new = 1;
                    }

                # idあり
                } else {
                    $content_data = MT::ContentData->load( { blog_id => $blog_id, id => $value, content_type_id => $content_type_id, } );

                    # 指定記事IDなし
                    if (!$content_data) {

                        # インポートしない指定あり
                        if (!$param{no_id_process}) {
                            $param{Callback}->( "Line:" . $line . ":" . "ID:$value " . $plugin->translate('Processing is skipped because there is no applicable entry.') . "\n" );
                            $skip = 1;
                            last;

                        # インポート
                        } else {
                            $content_data = MT::ContentData->new;
                            $new = 1;
                        }

                    # 指定記事IDあり
                    } else {
                        $id = $content_data->id;

                        # インポートしない指定あり
                        if ($param{same_id_process}) {
                            my $id = $content_data->id;
                            $param{Callback}->( "Line:" . $line . ":" . "ID:$value " . $plugin->translate('Update is skipped because there is applicable entry.') . "\n" );
                            $skip = 1;
                            last;
                        } else {
                            $data = $content_data->data;
                        }
                    }
                }
            }

            if ( $headers[$counter] eq 'author_id') {
                $author_id = $value;
            }
            if ( $headers[$counter] eq 'identifier') {
                $identifier = $value;
            }
            if ( $headers[$counter] eq 'label') {
                $label = $value;
            }
            if ( $headers[$counter] eq 'authored_on') {
                $authored_on = $value;
            }
            if ( $headers[$counter] eq 'modified_on') {
                $modified_on = $value;
            }
            if ( $headers[$counter] eq 'unpublished_on') {
                $unpublished_on = $value;
                if ( !$unpublished_on ) {
                    undef $unpublished_on;
                }
            }
            if ( $headers[$counter] eq 'unique_id') {
                $unique_id = $value;
            }
            if ( $headers[$counter] eq 'status') {
                $status = $value;
            }

            if ( $types[$counter] eq 'number') {
                if ( $value && $value !~ /[0-9\.-]/ ) {
                    $param{Callback}->( "Line:" . $line . ":" . "ID:$id " . $plugin->translate('Skipped because value([_1]) is not numeric.', $value) . "\n" );
                    $skip = 1;
                }
            }

            if ( $headers[$counter] eq 'content_type_id') {
                if ( $content_type_id != $value ) {
                     $param{Callback}->( "Line:" . $line . ":" . "ID:$value " . $plugin->translate('content type is difference.') . "\n" );
                     $skip = 1;
                }
            }

            if ( $headers[$counter] eq 'status') {
                $status = $value;
            }

            if ( $types[$counter] =~ /^.*_convert_breaks$/) {
                $convert_breaks->{ $ids[$counter] } = $value; # 同じフィールドのidを取得
            }

            if ( $types[$counter] eq 'date_and_time') {
                $value = _convert_date_and_time_cd( $value );
            }
            if ( $types[$counter] eq 'date_only') {
                $value = _convert_date_cd( $value );
            }
            if ( $types[$counter] eq 'time_only') {
                $value = _convert_time_cd( $value );
            }
            if ( $types[$counter] eq 'multi_line_text' ) {
            }

            if ($types[$counter] eq 'select_box') {
                my $select_box_value = is_value( $plugin, $blog_id, 'select_box_value' );

                # 値に対応するラベルを取得
                my @values;
                my @a = split( /,/, $value );
                for my $v ( @a ) {
                    for my $option (@{$options[$counter]}) {
                        if ( !$select_box_value ) {
                            my $label = $option->{label};
                            utf8::encode($label); # utf8フラグ対処
                            if ( $v eq $label ) {
                                push @values, $option->{value};
                                last;
                            }
                        } else {
                            my $value = $option->{value};
                            utf8::encode($value); # utf8フラグ対処
                            if ( $v eq $value ) {
                                push @values, $option->{value};
                                last;
                            }
                        }
                    }
                }
                $value = \@values;
            }

            if ($types[$counter] eq 'checkboxes') {
                my $checkboxes_value = is_value( $plugin, $blog_id, 'checkboxes_value' );

                # 値に対応するラベルを取得
                my @values;
                my @a = split( /,/, $value );
                for my $v ( @a ) {
                    for my $option (@{$options[$counter]}) {
                        if ( !$checkboxes_value ) {
                            my $label = $option->{label};
                            utf8::encode($label); # utf8フラグ対処
                            if ( $v eq $label ) {
                                push @values, $option->{value};
                                last;
                            }
                        } else {
                            my $value = $option->{value};
                            utf8::encode($value); # utf8フラグ対処
                            if ( $v eq $value ) {
                                push @values, $option->{value};
                                last;
                            }
                        }
                    }
                }
                $value = \@values;
            }

            if ($types[$counter] eq 'radio_button') {
                my $radio_button_value = is_value( $plugin, $blog_id, 'radio_button_value' );

                # 値に対応するラベルを取得
                my @values;
                for my $option (@{$options[$counter]}) {
                    if ( !$radio_button_value ) {
                        my $label = $option->{label};
                        utf8::encode($label); # utf8フラグ対処
                        if ( $value eq $label) {
                            $value = $option->{value};
                            last;
                        }
                    } else {
                        my $value2 = $option->{value};
                        utf8::encode($value2); # utf8フラグ対処
                        if ( $value eq $value2 ) {
                            push @values, $option->{value};
                            last;
                        }
                    }
                }
            }

            if ($types[$counter] eq 'categories' ) {
                my @a = split( /,/, $value );
                $value = \@a;
            }

            if ($types[$counter] eq 'categories' ) {
                my @categories;
                if ( $value =~ /,/ ) {
                    @categories = split(/,/, $value);
                } else {
                    push @categories, $value;
                }
                $value = _add_category_to_cd( $app, $req, \%param, $content_type_id, $content_data->id, $headers[$counter], @categories, $param{Callback}, $cat_set_ids[$counter] );
            }

            if ($types[$counter] eq 'asset' ||
                $types[$counter] eq 'asset_audio' ||
                $types[$counter] eq 'asset_video' ||
                $types[$counter] eq 'asset_image' ) {
                @assets = split( /,/, $value );
                $value = _add_asset_to_entry_cd( $blog_id, $content_data->id, \@assets, $headers[$counter], $content_type_id, $param{Callback} );
            }

            if ($types[$counter] eq 'tags' ) {
                my @a = split( /,/, $value );
                my @ids;
                for my $name (@a) {
                    my @iter = MT::Tag->load( { name => $name } );
                    if (!@iter) {
                        my $tag = MT::Tag->new( name => $name );
                        $tag->save;
                        push @ids, $tag->id;
                        $param{Callback}->( $plugin->translate('Created [_1](ID:[_2])', $plugin->translate('Tag'), $tag->id) . "\n" );
                    } else {
                        for my $tag ( @iter ) {
                            push @ids, $tag->id;
                        }
                    }
                }
                $value = \@ids;
            }

            if ($types[$counter] eq 'list' ||
                $types[$counter] eq 'tables' ) {
                my @a = split( /,/, $value );
                $value = \@a;
            }

            if ( $types[$counter] eq 'content_type') {
                my @ct = split( /,/, $value );
                my @v;
                for my $ct ( @ct ) {
                    my @ct2 = split( /:/, $ct );
                    next if scalar(@ct2) != 2; # check format

                    # コンテントタイプ取得
                    my $inner_content_type = MT::ContentType->load( { blog_id => $blog_id, name => $ct2[0] } );
                    next if !$inner_content_type;

                    # データ識別ラベルがユーザ入力以外の場合
                    if ( $inner_content_type->data_label ) {

                        # 選択したコンテントタイプのユニークID取得
                        my $unique_id = $inner_content_type->data_label;

                        # ユニークIDを元にコンテントフィールド取得
                        my $cf = MT::ContentField->load( { unique_id => $unique_id } );
                        my $cf_type = $cf->type;
                        my $id = $cf->id;

                        # フィールドタイプよりDB検索フィールド名設定
                        my $key;
                        if ( $cf_type eq 'single_line_text' ) {
                            $key = 'value_varchar';
                        } elsif ( $cf_type eq 'url' ) {
                            $key = 'value_text';
                        }

                        # コンテントフィールドインデックスよりコンテントデータID取得
                        # データ識別ラベルがユーザ入力の場合, value_varcharは変更されないので注意
                        my $index = MT->model('content_field_index')->load({ content_field_id => $id, $key => $ct2[1]});
                        push @v, $index->content_data_id;

                    # データ識別ラベルがユーザ入力の場合
                    } else {

                        # 選択したコンテントタイプのコンテントデータID取得
                        my $inner_content_data = MT::ContentData->load( { blog_id => $blog_id, content_type_id => $inner_content_type->id, label => $ct2[1] } );
                        next if !$inner_content_data;
                        push @v, $inner_content_data->id;
                    }
                }
                $value = \@v;
            }

            $data->{ $ids[$counter] } = $value if $ids[$counter] != 0 && $ids[$counter] !~ /convert_breaks/;

            $counter++;
        }

        # 行カウンタ更新
        $line++;

        # 保存
        next if $skip;

        my $tmp_line = $line - 1;

        # 必須データチェック
        if ( $content_type_id && !$author_id ) {
            $param{Callback}->( "Line:" . $tmp_line . ":" . $plugin->translate('No author_id.') . "\n" );
            next;
        }

        $content_data->convert_breaks( MT::Serialize->serialize( \$convert_breaks ) );
        $content_data->data($data);
        $content_data->label($label)if $label;
        $content_data->blog_id($blog_id);
        $content_data->content_type_id($content_type_id);
        $content_data->author_id($author_id);

        $content_data->identifier($identifier) if $identifier;

        # タイムスタンプ
        # 既存：設定されていれば上書き（未設定であればスキップ）
        if ( !$new ) {
            $content_data->authored_on(_convert_date($authored_on)) if $authored_on;
            $content_data->modified_on(_convert_date($modified_on)) if $modified_on;

        # 新規：設定されていれば利用、未設定であれば生成
        } else {
            if ( $authored_on ) {
                $content_data->authored_on(_convert_date($authored_on));
            } else {
                $content_data->authored_on(_convert_date());
            }
            if ( $modified_on ) {
                $content_data->modified_on(_convert_date($modified_on));
            } else {
                $content_data->modified_on(_convert_date());
            }
        }

        if ( !$unpublished_on ) {
            $content_data->unpublished_on( undef );
        }
        if ( defined $unpublished_on ) {
            $content_data->unpublished_on(_convert_date($unpublished_on));
        } else {
            $content_data->unpublished_on( undef );
        }
        $content_data->status($status);
#        $content_data->save or $param{Callback}->( 'save error. ' . $content_data->errstr . "\n" );

        eval { $content_data->save; };
        if ($@) {
             $param{Callback}->( 'save error. ' . $@ . "\n" );
        } else {

            if ( $is_revision ) {
                my $changed_cols = $content_data->{changed_revisioned_cols};
                push @$changed_cols, 'for csv';
                $content_data->{changed_revisioned_cols} = $changed_cols;
                _mt_postsave_obj( $plugin, $content_data );
            }

            if ($new) {
                 $param{Callback}->( "Line:" . $tmp_line . ":" . $plugin->translate('Added [_1](ID:[_2])', $plugin->translate('ContentData'), $content_data->id) . "\n" );
            } else {
                 $param{Callback}->( "Line:" . $tmp_line . ":" . $plugin->translate('Updated [_1](ID:[_2])', $plugin->translate('ContentData'), $content_data->id) . "\n" );
            }
        }
    }

    return 1;
}

sub _create_category_cd {
    my ($blog_id, $category_label, $category_basename, $parent_category_id, $category_set_id, $cb) = @_;

    my $category_class = MT->model('category');

    my $cat = $category_class->new;
    $cat->blog_id($blog_id);
    $cat->category_set_id($category_set_id);
    $cat->label($category_label);
    $cat->basename($category_basename) if $category_basename;
    $cat->parent($parent_category_id);
    $cat->save
      or die $cat->errstr;
    my $cat_id = $cat->id;
    undef $cat;

    return $cat_id;
}

sub _add_category_to_cd {
    my ($app, $req, $param, $content_type_id, $content_data_id, $content_field_name, $categories, $cb, $cat_set_id) = @_;

    # コンテントフィールド名からカテゴリセット名を取得
    my $content_field = MT::ContentField->load( { blog_id => $app->blog->id, content_type_id => $content_type_id, name => $content_field_name } );
    return undef if !$content_field;

    my $cat_set_id = $content_field->related_cat_set_id;

    my $obj_categories = ();
    if ( $content_data_id ) {
        my @obj_categories = MT::ObjectCategory->load({ blog_id => $app->blog->id, object_ds => 'content data', cf_id => $content_field->id, object_id => $content_data_id });
#$cb->( "obj_categories:" . Dumper(@obj_categories) . "\n" );
        foreach my $obj_category (@obj_categories) {
            my $category_id = $obj_category->category_id;
            $obj_categories->{$category_id} = 1;
        }
    }
    my $seen = ();
    $content_data_id = 'NEW' unless $content_data_id; # 保存前のCD

    my $blog_id = $param->{Blog}->id;
    my $category_class = MT->model('category');

    my $is_primary;
    my $cat;
    my $cat_id;
    my $count = 0;

    my $plugin = MT->component("CSVDataImExporter");

    my @result;

    for my $category_tmp (@{$categories}) {
        my @category_list = ();
        if ($category_tmp =~ /$category_separator/) {
           @category_list = split($category_separator, $category_tmp);
        } else {
           push(@category_list, $category_tmp);
        }
        my $category_count = 0;
        my $parent_categories;
        my $parent_category_id = 0;

        my $message_class = MT->translate('Category');

        for my $category_label (@category_list) {
            my $create = 0;
            my $category_id = '';

            my $category_basename = '';
            if ($category_label =~ /(.*)\((\d+):(.*)\)/) {
                $category_label = $1;
                $category_id = $2;
                $category_basename = $3;

                if($app->param('no_id_process')){
                    $create = 1;
                }
            } elsif ($category_label =~ /(.*)\((\d+)\)/) {
                $category_label = $1;
                $category_id = $2;

                if($app->param('no_id_process')){
                    $create = 1;
                }
            } elsif ($category_label =~ /(.*)\(\:(.*)\)/) {
                $category_label = $1;
                $category_basename = $2;
                $create = 1;
            } elsif ($category_label =~ /(.*)/) {
                $category_label = $1;
                $create = 1;
            }
#            $cat = $req->cache( "cat" . $category_id . $blog_id );

            if (!$create) {
                if (!$category_count) {
                    $cat = $category_class->load({ id => $category_id, blog_id => $blog_id, category_set_id => $cat_set_id });
                } else {
                    $cat = $category_class->load( { id => $category_id, parent => $parent_category_id, blog_id => $blog_id, category_set_id => $cat_set_id } );
                }
            }

            if ($create) {
                if ($category_basename) {
                    if ($category_count) {
                        $cat = $category_class->load({ label => $category_label, basename => $category_basename, parent => $parent_category_id, blog_id => $blog_id, category_set_id => $cat_set_id });
                    } else {
                        $cat = $category_class->load({ label => $category_label, basename => $category_basename, blog_id => $blog_id, category_set_id => $cat_set_id });
                    }
                } else {
                    if ($category_count) {
                        $cat = $category_class->load({ label => $category_label, parent => $parent_category_id, blog_id => $blog_id, category_set_id => $cat_set_id });
                    } else {
                        $cat = $category_class->load({ label => $category_label, blog_id => $blog_id, category_set_id => $cat_set_id });
                    }
                }
                $create = 0 if $cat;
            }

            # カテゴリ作成
            if(!$cat) {
                my $category_set = MT::CategorySet->load( { blog_id => $blog_id, id => $cat_set_id } );

                # カテゴリセット作成(カテゴリセット名：$content_field_name)
#                if ( !$category_set ) {
#                    $category_set = MT::CategorySet->new( { name => $content_field_name } );
#                    $cb->( $plugin->translate('Categoryset [_1]([_2]) is created.', $content_field_name, $category_set->id . "\n" ));
#                }

                # カテゴリセットに追加
                if ( $category_set ) {
                    $category_id = _create_category_cd($blog_id, $category_label, $category_basename, $parent_category_id, $category_set->id, $cb );
                    my $order = $category_set->order . "," . $category_id;
                    $category_set->order( $order );
                    my $cat_count = $category_set->cat_count;
                    my @c = split(/,/, $cat_count);
                    $category_set->cat_count( scalar(@c) + 1 );
                    $category_set->save;

                    if ($category_count) {
                        $cb->( $plugin->translate('sub [_1]([_2]) is created to [_3].', $message_class , Encode::decode_utf8($category_label), Encode::decode_utf8($category_set->name)) . "\n" );
                    } else {
                        $cb->( $plugin->translate('\[_1]([_2]) is created to [_3].', $message_class , Encode::decode_utf8($category_label), Encode::decode_utf8($category_set->name)) . "\n" );
                    }
                }

            } else {
                $category_id = $cat->id;
            }

            if (!$category_count) {
                $parent_categories = $category_label;
#                $cb->( $plugin->translate('set category [_1]', $category_label) . "\n" ) if $category_id;
            } else {
                $parent_categories .= '->'.$category_label;
#                $cb->( $plugin->translate('set subcategory [_1] parent category[_2]', $category_label, $parent_categories) . "\n" ) if $category_id;
            }

            # 最下層のサブカテゴリの場合,idをコンテンツデータとして取得
            if ($category_count == $#category_list) {
                push @result, $category_id;
                $cb->( $plugin->translate('ContentData([_1]) and [_2]([_3]) are associated.', $content_data_id, $message_class, Encode::decode_utf8($parent_categories)) . "\n" );
                $seen->{$category_id} = 1;
            }

            $parent_category_id = $category_id;
            $count++;
            $category_count++;
undef $cat;
        }
    }

    # clean objectcategory
    foreach my $category_id (keys %{$obj_categories}) {
        unless ($seen->{$category_id}) {
            my $obj_category = MT::ObjectCategory->load({ category_id => $category_id, object_ds => 'content data', cf_id => $content_field->id, object_id => $content_data_id });
            $obj_category->remove;
            $cb->( $plugin->translate('Association of ContentData([_1]) and Catgory([_2]) is canceled.', $content_data_id, $category_id) . "\n" );
undef $obj_category;
        }
    }

    return \@result;
}

sub _add_asset_to_entry_cd {
    my ($blog_id, $id, $assets, $name, $content_type_id, $cb) = @_; # no nessesary class_type

    my $plugin = MT->component("CSVDataImExporter");

    # コンテントフィールド名からカテゴリセット名を取得
    my $content_field = MT::ContentField->load( { blog_id => $blog_id, content_type_id => $content_type_id, name => $name } );

    my $obj_assets = ();
    if ( $id ) {
        my $content_field = MT::ContentField->load( { blog_id => $blog_id, name => $name } );
        my @obj_assets = MT::ObjectAsset->load({ object_ds => 'content data', cf_id => $content_field->id, object_id => $id });
        foreach my $obj_asset (@obj_assets) {
            my $asset_id = $obj_asset->asset_id;
            $obj_assets->{$asset_id} = 1;
        }
    }

    my $seen = ();
    my @assets_result;
    foreach my $asset_id (@{$assets}) {
        if ($asset_id =~ /.*\((\d+)\)/) {
            $asset_id = $1;
        } else {
            $asset_id = upload($blog_id, $asset_id, $cb);
            next if !$asset_id;
        }
        push @assets_result, $asset_id;
        $seen->{$asset_id} = 1;
    }

    foreach my $asset_id (keys %{$obj_assets}) {
        unless ($seen->{$asset_id}) {
            my $obj_asset = MT::ObjectAsset->load({ asset_id => $asset_id, object_ds => 'content data', cf_id => $content_field->id, object_id => $id });
            $obj_asset->remove;
            $cb->( $plugin->translate('Association of ContentData([_1]) and Asset([_2]) is canceled.', $id, $asset_id) . "\n" );
undef $obj_asset;
        }
    }

    return \@assets_result;
}

sub export {
    my $class = shift;
    my ( $app, $blog, $cb ) = @_;

my @field = ('class','id','status','author','authored_on','modified_on','unpublished_on','convert_breaks','title','text','text_more','excerpt','keywords','categories','tags','allow_comments','allow_pings','assets','basename');

    my $field_max = $#field + 1;
    _add_customfield($app, \@field);

    $cb ||= sub { };
    my $sep = ',';

    my $plugin = MT->component("CSVDataImExporter");
    my $is_cloud = $plugin->get_config_value('is_cloud', 'system') || 0;
    my $imexport_character = get_imexport_character( $plugin, $blog->id );

    my $req = MT::Request->instance() unless $is_cloud;

    my $q = $app->param;
    my @ids = $q->param('id');
    my $iter;
    if (@ids) {
        $iter = MT::Entry->load_iter( { blog_id => $blog->id, class => $q->param('export_class'), id => \@ids } );
    } else {
        $iter = MT::Entry->load_iter( { blog_id => $blog->id, class => $q->param('export_class') } );
    }

#    require MT::Import;
#    my $importer = MT::Import->importer('import_csv');
#    my $handler  = $importer->{export_handler};
#    $handler = MT->handler_to_coderef($handler);

    $cb->( join(",", @field) );
    $cb->( "\n" );
    my $entries;
    while ( my $entry = $iter->() ) {
        my @csvdata;
        my $id;
        my $category_class;
        my $counter = 0;
        foreach my $col (@field) {
            my $data = '';
            $id = $entry->$col if $col eq 'id';
            if ($col eq 'categories') {
                $data = _get_category($id, $category_class);
            } elsif ($col eq 'author') {
                my $author = MT::Author->load( { id => $entry->author_id } );
                $data = $author->name;
            } elsif ($col eq 'tags') {
                $data = join(',', $entry->$col);
            } elsif ($col eq 'assets') {
                my @assets;
                my @obj_assets = MT::ObjectAsset->load({ object_id => $id, blog_id => $blog->id });
                foreach my $obj_asset (@obj_assets) {
                    my $asset = MT->model('asset')->load({ id => $obj_asset->asset_id, blog_id => $blog->id });
                    next if !$asset;
                    if ( $asset->label ) {
                        push(@assets, $asset->label.'('.$asset->id.')');
                    } else {
                        push(@assets, $asset->file_name.'('.$asset->id.')');
                    }
                    $data = join(',', @assets);
                }
            } elsif ($counter >= $field_max) {

                my $field;
                if ($is_cloud) {
                    $field = MT->model('field')->load(
                        {   basename => $col,
                            blog_id  => [ 0, $entry->blog_id ],
                            obj_type => $q->param('export_class')
                        }
                    );
                } else {
                    $field = $req->cache( $col . $entry->blog_id );
                    unless ($field) {
                        $field = MT->model('field')->load(
                            {   basename => $col,
                                blog_id  => [ 0, $entry->blog_id ],
                                obj_type => $q->param('export_class')
                            }
                        );
                        $req->cache( $col . $entry->blog_id, $field )
                            if $field;
                    }
                }
                next unless $field;

                my $key = 'field.' . $col;
                $data = $entry->$key;

                if ($field->type eq 'datetime') {
                    if ($data) {
                        $data =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5:$6/;
                    } else {
                        $data = '';
                    }
                }
            } else {
                my $field_name = 'field.' . $col;
                if ( $entry->has_meta( $field_name ) ) {
                    $data = $entry->$field_name;
                } else {
                    $data = $entry->$col;
                }
            }

            if ($col eq 'class') {
                $category_class = MT->model($entry->class eq 'entry' ? 'category' : 'folder');
            }
            if ($col eq 'authored_on' || $col eq 'modified_on' || 'unpublished_on') {
                $data =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5:$6/;
            }

            $data =~ s/"/""/g;
            if ($data =~ /\r?\n|,|"/) {
                $data = '"'.$data.'"';
            }
            push ( @csvdata, encode_text($data, 'utf-8', $imexport_character) );
            $counter++;
        }
        $cb->( join(",", @csvdata) );
        $cb->( "\n" );
        undef $entry;
        undef @csvdata;
    }
    undef @field;
}

sub _add_customfield {
    my $app = shift;
    my $field = shift;

    my $blog_id = $app->param('blog_id');

    my $iter;
    if ($app->param('export_class') eq '*') {
        $iter = CustomFields::Field->load_iter(
               { blog_id => [0, $blog_id],
                 obj_type => 'entry',
               });
        while (my $f = $iter->()) {
            push(@$field, $f->basename);
        }
        $iter = CustomFields::Field->load_iter(
               { blog_id => [0, $blog_id],
                 obj_type => 'page',
               });
        while (my $f = $iter->()) {
            push(@$field, $f->basename);
        }
    } else {
        $iter = CustomFields::Field->load_iter(
               { blog_id => [0, $blog_id],
                 obj_type => $app->param('export_class'),
               });
        while (my $f = $iter->()) {
            push(@$field, $f->basename);
        }
    }
}

sub _get_category {
    my ($id, $category_class) = @_;
    my $data = '';
    my $place = MT::Placement->load( { entry_id => $id, is_primary => 1 } );
    if ($place) {
        my $primary = '';
        my $cat = $category_class->load( { id => $place->category_id } );
        $primary = $cat->label.'('.$cat->id.":".$cat->basename.')';
        while ($cat->parent != 0) {
            $cat = $category_class->load( { id => $cat->parent } );
            $primary = $cat->label.'('.$cat->id.":".$cat->basename.')'.$category_separator.$primary;
        }

        my @places = MT::Placement->load( { entry_id => $id, is_primary => 0 } );
        my @sec;
        foreach my $p (@places) {
            my $secondary = '';
            my $cat = $category_class->load( { id => $p->category_id } );
            $secondary .= $cat->label.'('.$cat->id.":".$cat->basename.')';
            while ($cat->parent != 0) {
                $cat = $category_class->load( { id => $cat->parent } );
                $secondary = $cat->label.'('.$cat->id.":".$cat->basename.')'.$category_separator.$secondary;
            }
            push(@sec, $secondary);
        }
        $data = $primary . (@sec ? "," . join(",", @sec) : '');
    }
    return $data;
}

sub export_cd {
    my $class = shift;
    my ( $app, $blog, $content_type_id, $cb ) = @_;

    my $plugin = MT->component("CSVDataImExporter");
    my $imexport_character = $plugin->get_config_value('imexport_character', 'blog:' . $blog->id);
    if ( $imexport_character eq 'system' ) {
        $imexport_character = $plugin->get_config_value('imexport_character_system', 'system') || 0;
    }

    my $content_type = MT::ContentType->load($content_type_id)
        or return $app->errtrans('Invalid request.');
    my $content_type_name = $content_type->name;

    my $array = $content_type->fields;

    my @labels = map {
        encode_text($_->{options}->{label}, 'utf-8', $imexport_character);
    } @$array;

    my @labels2 = map {
        encode_text($_->{options}->{label}, 'utf-8', $imexport_character);
    } @$array;

    my @labels_without_encode = map {
        $_->{options}->{label};
    } @$array;

    my @types = map {
        $_->{type};
    } @$array;

    my @ids = map {
        $_->{id};
    } @$array;

    my @options;
    for my $field (@$array) {
        push @options, $field->{options}->{values};
    }

    my $counter = 0;
    my $padding = 0;
    for my $type (@types) {
        if ( $type eq 'multi_line_text' ) {
            splice( @labels2, $counter+$padding, 0 , $labels[$counter] . '_convert_breaks');
            $padding++;
        }
        $counter++;
    }

    unshift( @labels2, 'status');
#    unshift( @labels2, 'unique_id');
    unshift( @labels2, 'unpublished_on');
    unshift( @labels2, 'modified_on');
    unshift( @labels2, 'authored_on');
    unshift( @labels2, 'identifier');
    unshift( @labels2, 'author_id');
#    unshift( @labels2, 'content_type_id');
    unshift( @labels2, 'label');
    unshift( @labels2, 'id');
    unshift( @labels2, 'content_type');

    $cb->( join(",", @labels2) );
    $cb->( "\n" );

    my $q = $app->param;
    my @ids2 = $q->param('id');
    my $iter;
    if (@ids2) {
        $iter = MT::ContentData->load_iter({ content_type_id => $content_type_id, id => \@ids2 });
    } else {
        $iter = MT::ContentData->load_iter({ content_type_id => $content_type_id });
    }
    while ( my $content_data = $iter->() ) {
        my $data = $content_data->data;

        my $convert_breaks = MT::Serialize->unserialize( $content_data->convert_breaks );
        my $blockeditor_data
            = $content_data
            ? $content_data->block_editor_data()
            : undef;
        my $content_field_types = $app->registry('content_field_types');

        my @csvdata;
        push( @csvdata, encode_text($content_type_name, 'utf-8', $imexport_character) );
        push( @csvdata, $content_data->id );

        my $label = $content_data->label;
        $label =~ s/"/""/g;
        if ($label =~ /\r?\n|,|"/) {
            $label = '"' . $label . '"';
        }
        push( @csvdata, encode_text($label, 'utf-8', $imexport_character) );

#        push( @csvdata, $content_data->content_type_id );
        push( @csvdata, $content_data->author_id );
        push( @csvdata, $content_data->identifier );

        (my $authored_on = $content_data->authored_on) =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5:$6/;
        (my $modified_on = $content_data->modified_on) =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5:$6/;
         my $unpublished_on = undef;
        ($unpublished_on = $content_data->unpublished_on) =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5:$6/ if $content_data->unpublished_on;

        push( @csvdata, $authored_on );
        push( @csvdata, $modified_on );
        push( @csvdata, $unpublished_on );
#        push( @csvdata, $content_data->unique_id );
        push( @csvdata, $content_data->status );

        my $counter = 0;
        for my $key (@ids) {
            my $tmp = $data->{$key};

            if ($types[$counter] eq 'multi_line_text') {
                push ( @csvdata, $$convert_breaks->{$key} );
            }

            if ($types[$counter] eq 'date_and_time') {
                $tmp =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5:$6/;
            }

            if ($types[$counter] eq 'date_only') {
                $tmp =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$1-$2-$3/;
            }

            if ($types[$counter] eq 'time_only') {
                $tmp =~ s/(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/$4:$5:$6/;
            }

            if ($types[$counter] eq 'select_box') {
                my $select_box_value = is_value( $plugin, $blog->id, 'select_box_value' );
                if (ref($tmp) eq "ARRAY") {

                    # 値に対応するラベルを取得
                    my @values;
                    for my $t (@{$tmp}) {
                        for my $option (@{$options[$counter]}) {
                            if ( $t eq $option->{value} ) {
                                if ( $select_box_value ) {
                                    push @values, $option->{value};
                                } else {
                                    push @values, $option->{label};
                                }
                                last;
                            }
                        }
                    }
                    $tmp = join(",", @values);
                } else {
                    for my $option (@{$options[$counter]}) {
                        if ( $tmp eq $option->{value} ) {
                            if ( !$select_box_value ) {
                                $tmp = $option->{label};
                            }
                            last;
                        }
                    }
                }
            }

            if ($types[$counter] eq 'checkboxes') {
                my $checkboxes_value = is_value( $plugin, $blog->id, 'checkboxes_value' );
                if (ref($tmp) eq "ARRAY") {

                    # 値に対応するラベルを取得
                    my @values;
                    for my $t (@{$tmp}) {
                        for my $option (@{$options[$counter]}) {
                            if ( $t eq $option->{value} ) {
                                if ( $checkboxes_value ) {
                                    push @values, $option->{value};
                                } else {
                                    push @values, $option->{label};
                                }
                                last;
                            }
                        }
                    }
                    $tmp = join(",", @values);
                } else {
                    for my $option (@{$options[$counter]}) {
                        if ( $tmp eq $option->{value} ) {
                            if ( !$checkboxes_value ) {
                                $tmp = $option->{label};
                            }
                            last;
                        }
                    }
                }
            }

            if ($types[$counter] eq 'radio_button' ) {
                my $radio_button_value = is_value( $plugin, $blog->id, 'radio_button_value' );
                if (ref($tmp) eq "ARRAY") {

                    # 値に対応するラベルを取得
                    my @values;
                    for my $t (@{$tmp}) {
                        for my $option (@{$options[$counter]}) {
                            if ( $t eq $option->{value} ) {
                                if ( $radio_button_value ) {
                                    push @values, $option->{value};
                                } else {
                                    push @values, $option->{label};
                                }
                                last;
                            }
                        }
                    }
                    $tmp = join(",", @values);
                } else {
                    for my $option (@{$options[$counter]}) {
                        if ( $tmp eq $option->{value} ) {
                            if ( !$radio_button_value ) {
                                $tmp = $option->{label};
                            }
                            last;
                        }
                    }
                }
            }

            if ($types[$counter] eq 'content_type' ) {
                my @content_type_buf;
                for my $content_data_id (@{$tmp}) {

                    # コンテントデータ取得
                    my $content_data = MT::ContentData->load( $content_data_id );
                    next if !$content_data;
                    my $inner_content_type_id = $content_data->content_type_id;

                    # コンテンツタイプ取得
                    my $inner_content_type = MT::ContentType->load( $inner_content_type_id );
                    next if !$content_type;

                    push @content_type_buf, $inner_content_type->name . ":" . $content_data->label;
                }
                $tmp =  join(",", @content_type_buf);
                undef @content_type_buf;
            }

            if ($types[$counter] eq 'asset' ||
                $types[$counter] eq 'asset_audio' ||
                $types[$counter] eq 'asset_video' ||
                $types[$counter] eq 'asset_image' ) {

                my @assets;
                if (ref($tmp) eq "ARRAY" && scalar(@{$tmp})) {
                    foreach my $id (@{$tmp}) {
                        my $asset = MT->model('asset')->load({ id => $id, blog_id => $blog->id });
                        next if !$asset;
                        if ( $asset->label ) {
                            push(@assets, $asset->label.'('.$asset->id.')');
                        } else {
                            push(@assets, $asset->file_name.'('.$asset->id.')');
                        }
                    }
                    $tmp = join(',', @assets);
                } else {
                    $tmp = '';
                }
            }

            if ($types[$counter] eq 'tags' ) {
                if (ref($tmp) eq "ARRAY") {
                    my @tags;
                    for my $id (@{$tmp}) {
                        my $iter = MT::Tag->load_iter({ id => $id });
                        while ( my $tag = $iter->() ) {
                            push @tags, $tag->name;
                        }
                    }
                    $tmp =  join(",", @tags);
                }
            }

            if ($types[$counter] eq 'list' ||
                $types[$counter] eq 'tables' ) {
                if (ref($tmp) eq "ARRAY") {
                    $tmp =  join(",", @{$tmp});
                }
            }

            if ($types[$counter] eq 'categories' ) {
                my @cat_tmp;
                for my $cat_id ( @{$tmp} ) {
                    my $category = MT::Category->load( { id => $cat_id } );
                    push @cat_tmp, $category->label.'('.$category->id.":".$category->basename.')';
                }
                $tmp =  join(",", @cat_tmp);
            }

            $tmp =~ s/"/""/g;
            if ($tmp =~ /\r?\n|,|"/) {
                $tmp = '"' . $tmp . '"';
            }

            push ( @csvdata, encode_text($tmp, 'utf-8', $imexport_character) );
            $counter++;
        }

        $cb->( join(",", @csvdata) );
        $cb->( "\n" );
        undef $content_data;
        undef @csvdata;
    }

    undef $array;
    undef @labels;
}

sub _get_category_cd {
    my ($id, $category_class) = @_;
    my $data = '';
    my $place = MT::Placement->load( { entry_id => $id, is_primary => 1 } );
    if ($place) {
        my $primary = '';
        my $cat = $category_class->load( { id => $place->category_id } );
        $primary = $cat->label.'('.$cat->id.":".$cat->basename.')';
        while ($cat->parent != 0) {
            $cat = $category_class->load( { id => $cat->parent } );
            $primary = $cat->label.'('.$cat->id.":".$cat->basename.')'.$category_separator.$primary;
        }

        my @places = MT::Placement->load( { entry_id => $id, is_primary => 0 } );
        my @sec;
        foreach my $p (@places) {
            my $secondary = '';
            my $cat = $category_class->load( { id => $p->category_id } );
            $secondary .= $cat->label.'('.$cat->id.":".$cat->basename.')';
            while ($cat->parent != 0) {
                $cat = $category_class->load( { id => $cat->parent } );
                $secondary = $cat->label.'('.$cat->id.":".$cat->basename.')'.$category_separator.$secondary;
            }
            push(@sec, $secondary);
        }
        $data = $primary . (@sec ? "," . join(",", @sec) : '');
    }
    return $data;
}

sub _mt_postsave_obj {
    my ( $plugin, $obj ) = @_;

    if ( exists $obj->{changed_revisioned_cols} ) {
        my $col = 'max_revisions_' . $obj->datasource;
        if ( my $blog = $obj->blog ) {
            my $max = $blog->$col;
            $obj->handle_max_revisions($max);
        }
        my $revision = $obj->save_revision( $plugin->translate('for csv') );
        $obj->current_revision($revision);

        # call update to bypass instance save method
        $obj->update or return $obj->error( $obj->errstr );
        if ( $obj->has_meta('revision') ) {
            $obj->revision($revision);

            # hack to bypass instance save method
            $obj->{__meta}->set_primary_keys($obj);
            $obj->{__meta}->save;
        }
    }

    return 1;
}

1;
