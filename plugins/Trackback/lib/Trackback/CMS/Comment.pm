# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package Trackback::CMS::Comment;

use strict;
use warnings;
use MT::Util qw( encode_html );

sub approve_item {
    my $app   = shift;
    my $perms = $app->permissions;
    $app->param( 'approve', 1 );
    set_item_visible($app);
}

sub unapprove_item {
    my $app   = shift;
    my $perms = $app->permissions;
    $app->param( 'unapprove', 1 );
    set_item_visible($app);
}

sub empty_junk {
    my $app      = shift;
    my $perms    = $app->permissions;
    my $user     = $app->user;
    my $blog     = $app->blog;
    my $blog_ids = [];

    $app->validate_magic() or return;

    if ($blog) {
        push @$blog_ids, $blog->id
            if $user->permissions( $blog->id )
            ->can_do('delete_junk_comments');
        if ( !$blog->is_blog ) {
            foreach my $b ( @{ $blog->blogs } ) {
                push @$blog_ids, $b->id
                    if $user->permissions( $b->id )
                    ->can_do('delete_junk_comments');
            }
        }
        return $app->permission_denied() unless @$blog_ids;
    }
    else {
        $app->can_do('delete_all_junk_comments')
            or return $app->permission_denied();
    }

    my $type  = $app->param('_type') || '';
    my $class = $app->model($type);
    my $arg   = {};
    require MT::Comment;
    $arg->{junk_status} = MT::Comment::JUNK();
    $arg->{blog_id} = $blog_ids if @$blog_ids;
    $class->remove($arg);
    $app->add_return_arg( 'emptied' => 1 );
    $app->call_return;
}

sub handle_junk {
    my $app   = shift;
    my @ids   = $app->multi_param("id");
    my $type  = $app->param("_type");
    my $class = $app->model($type);
    my @item_loop;
    my $i       = 0;
    my $blog_id = $app->param('blog_id');
    my ( %rebuild_entries, %rebuild_categories );

    if ( my $req_nonce = $app->param('nonce') ) {
        if ( scalar @ids == 1 ) {
            my $cmt_id = $ids[0];
            if ( my $obj = $class->load($cmt_id) ) {
                my $nonce
                    = MT::Util::perl_sha1_digest_hex( $obj->id
                        . $obj->created_on
                        . $obj->blog_id
                        . $app->config->SecretToken );
                return $app->errtrans("Invalid request.")
                    unless $nonce eq $req_nonce;
                my $return_args = $app->uri_params(
                    mode => 'view',
                    args => {
                        '_type' => $type,
                        id      => $cmt_id,
                        blog_id => $obj->blog_id
                    }
                );
                $return_args =~ s!^\?!!;
                $app->return_args($return_args);
            }
            else {
                return $app->errtrans("Invalid request.");
            }
        }
        else {
            return $app->errtrans("Invalid request.");
        }
    }
    else {
        $app->validate_magic() or return;
    }

    foreach my $id (@ids) {
        next unless $id;

        my $obj = $class->load($id) or die "No $class $id";
        my $perms = $app->user->permissions( $obj->blog_id )
            or return $app->permission_denied();
        my $perm_checked = $perms->can_do('handle_junk');
        my $old_visible = $obj->visible || 0;
        unless ($perm_checked) {
            if ( $obj->isa('MT::TBPing') && $obj->parent->isa('MT::Entry') ) {
                return $app->permission_denied()
                    if $obj->parent->author_id != $app->user->id;
            }
            elsif ($obj->isa('MT::TBPing')
                && $obj->parent->isa('MT::Category') )
            {
                return $app->permission_denied()
                    unless $perms->can_do(
                    'handle_junk_for_category_trackback');
            }
            elsif ( $obj->isa('MT::Comment') ) {
                return $app->permission_denied()
                    if $obj->entry->author_id != $app->user->id;
            }
            return $app->permission_denied()
                unless $perms->can_do('handle_junk_for_own_entry');
        }
        $obj->junk;
        $app->run_callbacks( 'handle_spam', $app, $obj )
            ;          # mv this into blk below?
        $obj->save;    # (so that each cb doesn't have to save indiv'ly)
        next if $old_visible == $obj->visible;
        if ( $obj->isa('MT::TBPing') ) {
            my ( $parent_type, $parent_id ) = $obj->parent_id();
            if ( $parent_type eq 'MT::Entry' ) {
                $rebuild_entries{$parent_id} = 1;
            }
            else {
                $rebuild_categories{$parent_id} = 1;

                # TODO: do something with this list.
            }
        }
        else {
            $rebuild_entries{ $obj->entry_id } = 1;
        }
    }
    $app->add_return_arg( 'junked' => 1 );
    if (%rebuild_entries) {
        $app->rebuild_these( \%rebuild_entries,
            how => MT::App::CMS::NEW_PHASE() );
    }
    else {
        $app->call_return;
    }
}

