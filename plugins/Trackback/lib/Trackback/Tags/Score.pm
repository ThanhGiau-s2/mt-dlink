# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$
package Trackback::Tags::Score;

use strict;
use warnings;
use MT::Template::Tags::Score;

###########################################################################

=head2 PingScore

A function tag that provides total score of the TrackBack ping in context.
Scores grouped by namespace of a plugin are summed to calculate total
score of a TrackBack ping.

B<Attributes:>

=over 4

=item * namespace (required)

Specify namespace for the score to be sorted. Namespace is defined by each
plugin which leverages rating API.

=back

B<Example:>

    <$mt:PingScore namespace="FiveStarRating"$>

=for tags pings, scoring

=cut

sub _hdlr_ping_score {
    return MT::Template::Tags::Score::_object_score_for( 'ping', @_ );
}

###########################################################################

=head2 PingScoreHigh

A function tag that provides the highest score of the TrackBack ping
in context. Scorings grouped by namespace of a plugin are sorted to
find the highest score of a TrackBack ping.

B<Attributes:>

=over 4

=item * namespace (required)

Specify namespace for the score to be sorted. Namespace is defined by each
plugin which leverages rating API.

=back

B<Example:>

    <$mt:PingScoreHigh namespace="FiveStarRating"$>

=for tags pings, scoring

=cut

sub _hdlr_ping_score_high {
    return MT::Template::Tags::Score::_object_score_high( 'ping', @_ );
}

###########################################################################

=head2 PingScoreLow

A function tag that provides the lowest score of the TrackBack ping in context. Scorings grouped by namespace of a plugin are sorted to find the lowest score of a TrackBack ping.

B<Attributes:>

=over 4

=item * namespace (required)

Specify namespace for the score to be sorted. Namespace is defined by each
plugin which leverages rating API.

=back

B<Example:>

    <$mt:PingScoreLow namespace="FiveStarRating"$>

=for tags pings, scoring

=cut

sub _hdlr_ping_score_low {
    return MT::Template::Tags::Score::_object_score_low( 'ping', @_ );
}

###########################################################################

=head2 PingScoreAvg

A function tag that provides the avarage score of the TrackBack ping in
context. Scores grouped by namespace of a plugin are summed to calculate
total score of a TrackBack ping, and average is calculated by dividing the
total score by the number of scorings or 'votes'.

B<Attributes:>

=over 4

=item * namespace (required)

Specify namespace for avarage score to be calculated. Namespace is defined by
each plugin which leverages rating API.

=back

B<Example:>

    <$mt:PingScoreAvg namespace="FiveStarRating"$>

=for tags pings, scoring

=cut

sub _hdlr_ping_score_avg {
    return MT::Template::Tags::Score::_object_score_avg( 'ping', @_ );
}

###########################################################################

=head2 PingScoreCount

A function tag that provides the number of scorings or 'votes' made to the
TrackBack ping in context. Scorings grouped by namespace of a plugin are
summed.

B<Attributes:>

=over 4

=item * namespace (required)

Specify namespace for the number of scorings to be calculated. Namespace is
defined by each plugin which leverages rating API.

=back

B<Example:>

    <$mt:PingScoreCount namespace="FiveStarRating"$>

=for tags pings, scoring

=cut

sub _hdlr_ping_score_count {
    return MT::Template::Tags::Score::_object_score_count( 'ping', @_ );
}

###########################################################################

=head2 PingRank

A function tag which returns a number from 1 to 6 (by default) which
represents the rating of the TrackBack ping in context in terms of total score
where '1' is used for the highest score, '6' for the lowest score.

B<Attributes:>

=over 4

=item * namespace (required)

Specify namespace for rank to be calculated. Namespace is defined by each plugin which leverages rating API.

=item * max (optional; default "6")

Allows a user to specify the upper bound of the scale.

=back

B<Example:>

    <$mt:PingRank namespace="FiveStarRating"$>

=for tags pings, scoring

=cut

sub _hdlr_ping_rank {
    return MT::Template::Tags::Score::_object_rank(
        'ping',
        {   'join' => MT->model('ping')->join_on(
                undef, { id => \'= objectscore_object_id', visible => 1, }
            )
        },
        @_
    );
}

###########################################################################

1;
