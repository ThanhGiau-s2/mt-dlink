# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package Trackback::Entry;

use strict;
use warnings;
use MT::Util qw( extract_domain extract_domains );

sub init {
    no warnings 'redefine';
    *MT::Entry::pings                  = \&_pings;
    *MT::Entry::trackback              = \&_trackback;
    *MT::Entry::discover_tb_from_entry = \&_discover_tb_from_entry;

    MT::TBPing->add_callback( 'post_save', 0, MT->component('core'),
        \&__update_ping_count );

    MT::TBPing->add_callback( 'post_remove', 0, MT->component('core'),
        \&__update_ping_count );
}

sub __update_ping_count {
    my ( $cb, $ping ) = @_;
    require MT::Trackback;
    return unless $ping->tb_id;
    my $tb = MT::Trackback->load( $ping->tb_id ) or return;
    return unless $tb->entry_id;
    my $entry = MT::Entry->load( $tb->entry_id ) or return;
    my $count = MT::TBPing->count(
        {   tb_id   => $tb->id,
            visible => 1,
        }
    );
    return if $entry->ping_count == $count;
    $entry->ping_count($count);
    $entry->save;
}

sub _pings {
    my $entry = shift;
    my ( $terms, $args ) = @_;
    my $tb = $entry->trackback;
    return undef unless $tb;
    if ( $terms || $args ) {
        $terms ||= {};
        $terms->{tb_id} = $tb->id;
        return [ MT::TBPing->load( $terms, $args ) ];
    }
    else {
        $entry->cache_property(
            'pings',
            sub {
                [ MT::TBPing->load( { tb_id => $tb->id } ) ];
            }
        );
    }
}

sub _trackback {
    my $entry = shift;
    $entry->cache_property(
        'trackback',
        sub {
            require MT::Trackback;
            if ( $entry->id ) {
                return
                    scalar MT::Trackback->load( { entry_id => $entry->id } );
            }
        },
        @_
    );
}

sub _save_trackback {
    my $entry = shift;

    require MT::Trackback;
    if ( $entry->allow_pings ) {
        my $tb;
        unless ( $tb = $entry->trackback ) {
            $tb = MT::Trackback->new;
            $tb->blog_id( $entry->blog_id );
            $tb->entry_id( $entry->id );
            $tb->category_id(0);    ## category_id can't be NULL
        }
        $tb->title( $entry->title );
        $tb->description( $entry->get_excerpt );
        $tb->url( $entry->permalink );
        $tb->is_disabled(0);
        $tb->save
            or return $entry->error( $tb->errstr );
        $entry->trackback($tb);
    }
    else {
        ## If there is a TrackBack item for this entry, but
        ## pings are now disabled, make sure that we mark the
        ## object as disabled.
        my $tb = $entry->trackback;
        if ( $tb && !$tb->is_disabled ) {
            $tb->is_disabled(1);
            $tb->save
                or return $entry->error( $tb->errstr );
        }
    }
}

sub _discover_tb_from_entry {
    my $entry = shift;
    ## If we need to auto-discover TrackBack ping URLs, do that here.
    my $cfg     = MT->config;
    my $blog    = $entry->blog();
    my $send_tb = $cfg->OutboundTrackbackLimit;
    if (   $send_tb ne 'off'
        && $blog
        && (   $blog->autodiscover_links
            || $blog->internal_autodiscovery )
        )
    {
        my @tb_domains;
        if ( $send_tb eq 'selected' ) {
            @tb_domains = $cfg->OutboundTrackbackDomains;
        }
        elsif ( $send_tb eq 'local' ) {
            my $iter = MT::Blog->load_iter( undef,
                { fetchonly => ['site_url'], no_triggers => 1 } );
            while ( my $b = $iter->() ) {
                next if $b->id == $blog->id;
                push @tb_domains, extract_domain( $b->site_url );
            }
        }
        my $tb_domains;
        if (@tb_domains) {
            $tb_domains = '';
            my %seen;
            foreach (@tb_domains) {
                next unless $_;
                $_ = lc($_);
                next if $seen{$_};
                $tb_domains .= '|' if $tb_domains ne '';
                $tb_domains .= quotemeta($_);
                $seen{$_} = 1;
            }
            $tb_domains = '(' . $tb_domains . ')' if $tb_domains;
        }
        my $archive_domain;
        ($archive_domain) = extract_domains( $blog->archive_url );
        my %to_ping = map { $_ => 1 } @{ $entry->to_ping_url_list };
        my %pinged  = map { $_ => 1 }
            @{ $entry->pinged_url_list( IncludeFailures => 1 ) };
        my $body = $entry->text . ( $entry->text_more || "" );
        $body = MT->apply_text_filters( $body, $entry->text_filters );

        require Trackback::Util;
        while ( $body =~ m!<a\s.*?\bhref\s*=\s*(["']?)([^'">]+)\1!gsi ) {
            my $url = $2;
            my $url_domain;
            ($url_domain) = extract_domains($url);
            if ( $url_domain =~ m/\Q$archive_domain\E$/i ) {
                next if !$blog->internal_autodiscovery;
            }
            else {
                next if !$blog->autodiscover_links;
            }
            next if $tb_domains && lc($url_domain) !~ m/$tb_domains$/;
            if ( my $item = Trackback::Util::discover_tb($url) ) {
                $to_ping{ $item->{ping_url} } = 1
                    unless $pinged{ $item->{ping_url} };
            }
        }
        $entry->to_ping_urls( join "\n", keys %to_ping );
    }
}

1;