sub not_junk {
    my $app = shift;
    $app->validate_magic or return;

    my @ids = $app->multi_param("id");
    my @item_loop;
    my $i     = 0;
    my $type  = $app->param('_type');
    my $class = $app->model($type);
    my %rebuild_set;

    foreach my $id (@ids) {
        next unless $id;
        my $obj = $class->load($id)
            or next;
        my $perms = $app->user->permissions( $obj->blog_id )
            or return $app->permission_denied();
        my $perm_checked = $perms->can_do('handle_not_junk');

        unless ($perm_checked) {
            if ( $obj->isa('MT::TBPing') && $obj->parent->isa('MT::Entry') ) {
                return $app->permission_denied()
                    if $obj->parent->author_id != $app->user->id;
            }
            elsif ($obj->isa('MT::TBPing')
                && $obj->parent->isa('MT::Category') )
            {
                return $app->permission_denied()
                    unless $perms->can_do(
                    'handle_junk_for_category_trackback');
            }
            elsif ( $obj->isa('MT::Comment') ) {
                return $app->permission_denied()
                    if $obj->entry->author_id != $app->user->id;
            }
            return $app->permission_denied()
                unless $perms->can_do('handle_not_junk_for_own_entry');
        }
        $obj->approve;
        $app->run_callbacks( 'handle_ham', $app, $obj );
        if ( $obj->isa('MT::TBPing') ) {
            my ( $parent_type, $parent_id ) = $obj->parent_id();
            if ( $parent_type eq 'MT::Entry' ) {
                $rebuild_set{$parent_id} = 1;
            }
            else {
            }
        }
        else {
            $rebuild_set{ $obj->entry_id } = 1;
        }
        $obj->save();
    }
    $app->param( 'approve', 1 );

    $app->add_return_arg( 'unjunked' => 1 );

    $app->rebuild_these( \%rebuild_set, how => MT::App::CMS::NEW_PHASE() );
}

sub build_junk_table {
    my $app = shift;
    my (%args) = @_;

    my $param = $args{param};
    my $obj   = $args{object};

    if ( defined $obj->junk_score ) {
        $param->{junk_score}
            = ( $obj->junk_score > 0 ? '+' : '' ) . $obj->junk_score;
    }
    my $log = $obj->junk_log || '';
    my @log = split /\r?\n/, $log;
    my @junk;
    for ( my $i = 0; $i < scalar(@log); $i++ ) {
        my $line = $log[$i];
        $line =~ s/(^\s+|\s+$)//g;
        next unless $line;
        last if $line =~ m/^--->/;
        my ( $test, $score, $log );
        ($test) = $line =~ m/^([^:]+?):/;
        if ( defined $test ) {
            ($score) = $test =~ m/\(([+-]?\d+?(?:\.\d*?)?)\)/;
            $test =~ s/\(.+\)//;
        }
        if ( defined $score ) {
            $score =~ s/\+//;
            $score .= '.0' unless $score =~ m/\./;
            $score = ( $score > 0 ? '+' : '' ) . $score;
        }
        $log = $line;
        $log =~ s/^[^:]+:\s*//;
        $log = encode_html($log);
        for ( my $j = $i + 1; $j < scalar(@log); $j++ ) {
            my $line = encode_html( $log[$j] );
            if ( $line =~ m/^\t+(.*)$/s ) {
                $i = $j;
                $log .= "<br />" . $1;
            }
            else {
                last;
            }
        }
        push @junk, { test => $test, score => $score, log => $log };
    }
    $param->{junk_log_loop} = \@junk;
    \@junk;
}

