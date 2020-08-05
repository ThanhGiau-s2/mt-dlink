# Movable Type (r) (C) 2007-2019 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

# Original Copyright (c) 2005-2007 Arvind Satyanarayan

package CustomFields::XMLRPCServer;

use strict;
use CustomFields::Util qw( get_meta save_meta );

sub APIPostSave_entry {
    my ( $cb, $mt, $entry, $original ) = @_;

    require MT::XMLRPCServer;

# The following has been mostly copied from the KeyValues plugin
# by Brad Choate <http://bradchoate.com/weblog/2002/07/27/keyvalues>
# licensed under the MIT License <http://www.opensource.org/licenses/mit-license.php>

    my $delimiter = '=';

    my $t = $entry->text_more;
    $t = '' unless defined $t;

    my ( %values, @stripped, $need_closure, $line );

    my @lines = split /\r?\n/, $t;
    my $row   = 0;
    my $count = scalar(@lines);
    while ( $row < $count ) {
        $line = $lines[$row];
        chomp $line;
        if ( $line =~ m/^[A-Z0-9][^\s]+?$delimiter/io ) {

            # key/value!
            my ( $key, $value )
                = $line =~ m/^([A-Z0-9][^\s]+?)$delimiter(.*)/io;
            if ( $value eq $delimiter ) {
                $value = '';    # discard opening delimiter
                     # read additional lines until we find '$delimiter$key'
                $row++;
                $need_closure = $key;
                while ( $row < $count ) {
                    $line = $lines[$row];
                    chomp $line;
                    if ( $line =~ m/^$delimiter$delimiter$key\s*$/ ) {
                        undef $need_closure;
                        last;
                    }
                    else {
                        $value .= $line . "\n";
                    }
                    $row++;
                }
                chomp $value if $value;
            }

            $values{$key} = $value;
        }
        else {
            push @stripped, $line;
        }
        $row++;
    }
    if ($need_closure) {
        die MT::XMLRPCServer::_fault(
            "Key $need_closure was not closed properly: missing '$delimiter$delimiter$need_closure'"
        );
    }
    $t = join "\n", @stripped;
    $t = '' unless defined $t;

    $entry->text_more($t);
    $entry->save or die MT::XMLRPCServer::_fault( $entry->errstr );

    my $meta = get_meta($entry);
    foreach my $key ( keys %values ) {
        $meta->{$key} = $values{$key};
    }
    save_meta( $entry, $meta );
}

1;
