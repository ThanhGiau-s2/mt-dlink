# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package Trackback::App::ActivityFeed;

use strict;
use warnings;

sub _feed_ping {
    my ( $cb, $app, $view, $feed ) = @_;

    my $user = $app->user;

    require MT::Blog;
    my $blog;

    # verify user has permission to view pings for given weblog
    my $blog_id = $app->param('blog_id');
    if ($blog_id) {
        my $blog_ids;
        my $blog = MT->model('blog')->load($blog_id)
            or return $cb->error( $app->translate("Invalid request.") );
        if ( !$blog->is_blog ) {
            push @$blog_ids, map { $_->id } @{ $blog->blogs };
        }
        push @$blog_ids, $blog_id;

        my $iter = MT->model('permission')
            ->load_iter( { author_id => $user->id, blog_id => $blog_ids } );

        $blog_ids = ();
        while ( my $p = $iter->() ) {
            push @$blog_ids, $p->blog_id
                if $p->can_do('get_trackback_feed');
        }

        return $cb->error( $app->translate("No permissions.") )
            unless $blog_ids;

        $blog_id = join ',', @$blog_ids;
    }
    else {
        if ( !$user->is_superuser ) {

       # limit activity log view to only weblogs this user has permissions for
            require MT::Permission;
            my @perms = MT::Permission->load( { author_id => $user->id } );
            return $cb->error( $app->translate("No permissions.") )
                unless @perms;
            my @blog_list = map { $_->blog_id }
                grep { $_->can_do('get_trackback_feed') } @perms;
            push @blog_list, $_->blog_id foreach @perms;
            $blog_id = join ',', @blog_list;
        }
    }

    my $link = $app->base
        . $app->mt_uri(
        mode => 'list',
        args => {
            '_type' => 'ping',
            ( $blog ? ( blog_id => $blog_id ) : () ),
        }
        );
    my $param = {
        feed_link  => $link,
        feed_title => $blog
        ? $app->translate( '[_1] TrackBacks', $blog->name )
        : $app->translate("All TrackBacks")
    };

    # user has permissions to view this type of feed... continue
    my $terms = $app->apply_log_filter(
        {   filter     => 'class',
            filter_val => 'ping',
            $blog_id ? ( blog_id => $blog_id ) : (),
        }
    );
    $$feed = $app->process_log_feed( $terms, $param );
}

sub _filter_ping {
    my ( $cb, $app, $item ) = @_;
    my $user = $app->user;

    return 0 if !exists $item->{'log.tbping.id'};
    my $own  = $item->{'log.tbping.entry.author.id'} == $user->id;
    my $perm = $user->permissions( $item->{'log.tbping.blog.id'} )
        or return 0;

    if (   !$app->can_do('get_all_system_feed')
        && !$perm->can_do('get_system_feed') )
    {
        if ( !$perm->can_do('view_all_trackbacks') ) {
            return 0 if !$own;
            return 0 if $own && !$perm->can_do('view_own_entry_trackback');
        }
    }

    $item->{'log.tbping.can_edit'} = 1
        if $own && $perm->can_do('edit_own_entry_trackback_without_status')
        || $perm->can_do('view_all_trackback');
    $item->{'log.tbping.can_change_status'}
        = $perm->can_do('edit_trackback_status') ? 1 : 0;

    return 1;
}

1;