sub set_item_visible {
    my $app    = shift;
    my $perms  = $app->permissions;
    my $author = $app->user;

    my $type = $app->param('_type');
    return $app->errtrans("Invalid request.")
        unless grep { $_ eq $type } qw{comment ping tbping ping_cat};

    my $class = $app->model($type);
    $app->setup_filtered_ids
        if $app->param('all_selected');
    my @obj_ids = $app->multi_param('id');

    if ( my $req_nonce = $app->param('nonce') ) {
        if ( scalar @obj_ids == 1 ) {
            my $cmt_id = $obj_ids[0];
            if ( my $obj = $class->load($cmt_id) ) {
                my $nonce
                    = MT::Util::perl_sha1_digest_hex( $obj->id
                        . $obj->created_on
                        . $obj->blog_id
                        . $app->config->SecretToken );
                return $app->errtrans("Invalid request.")
                    unless $nonce eq $req_nonce;
                my $return_args = $app->uri_params(
                    mode => 'view',
                    args => {
                        '_type' => $type,
                        id      => $cmt_id,
                        blog_id => $obj->blog_id
                    }
                );
                $return_args =~ s!^\?!!;
                $app->return_args($return_args);
            }
            else {
                return $app->errtrans("Invalid request.");
            }
        }
        else {
            return $app->errtrans("Invalid request.");
        }
    }
    else {
        $app->validate_magic() or return;
    }

    my $new_visible;
    if ( $app->param('approve') ) {
        $new_visible = 1;
    }
    elsif ( $app->param('unapprove') ) {
        $new_visible = 0;
    }

    my %rebuild_set = ();
    require MT::Entry;
    foreach my $id (@obj_ids) {
        my $obj = $class->load($id)
            or next;
        my $old_visible = $obj->visible || 0;
        if ( $old_visible != $new_visible ) {
            if ( $obj->isa('MT::TBPing') ) {
                my $obj_parent = $obj->parent();
                if ( $obj_parent->isa('MT::Category') ) {
                    my $blog = MT::Blog->load( $obj_parent->blog_id );
                    next unless $blog;
                    $app->publisher->_rebuild_entry_archive_type(
                        Entry       => undef,
                        Blog        => $blog,
                        Category    => $obj_parent,
                        ArchiveType => 'Category'
                    );
                }
                else {
                    if ( !$perms || $perms->blog_id != $obj->blog_id ) {
                        $perms = $author->permissions( $obj->blog_id );
                    }
                    if ( !$app->can_do( 'approve_all_trackback', $perms ) ) {
                        if ($app->can_do(
                                'approve_own_entry_trackback', $perms
                            )
                            )
                        {
                            return $app->errtrans(
                                "You do not have permission to approve this trackback."
                            ) if $obj_parent->author_id != $author->id;
                        }
                        else {
                            return $app->errtrans(
                                "You do not have permission to approve this trackback."
                            );
                        }
                    }
                    $rebuild_set{ $obj_parent->id } = $obj_parent;
                }
            }
            elsif ( $obj->entry_id ) {

                # TODO: Factor out permissions checking
                my $entry = MT::Entry->load( $obj->entry_id )
                    || return $app->error(
                    $app->translate(
                        "The entry corresponding to this comment is missing.")
                    );

                if ( !$perms || $perms->blog_id != $obj->blog_id ) {
                    $perms = $author->permissions( $obj->blog_id );
                }
                unless ($perms) {
                    return $app->errtrans(
                        "You do not have permission to approve this comment."
                    );
                }
                if ( !$app->can_do( 'approve_all_comment', $perms ) ) {
                    if ( $app->can_do( 'approve_own_entry_comment', $perms ) )
                    {
                        return $app->errtrans(
                            "You do not have permission to approve this comment."
                        ) if $entry->author_id != $author->id;
                    }
                    else {
                        return $app->errtrans(
                            "You do not have permission to approve this comment."
                        );
                    }
                }
                $rebuild_set{ $obj->entry_id } = $entry;
            }
            if ($new_visible) {
                $obj->approve;
            }
            else {
                $obj->visible($new_visible);
            }
            $obj->save();
        }
    }
    my $approved_flag = ( $new_visible ? '' : 'un' ) . 'approved';
    $app->add_return_arg( $approved_flag => 1 );
    return $app->rebuild_these( \%rebuild_set,
        how => MT::App::CMS::NEW_PHASE() );
}

1;
