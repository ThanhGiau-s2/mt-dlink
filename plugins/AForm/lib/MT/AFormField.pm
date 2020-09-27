# A plugin for adding "A-Form" functionality.
# Copyright (c) 2008 ARK-Web Co.,Ltd.

package MT::AFormField;

use strict;
use MT::Util qw( days_in );

use MT::Object;
@MT::AFormField::ISA = qw(MT::Object);
__PACKAGE__->install_properties({
	column_defs => {
		'id' => 'integer not null auto_increment',
		'aform_id' => 'integer not null',
		'type' => 'string(10) not null',
		'label' => 'text',
		'is_necessary' => 'boolean',
		'sort_order' => 'integer',
		'property' => 'text',
		'parts_id' => 'string(100)',
	},
	indexes => {
		'id' => 1,
		'aform_id' => 1,
                'type' => 1,
                'sort_order' => 1,
		'parts_id' => 1,
	},
        defaults => {
        },
	audit => 1,
	datasource => 'aform_field',
	primary_key => 'id'
});

sub options {
    my $self = shift;

    my $property = $self->_get_property();
    my $options = $property->{options};
    if ( ref($options) eq 'ARRAY' ) {
        for ( my $i=0; $i<@$options; $i++ ) {
            $options->[$i]->{'index'} = $i+1; 
        }
    }
    return $options;
}

sub use_default {
    my $self = shift;

    my $property = $self->_get_property();
    return $property->{use_default};
}

sub default_label {
    my $self = shift;

    my $property = $self->_get_property();
    return $property->{default_label};
}

sub privacy_link {
    my $self = shift;

    my $property = $self->_get_property();
    return $property->{privacy_link};
}

sub is_replyed {
    my $self = shift;

    my $property = $self->_get_property();
    return $property->{is_replyed};
}

sub input_example {
    my $self = shift;

    my $property = $self->_get_property();
    return $property->{input_example};
}

sub min_length {
    my $self = shift;

    my $property = $self->_get_property();
    return $property->{min_length};
}

sub max_length {
    my $self = shift;

    my $property = $self->_get_property();
    return $property->{max_length};
}

sub upload_type {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{upload_type};
}

sub upload_size {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{upload_size};
}

sub upload_size_numeric {
    my $self = shift;

    my $property = $self->_get_property;
    my $size_text = $property->{upload_size};

    if( !$size_text ){
      return 0;
    }

    # remove [,]
    $size_text =~ s/,//g;

    # calc size
    my $size = 0;
    if( $size_text =~ m/K$/i ){
      $size = sprintf("%0.1f", $size_text) * 1024;
    }elsif( $size_text =~ m/M$/i ){
      $size = sprintf("%0.1f", $size_text) * 1024 * 1024;
    }elsif( $size_text =~ m/G$/i ){
      $size = sprintf("%0.1f", $size_text) * 1024 * 1024 * 1024;
    }else{
      $size = sprintf("%0.1f", $size_text);
    }
    return $size;
}

sub parameter_name {
    my $self = shift;

    my $property = $self->_get_property();
    return $property->{parameter_name};
}

sub show_parameter {
    my $self = shift;

    my $property = $self->_get_property();
    return $property->{show_parameter};
}

sub range_from {
    my $self = shift;

    my $property = $self->_get_property();
    return $property->{range_from};
}

sub range_to {
    my $self = shift;

    my $property = $self->_get_property();
    return $property->{range_to};
}

sub default_value {
    my $self = shift;

    my $property = $self->_get_property();
    my($ss,$ii,$hh,$dd,$mm,$yy) = localtime();
    $yy += 1900;
    $mm += 1;
    if( $property->{default_value} && $property->{default_value} eq 'today' ){
        ;
    }elsif( $property->{default_value} && $property->{default_value} =~ m/([\+\-]\d+)((day|month|year))/ ){
        if( $2 eq 'year' ){
            $yy += int($1);
            my $days_in = days_in($mm, $yy);
            if( $dd > $days_in ){
                $dd = $days_in;
            }
        }elsif( $2 eq 'month' ){
            $mm += int($1);
            if( $mm > 12 ){
                $yy += 1;
                $mm -= 12;
            }
            if( $mm < 1 ){
                $yy -= 1;
                $mm += 12;
            }
            my $days_in = days_in($mm, $yy);
            if( $dd > $days_in ){
                $dd = $days_in;
            }
        }elsif( $2 eq 'day' ){
            ($ss,$ii,$hh,$dd,$mm,$yy) = localtime(time + int($1) * 24*3600);
            $yy += 1900;
            $mm += 1;
        }
    }else{
        $yy = $mm = $dd= '';
    }
    my %ret = ('yy' => $yy, 'mm' => $mm, 'dd' => $dd, 'text' => $property->{default_value});
    return \%ret;
}

sub _get_property {
    my $self = shift;

    return $self->{cache_property} if $self->{cache_property};

    my $property = $self->property;
    require AFormEngineCGI::Common;
    my $data = AFormEngineCGI::Common::json_to_obj($self->property);
    unless (defined $data->{require_hyphen}) {
        if ($self->type eq 'zipcode') {
            $data->{require_hyphen} = 1;
        }
        elsif ($self->type eq 'tel') {
            $data->{require_hyphen} = 0;
        }
    }
    $self->{cache_property} = MT::Util::deep_copy($data, MT->config->DeepCopyRecursiveLimit);
    return $self->{cache_property};
}

sub require_twice {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{require_twice};
}

sub use_ajaxzip {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{use_ajaxzip};
}

sub ajaxzip_prefecture_parts_id {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{ajaxzip_prefecture_parts_id};
}

sub ajaxzip_city_parts_id {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{ajaxzip_city_parts_id};
}

sub ajaxzip_area_parts_id {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{ajaxzip_area_parts_id};
}

sub ajaxzip_street_parts_id {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{ajaxzip_street_parts_id};
}

sub send_attached_files {
    my $self = shift;
    my $property = $self->_get_property;
    return $property->{send_attached_files};
}

sub send_attached_files_to_customer {
    my $self = shift;
    my $property = $self->_get_property;
    return $property->{send_attached_files_to_customer};
}

sub disable_dates {
    my $self = shift;
    my $property = $self->_get_property;
    my %disable_dates;
    return \%disable_dates unless $property->{disable_dates};
    my @dates = split("\n", $property->{disable_dates});
    foreach my $date (@dates) {
        my ($ymd, $title) = split(",", $date);
        $ymd =~ s/\D//g;
        $disable_dates{$ymd}->{'title'} = $title;
    }
    return \%disable_dates;
}

sub only_ascii {
    my $self = shift;
    my $property = $self->_get_property;
    return $property->{only_ascii};
}

sub allow_ascii_chars {
    my $self = shift;
    my $property = $self->_get_property;
    return $property->{allow_ascii_chars};
}

sub use_linked {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{use_linked};
}

sub default_text {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{default_text};
}

sub options_horizontally {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{options_horizontally};
}

sub relations {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{relations};
}

sub require_hyphen {
    my $self = shift;

    my $property = $self->_get_property;
    return $property->{require_hyphen};
}

sub abs_range_from {
    my $self = shift;
    my $property = $self->_get_property;
    return $property->{abs_range_from};
}

sub next_text {
    my $self = shift;
    my $property = $self->_get_property;
    return $property->{next_text};
}

1;
