package Trackback::XMLRPCServer;

use strict;
use warnings;

sub _getTrackbackPings {
    my $entry_id = shift;

    require MT::Trackback;
    require MT::TBPing;
    my $tb = MT::Trackback->load( { entry_id => $entry_id } ) or return [];
    my $iter = MT::TBPing->load_iter( { tb_id => $tb->id } );
    my @data;

    while ( my $ping = $iter->() ) {
        push @data,
            {
            pingTitle => SOAP::Data->type( string => $ping->title || '' ),
            pingURL => SOAP::Data->type( string => $ping->source_url || '' ),
            pingIP  => SOAP::Data->type( string => $ping->ip         || '' ),
            };
    }
    \@data;
}

1;
