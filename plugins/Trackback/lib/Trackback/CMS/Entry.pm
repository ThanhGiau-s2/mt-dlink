package Trackback::CMS::Entry;

use strict;
use warnings;

sub send_pings {
    my $app = shift;
    $app->validate_magic() or return;

    my $entry_id   = $app->param('entry_id');
    my $blog_id    = $app->param('blog_id');
    my $old_status = $app->param('old_status');

    do_send_pings(
        $app, $blog_id,
        $entry_id,
        $old_status,
        sub {
            my ($has_errors) = @_;
            my $entry        = $app->model('entry')->load($entry_id);
            my $is_new       = $app->param('is_new');
            _finish_rebuild_ping( $app, $entry, $is_new, $has_errors );
        }
    );
}

sub do_send_pings {
    my $app = shift;
    my ( $blog_id, $entry_id, $old_status, $callback ) = @_;

    require MT::Entry;
    require MT::Blog;
    my $blog = MT::Blog->load($blog_id)
        or return $app->errtrans('Invalid request');
    my $entry = MT::Entry->load($entry_id)
        or return $app->errtrans('Invalid request');

    return $app->permission_denied()
        unless $app->user->permissions( $entry->blog->id )
        ->can_do( 'send_update_pings_' . $entry->class );

    ## MT::ping_and_save pings each of the necessary URLs, then processes
    ## the return value from MT::ping to update the list of URLs pinged
    ## and not successfully pinged. It returns the return value from
    ## MT::ping for further processing. If a fatal error occurs, it returns
    ## undef.
    my $results = $app->ping_and_save(
        Blog      => $blog,
        Entry     => $entry,
        OldStatus => $old_status,
    ) or return;
    my $has_errors = 0;
    require MT::Log;
    for my $res (@$results) {
        $has_errors++,
            $app->log(
            {   message => $app->translate(
                    "Ping '[_1]' failed: [_2]", $res->{url},
                    $res->{error}
                ),
                class    => 'ping',
                level    => MT::Log::WARNING(),
                category => 'send_ping',
            }
            ) unless $res->{good};
    }

    $callback->($has_errors);
}

sub _finish_rebuild_ping {
    my $app = shift;
    my ( $entry, $is_new, $ping_errors ) = @_;
    $app->redirect(
        $app->uri(
            'mode' => 'view',
            args   => {
                '_type' => $entry->class,
                blog_id => $entry->blog_id,
                id      => $entry->id,
                ( $is_new ? ( saved_added => 1 ) : ( saved_changes => 1 ) ),
                ( $ping_errors ? ( ping_errors => 1 ) : () )
            }
        )
    );
}

sub ping_continuation {
    my $app = shift;
    my ( $entry, $blog, %options ) = @_;
    my $list = $app->needs_ping(
        Entry     => $entry,
        Blog      => $blog,
        OldStatus => $options{OldStatus}
    );
    require MT::Entry;
    if ( $entry->status == MT::Entry::RELEASE() && $list ) {
        my @urls = map { { url => $_ } } @$list;
        $app->load_tmpl(
            'pinging.tmpl',
            {   blog_id    => $blog->id,
                entry_id   => $entry->id,
                old_status => $options{OldStatus},
                is_new     => $options{IsNew},
                url_list   => \@urls,
            }
        );
    }
    else {
        _finish_rebuild_ping( $app, $entry, $options{IsNew} );
    }
}

1;
