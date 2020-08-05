# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package Trackback::DataAPI::Resource::v2::Blog;

use strict;
use warnings;

sub updatable_fields {
    [
        # v2 fields

        # Compose Settings screen
        qw( allowPingsDefault ),

        # Feedback Settings screen
        qw(
            allowPings
            moderatePings
            emailNewPings
            ),

        # Web Services Settings screen
        qw(
            pingGoogle
            pingWeblogs
            pingOthers
            ),
    ];
}

sub fields {
    [   {   name      => 'allowPingsDefault',
            alias     => 'allow_pings_default',
            type      => 'MT::DataAPI::Resource::DataType::Boolean',
            condition => \&_can_view_cfg_screens,
        },
        {   name      => 'allowPings',
            alias     => 'allow_pings',
            type      => 'MT::DataAPI::Resource::DataType::Boolean',
            condition => \&_can_view_cfg_screens,
        },
        {   name      => 'moderatePings',
            alias     => 'moderate_pings',
            type      => 'MT::DataAPI::Resource::DataType::Boolean',
            condition => \&_can_view_cfg_screens,
        },
        {   name      => 'emailNewPings',
            alias     => 'email_new_pings',         # Not boolean.
            condition => \&_can_view_cfg_screens,
        },

        # Web Services Settings screen
        {   name      => 'pingGoogle',
            alias     => 'ping_google',
            type      => 'MT::DataAPI::Resource::DataType::Boolean',
            condition => \&_can_view_cfg_screens,
        },
        {   name      => 'pingWeblogs',
            alias     => 'ping_weblogs',
            type      => 'MT::DataAPI::Resource::DataType::Boolean',
            condition => \&_can_view_cfg_screens,
        },
        {   name        => 'pingOthers',
            alias       => 'ping_others',
            from_object => sub {
                my ($obj) = @_;
                return [
                    split /\r?\n/,
                    defined $obj->ping_others ? $obj->ping_others : ''
                ];
            },
            to_object => sub {
                my ($hash) = @_;
                return join "\n", @{ $hash->{pingOthers} };
            },
            codition => \&_can_view_cfg_screens,
        },
    ];
}

sub _can_view_cfg_screens {
    my $app = MT->instance;
    return $app->can_do('edit_config');
}

1;
