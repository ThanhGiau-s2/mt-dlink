# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package Trackback::CMS::Search;

use strict;
use warnings;

sub search_apis {
    return +{
        ping => {
            order       => 300,
            condition   => \&condition,
            label       => 'Trackbacks',
            handler     => '$Trackback::MT::CMS::TrackBack::build_ping_table',
            perm_check  => \&perm_check,
            search_cols => {
                title      => sub { MT->translate('Title') },
                excerpt    => sub { MT->translate('Excerpt') },
                source_url => sub { MT->translate('Source URL') },
                ip         => sub { MT->translate('IP Address') },
                blog_name  => sub { MT->translate('Site Name') },
            },
            replace_cols       => [qw/title excerpt/],
            can_replace        => 1,
            can_search_by_date => 1,
            setup_terms_args   => \&setup_terms_args,
        },
    };
}

sub condition {
    my $app     = MT->app;
    my $blog_id = $app->param('blog_id');
    my $author  = $app->user;
    return 1 if $author->is_superuser;

    my $cnt = MT->model('permission')->count(
        [   {   (     ($blog_id)
                    ? ( blog_id => $blog_id )
                    : ( blog_id => \'> 0' )
                ),
                author_id => $author->id,
            },
            '-and',
            [   { permissions => { like => "\%'create_post'\%" } },
                '-or',
                { permissions => { like => "\%'publish_post'\%" } },
                '-or',
                { permissions => { like => "\%'edit_all_posts'\%" } },
                '-or',
                { permissions => { like => "\%'manage_feedback'\%" } },
            ],
        ]
    );

    return ( $cnt && $cnt > 0 ) ? 1 : 0;
}

sub perm_check {
    my $author = MT->app->user;
    my $ping   = shift;
    require MT::Trackback;
    my $tb = MT::Trackback->load( $ping->tb_id )
        or return undef;
    if ( $tb->entry_id ) {
        my $entry = MT->model('entry')->load( $tb->entry_id );
        return 1
            if $author->permissions( $entry->blog_id )
            ->can_do('manage_feedback')
            || $author->permissions( $entry->blog_id )
            ->can_edit_entry( $entry, $author );
    }
    elsif ( $tb->category_id ) {
        return 1
            if $author->permissions( $tb->blog_id )
            ->can_do('search_category_trackbacks');
    }
    return 0;
}

sub setup_terms_args {
    my ( $terms, $args, $blog_id ) = @_;
    $args->{sort}      = 'created_on';
    $args->{direction} = 'descend';
}

1;
