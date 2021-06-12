# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package Trackback::DataAPI::Resource::Entry;

use strict;
use warnings;

use MT::DataAPI::Resource::Util;

sub updatable_fields {
    [qw( allowTrackbacks )];
}

sub fields {
    [   {   name                => 'allowTrackbacks',
            alias               => 'allow_pings',
            from_object_default => 0,
            type                => 'MT::DataAPI::Resource::DataType::Boolean',
        },
        {   name  => 'pingsSentUrl',
            alias => 'pinged_url_list',
        },
        {   name  => 'trackbackCount',
            alias => 'ping_count',
        },
        {   name        => 'trackbacks',
            from_object => sub {
                my ($obj) = @_;
                my $app = MT->instance;
                my $max
                    = MT::DataAPI::Resource::Util::int_param( $app,
                    'maxTrackbacks' )
                    or return [];
                my $user = $app->user;

                my $terms = undef;
                if ( !$user->is_superuser ) {
                    my $perm = $app->model('permission')->load(
                        {   author_id => $user->id,
                            blog_id   => $obj->blog_id,
                        },
                    );
                    if (!$perm
                        || !(
                               $perm->can_do('manage_feedback')
                            || $perm->can_do('manage_pages')
                            || (   $perm->can_do('create_post')
                                && $obj->author_id == $user->id )
                        )
                        )
                    {
                        require MT::TBPing;
                        $terms = {
                            visible     => 1,
                            junk_status => MT::TBPing::NOT_JUNK(),
                        };
                    }
                }

                my $args = {
                    sort      => 'id',
                    direction => 'ascend',
                    limit     => $max
                };
                MT::DataAPI::Resource->from_object(
                    $obj->pings( $terms, $args ) || [] );
            },
        },
    ];
}

1;

__END__

=head1 NAME

Trackback::DataAPI::Resource::Entry - Movable Type class for resources definitions of the MT::Entry.

=head1 AUTHOR & COPYRIGHT

Please see the I<MT> manpage for author, copyright, and license information.

=cut
