package DateDiff::Plugin;

use strict;

use MT;
use Time::Local;
use POSIX qw( floor );

sub date_diff {
    my ($ctx, $args) = @_;

    my %unit = (
        'y' => 0,
        'n' => 1,
        'd' => 2,
        'h' => 3,
        'm' => 4,
        's' => 5,
    );

    my $blog = $ctx->stash('blog');
    my $ts;
    if ($args->{ts}) {
        $ts = $args->{ts};
    }
    else {
        my $tag = $args->{tag} || 'date';
        $ts = $ctx->invoke_handler($tag, { format => '%Y%m%d%H%M%S' });
    }
    my @ts = unpack('A4A2A2A2A2A2', $ts);
    my $offset = $args->{offset} || '0s';
    while ($offset =~ /([\-\+]?\d+)([yndhmsw])/g) {
        if ($2 eq 'w') {
            $ts[2] += $1 * 7;
        }
        else {
            $ts[$unit{$2}] += $1;
        }
    }
    $ts[0] += floor(($ts[1] - 1) / 12);
    $ts[1] = ($ts[1] - 1) % 12 + 1;
    my $epoch = Time::Local::timegm_nocheck($ts[5], $ts[4], $ts[3], $ts[2], $ts[1] - 1, $ts[0]);
    my ($s, $m, $h, $d, $mo, $y) = gmtime($epoch);
    $ts = sprintf( "%04d%02d%02d%02d%02d%02d", $y + 1900, $mo + 1, $d, $h, $m, $s );
    delete $args->{tag};
    $args->{ts} = $ts;
    return $ctx->invoke_handler('date', $args);
}

1;
