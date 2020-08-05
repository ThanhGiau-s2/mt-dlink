# Movable Type (r) (C) 2001-2020 Six Apart Ltd. All Rights Reserved.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id$

package Trackback;

use strict;
use warnings;
use Trackback::Entry;

sub init {
    no warnings 'redefine';
    *MT::ping             = \&_mt__ping;
    *MT::ping_and_save    = \&_mt__ping_and_save;
    *MT::needs_ping       = \&_mt__needs_ping;
    *MT::update_ping_list = \&_mt__update_ping_list;

    Trackback::Entry::init();
}

sub _mt__ping {
    my $mt    = shift;
    my %param = @_;
    my $blog;
    require MT::Entry;
    require MT::Util;
    unless ( $blog = $param{Blog} ) {
        my $blog_id = $param{BlogID};
        $blog = MT::Blog->load($blog_id)
            or return $mt->trans_error( "Loading of blog '[_1]' failed: [_2]",
            $blog_id, MT::Blog->errstr );
    }

    my (@res);

    my $send_updates = 1;
    if ( exists $param{OldStatus} ) {
        ## If this is a new entry (!$old_status) OR the status was previously
        ## set to draft, and is now set to publish, send the update pings.
        my $old_status = $param{OldStatus};
        if ( $old_status && $old_status eq MT::Entry::RELEASE() ) {
            $send_updates = 0;
        }
    }

    if ( $send_updates && !( MT->config->DisableNotificationPings ) ) {
        ## Send update pings.
        my @updates = $mt->update_ping_list($blog);
        for my $url (@updates) {
            require MT::XMLRPC;
            if (MT::XMLRPC->ping_update( 'weblogUpdates.ping', $blog, $url ) )
            {
                push @res, { good => 1, url => $url, type => "update" };
            }
            else {
                my $err = MT::XMLRPC->errstr;
                $err = Encode::decode_utf8($err)
                    if ( $err && !Encode::is_utf8($err) );
                push @res,
                    {
                    good  => 0,
                    url   => $url,
                    type  => "update",
                    error => $err,
                    };
            }
        }
        if ( $blog->mt_update_key ) {
            require MT::XMLRPC;
            if ( MT::XMLRPC->mt_ping($blog) ) {
                push @res,
                    {
                    good => 1,
                    url  => $mt->{cfg}->MTPingURL,
                    type => "update"
                    };
            }
            else {
                my $err = MT::XMLRPC->errstr;
                $err = Encode::decode_utf8($err)
                    if ( $err && !Encode::is_utf8($err) );
                push @res,
                    {
                    good  => 0,
                    url   => $mt->{cfg}->MTPingURL,
                    type  => "update",
                    error => $err,
                    };
            }
        }
    }

    my $cfg     = $mt->{cfg};
    my $send_tb = $cfg->OutboundTrackbackLimit;
    return \@res if $send_tb eq 'off';

    my @tb_domains;
    if ( $send_tb eq 'selected' ) {
        @tb_domains = $cfg->OutboundTrackbackDomains;
    }
    elsif ( $send_tb eq 'local' ) {
        my $iter = MT::Blog->load_iter();
        while ( my $b = $iter->() ) {
            next if $b->id == $blog->id;
            push @tb_domains, MT::Util::extract_domains( $b->site_url );
        }
    }
    my $tb_domains = join '|', map { lc quotemeta $_ } @tb_domains;
    $tb_domains = qr/(?:^|\.)$tb_domains$/ if $tb_domains;

    ## Send TrackBack pings.
    if ( my $entry = $param{Entry} ) {
        my $pings = $entry->to_ping_url_list;

        my %pinged = map { $_ => 1 } @{ $entry->pinged_url_list };
        my $cats = $entry->categories;
        for my $cat (@$cats) {
            push @$pings, grep !$pinged{$_}, @{ $cat->ping_url_list };
        }

        my $ua = MT->new_ua;

        # Get the hostname of MT in HTTPS.
        my $base = MT->config->CGIPath;
        $base =~ s/^http:/https:/;

        ## Build query string to be sent on each ping.
        my @qs;
        push @qs, 'title=' . MT::Util::encode_url( $entry->title );
        push @qs, 'url=' . MT::Util::encode_url( $entry->permalink );
        push @qs, 'excerpt=' . MT::Util::encode_url( $entry->get_excerpt );
        push @qs, 'blog_name=' . MT::Util::encode_url( $blog->name );
        my $qs = join '&', @qs;

        ## Character encoding--best guess.
        my $enc = $mt->{cfg}->PublishCharset;

        for my $url (@$pings) {
            $url =~ s/^\s*//;
            $url =~ s/\s*$//;
            my $url_domain;
            ($url_domain) = MT::Util::extract_domains($url);
            next if $tb_domains && ( lc($url_domain) !~ $tb_domains );

            # Do not verify SSL certificate
            # when sending a trackback ping to self.
            my %ssl_opts;
            my $changed_ssl_opts;
            if ( $base && $url =~ m/^$base/ ) {
                $ssl_opts{verify_hostname} = $ua->ssl_opts('verify_hostname');
                $ua->ssl_opts( verify_hostname => 0 );
                $changed_ssl_opts = 1;
            }

            my $req = HTTP::Request->new( POST => $url );
            $req->content_type(
                "application/x-www-form-urlencoded; charset=$enc");
            $req->content($qs);
            my $res = $ua->request($req);

            # Restore ssl_opts.
            if ($changed_ssl_opts) {
                $ua->ssl_opts(
                    'verify_hostname' => $ssl_opts{verify_hostname} );
            }

            if ( substr( $res->code, 0, 1 ) eq '2' ) {
                my $c = $res->content;
                $c = Encode::decode_utf8($c) if !Encode::is_utf8($c);
                my ( $error, $msg )
                    = $c =~ m!<error>(\d+).*<message>(.+?)</message>!s;
                if ($error) {
                    push @res,
                        {
                        good  => 0,
                        url   => $url,
                        type  => 'trackback',
                        error => $msg,
                        };
                }
                else {
                    push @res,
                        { good => 1, url => $url, type => 'trackback' };
                }
            }
            else {
                push @res,
                    {
                    good  => 0,
                    url   => $url,
                    type  => 'trackback',
                    error => "HTTP error: " . $res->status_line
                    };
            }
        }
    }
    \@res;
}

sub _mt__ping_and_save {
    my $mt    = shift;
    my %param = @_;
    if ( my $entry = $param{Entry} ) {
        my $results = MT::ping( $mt, @_ ) or return;
        my %still_ping;
        my $pinged = $entry->pinged_url_list;
        for my $res (@$results) {
            next if $res->{type} ne 'trackback';
            if ( !$res->{good} ) {
                $still_ping{ $res->{url} } = 1;
            }
            push @$pinged,
                $res->{url}
                . (
                $res->{good}
                ? ''
                : ' ' . $res->{error}
                );
        }
        $entry->pinged_urls( join "\n", @$pinged );
        $entry->to_ping_urls( join "\n", keys %still_ping );
        $entry->save or return $mt->error( $entry->errstr );
        return $results;
    }
    1;
}

sub _mt__needs_ping {
    my $mt    = shift;
    my %param = @_;
    my $blog  = $param{Blog};
    my $entry = $param{Entry};
    require MT::Entry;
    return unless $entry->status == MT::Entry::RELEASE();
    my $old_status = $param{OldStatus};
    my %list;
    ## If this is a new entry (!$old_status) OR the status was previously
    ## set to draft, and is now set to publish, send the update pings.
    if ( ( !$old_status || $old_status ne MT::Entry::RELEASE() )
        && !( MT->config->DisableNotificationPings ) )
    {
        my @updates = $mt->update_ping_list($blog);
        @list{@updates} = (1) x @updates;
        $list{ $mt->{cfg}->MTPingURL } = 1 if $blog && $blog->mt_update_key;
    }
    if ($entry) {
        @list{ @{ $entry->to_ping_url_list } } = ();
        my %pinged = map { $_ => 1 } @{ $entry->pinged_url_list };
        my $cats = $entry->categories;
        for my $cat (@$cats) {
            @list{ grep !$pinged{$_}, @{ $cat->ping_url_list } } = ();
        }
    }
    my @list = keys %list;
    return unless @list;
    \@list;
}

sub _mt__update_ping_list {
    my $mt = shift;
    my ($blog) = @_;

    my @updates;
    if ( my $pings = MT->registry('ping_servers') ) {
        my $up = $blog->update_pings;
        if ($up) {
            foreach ( split ',', $up ) {
                next unless exists $pings->{$_};
                push @updates, $pings->{$_}->{url};
            }
        }
    }
    if ( my $others = $blog->ping_others ) {
        push @updates, split /\r?\n/, $others;
    }
    my %updates;
    for my $url (@updates) {
        for ($url) {
            s/^\s*//;
            s/\s*$//;
        }
        next unless $url =~ /\S/;
        $updates{$url}++;
    }
    keys %updates;
}

sub listing_screens_ping_feed_link {
    my ($app) = @_;
    return 1 if $app->user->is_superuser;

    if ( $app->blog ) {
        return 1
            if $app->user->can_do( 'get_trackback_feed', at_least_one => 1 );
    }
    else {
        my $iter = MT->model('permission')->load_iter(
            {   author_id => $app->user->id,
                blog_id   => { not => 0 },
            }
        );
        my $cond;
        while ( my $p = $iter->() ) {
            $cond = 1, last
                if $p->can_do('get_trackback_feed');
        }
        return $cond ? 1 : 0;
    }
    0;
}

sub list_props_page {
    return +{ ping_count => { base => 'entry.ping_count', order => 900, }, };
}

sub list_props_entry {
    return +{
        ping_count => {
            auto         => 1,
            display      => 'optional',
            label        => 'Trackbacks',
            filter_label => '__PING_COUNT',
            order        => 900,
            html_link    => sub {
                my $prop = shift;
                my ( $obj, $app, $opts ) = @_;
                return unless $app->can_do('access_to_trackback_list');
                return $app->uri(
                    mode => 'list',
                    args => {
                        _type      => 'ping',
                        filter     => 'entry_id',
                        filter_val => $obj->id,
                        blog_id    => $opts->{blog_id} || 0,
                    },
                );
            },
        },
    };
}

sub list_props_ping {
    return {
        excerpt => {
            label     => 'Trackback Text',
            auto      => 1,
            display   => 'force',
            order     => 100,
            use_blank => 1,
            html      => sub {
                my ( $prop, $obj, $app ) = @_;
                my $text = MT::Util::remove_html( $obj->excerpt );
                ## FIXME: Hard coded...
                my $len = 30;
                if ( $len < length($text) ) {
                    $text = substr( $text, 0, $len );
                    $text .= '...';
                }
                elsif ( !$text ) {
                    $text = '...';
                }

                my $id        = $obj->id;
                my $edit_link = $app->uri(
                    mode => 'view',
                    args => {
                        _type   => 'ping',
                        id      => $id,
                        blog_id => $obj->blog_id,
                    }
                );
                my $status
                    = $obj->is_junk      ? 'Junk'
                    : $obj->is_published ? 'Published'
                    :                      'Moderated';
                my $lc_status = lc $status;

                my $status_icon_color_class
                    = $obj->is_junk      ? ' mt-icon--warning'
                    : $obj->is_published ? ' mt-icon--success'
                    :                      '';
                my $status_icon_id
                    = $obj->is_junk      ? 'ic_error'
                    : $obj->is_published ? 'ic_checkbox'
                    :                      'ic_statusdraft';

                my $static_uri = MT->static_path;
                my $status_img = qq{
                    <svg title="$status" role="img" class="mt-icon mt-icon--sm$status_icon_color_class">
                        <use xlink:href="${static_uri}images/sprite.svg#$status_icon_id">
                    </svg>
                };

                my $blog_name
                    = MT::Util::encode_html( $obj->blog_name || '' );
                my $title = MT::Util::encode_html( $obj->title      || '' );
                my $url   = MT::Util::encode_html( $obj->source_url || '' );
                my $view_img = qq{
                    <svg title="View" role="img" class="mt-icon mt-icon--sm">
                        <use xlink:href="${static_uri}images/sprite.svg#ic_permalink">
                    </svg>
                };
                my $ping_from
                    = MT->translate(
                    '<a href="[_1]">Ping from: [_2] - [_3]</a>',
                    $edit_link, $blog_name, $title );

                return qq{
                    <span class="icon status $lc_status">
                        $status_img
                    </span>
                    <span class="ping-from">$ping_from</span>
                    <span class="view-link">
                      <a href="$url" class="d-inline-block" target="_blank">
                        $view_img
                      </a>
                    </span>
                    <p class="ping-excerpt description">$text</p>
                };
            },
        },
        ip => {
            label     => 'IP Address',
            auto      => 1,
            order     => 200,
            condition => sub { MT->config->ShowIPInformation },
        },
        blog_name => {
            base    => '__common.blog_name',
            display => 'default',
            order   => 300,
        },
        target => {
            label       => 'Target',
            display     => 'default',
            order       => 400,
            view_filter => 'none',
            base        => '__virtual.string',
            bulk_html   => sub {
                my ( $prop, $objs, $app ) = @_;
                my %tbs = map { $_->tb_id => 1 } @$objs;
                my @tbs
                    = MT->model('trackback')->load( { id => [ keys %tbs ] } );
                my %tb_map = map { $_->id => $_ } @tbs;
                my %entries
                    = map { $_->entry_id => 1 } grep { $_->entry_id } @tbs;
                my @entries;
                if ( my @entry_ids = keys %entries ) {
                    @entries
                        = MT->model('entry')->load( { id => \@entry_ids } );
                }
                my %entry_map  = map { $_->id          => $_ } @entries;
                my %categories = map { $_->category_id => 1 }
                    grep { $_->category_id } @tbs;
                my @categories;
                if ( my @category_ids = keys %categories ) {
                    @categories = MT->model('category')
                        ->load( { id => \@category_ids } );
                }
                my %category_map = map { $_->id => $_ } @categories;
                my ( $title_col, $alt_label );
                require MT::Promise;
                my $user = $app->user;
                my @res;

                for my $obj (@$objs) {
                    my $tb = $tb_map{ $obj->tb_id };
                    my $obj;
                    if ( $tb->entry_id ) {
                        $obj       = $entry_map{ $tb->entry_id };
                        $title_col = 'title';
                        $alt_label = 'No title';
                    }
                    elsif ( $tb->category_id ) {
                        $obj       = $category_map{ $tb->category_id };
                        $title_col = 'label';
                        $alt_label = 'No label';
                    }
                    my $title_html;
                    my $type = $obj->class_type;
                    my $obj_promise
                        = MT::Promise::delay( sub { return $obj; } );
                    if ($user->is_superuser
                        or $app->run_callbacks(
                            'cms_view_permission_filter.' . $type,
                            $app, $obj->id, $obj_promise
                        )
                        )
                    {
                        $title_html
                            = MT::ListProperty::make_common_label_html( $obj,
                            $app, $title_col, $alt_label );
                    }
                    else {
                        $title_html = $obj->$title_col || $alt_label;
                    }
                    $type = 'categories' if $type eq 'category';

                    my $icon_title = $type;
                    my $icon_color = '';
                    if ( $type eq 'entry' ) {
                        $icon_color = '--success';
                    }
                    elsif ( $type eq 'page' ) {
                        $icon_color = '--info';
                    }
                    my $icon_type = '';
                    if ( $type eq 'entry' || $type eq 'page' ) {
                        $icon_type = 'file';
                    }
                    elsif ( $type eq 'categories' ) {
                        $icon_type = 'category';
                    }
                    my $static_uri = $app->static_path;
                    push @res, qq{
                        <svg title="$icon_title" role="img" class="mt-icon--sm mt-icon$icon_color">
                          <use xlink:href="${static_uri}images/sprite.svg#ic_$icon_type">
                        </svg>
                        $title_html
                    };
                }
                @res;
            },
            sort => sub {
                my $prop = shift;
                my ( $terms, $args ) = @_;
                $args->{joins} ||= [];
                push @{ $args->{joins} }, MT->model('trackback')->join_on(
                    undef, undef,
                    {   condition => { id => \'= tbping_tb_id' },
                        type      => 'Left',
                    },

                    ),
                    MT->model('entry')->join_on(
                    undef, undef,
                    {   sort      => 'title',
                        condition => { id => \'= trackback_entry_id', },
                        direction => ( $args->{direction} || 'ascend' ),
                        type      => 'left',
                    },
                    ),
                    MT->model('category')->join_on(
                    undef, undef,
                    {   sort      => 'label',
                        condition => { id => \'= trackback_category_id', },
                        direction => ( $args->{direction} || 'ascend' ),
                        type      => 'left',
                    },
                    );

                $args->{sort} = [];
                return;
            },
        },
        created_on => {
            base    => '__virtual.created_on',
            display => 'default',
            order   => 500,
        },
        modified_on => {
            auto    => 1,
            label   => 'Date Modified',
            display => 'none'
        },
        from => {
            label       => 'From',
            view_filter => [],
            sort        => sub {
                my $prop = shift;
                my ( $terms, $args ) = @_;
                my $dir = $args->{direction} eq 'descend' ? 'DESC' : 'ASC';
                $args->{sort} = [
                    { column => 'blog_name', desc => $dir },
                    { column => 'title',     desc => $dir },
                ];
            },
        },
        author_name      => { condition => sub {0}, },
        source_blog_name => {
            label     => 'Source Site',
            col       => 'blog_name',
            display   => 'none',
            base      => '__virtual.string',
            use_blank => 1,
        },
        source_url => {
            auto      => 1,
            label     => 'URL',
            display   => 'none',
            use_blank => 1,
        },
        status => {
            label   => 'Status',
            base    => '__virtual.single_select',
            col     => 'visible',
            display => 'none',
            terms   => sub {
                my $prop  = shift;
                my $value = $prop->normalized_value(@_);
                require MT::TBPing;
                return $value eq 'approved'
                    ? { visible => 1, junk_status => MT::TBPing::NOT_JUNK() }
                    : $value eq 'pending'
                    ? { visible => 0, junk_status => MT::TBPing::NOT_JUNK() }
                    : $value eq 'junk' ? { junk_status => MT::TBPing::JUNK() }
                    :   { junk_status => MT::TBPing::NOT_JUNK() };
            },
            single_select_options => [
                {   label => MT->translate('Approved'),
                    text  => 'Approved',
                    value => 'approved',
                },
                {   label => MT->translate('Unapproved'),
                    text  => 'Pending',
                    value => 'pending',
                },
                { label => MT->translate('Not spam'), value => 'not_junk', },
                {   label => MT->translate('Reported as spam'),
                    text  => 'Spam',
                    value => 'junk',
                },
            ],
        },
        title => {
            label     => 'Source Title',
            auto      => 1,
            display   => 'none',
            use_blank => 1,
        },
        entry_id => {
            base            => '__virtual.integer',
            label           => 'Entry/Page',
            display         => 'none',
            filter_editable => 0,
            terms           => sub {
                my $prop = shift;
                my ( $args, $db_terms, $db_args ) = @_;
                my $entry_id = $args->{value};
                $db_args->{joins} ||= [];
                push @{ $db_args->{joins} },
                    MT->model('trackback')->join_on(
                    undef,
                    {   entry_id => $entry_id,
                        id       => \'= tbping_tb_id',
                    },
                    );
            },
            label_via_param => sub {
                my ( $prop, $app, $val ) = @_;
                my $entry = MT->model('entry')->load($val)
                    or return $prop->error(
                    MT->translate(
                        '[_1] ( id:[_2] ) does not exists.',
                        MT->translate("Entry"),
                        defined $val ? $val : ''
                    )
                    );
                my $type = $entry->class_label || '';
                return MT->translate( 'Trackbacks on [_1]: [_2]',
                    $type, $entry->title, );
            },
        },
        category_id => {
            base            => '__virtual.integer',
            display         => 'none',
            filter_editable => 0,
            label           => 'Category',
            terms           => sub {
                my $prop = shift;
                my ( $args, $db_terms, $db_args ) = @_;
                my $cat_id = $args->{value};
                $db_args->{joins} ||= [];
                push @{ $db_args->{joins} },
                    MT->model('trackback')->join_on(
                    undef,
                    {   category_id => $cat_id,
                        id          => \'= tbping_tb_id',
                    },
                    );
            },
            label_via_param => sub {
                my ( $prop, $app, $val ) = @_;
                my $cat = MT->model('category')->load($val)
                    or return $prop->error(
                    MT->translate(
                        '[_1] ( id:[_2] ) does not exists.',
                        MT->translate("Category"),
                        defined $val ? $val : ''
                    )
                    );
                my $type
                    = $cat->class eq 'category' ? 'Category'
                    : $cat->class eq 'folder'   ? 'Folder'
                    :                             '';
                return MT->translate( 'Trackbacks on [_1]: [_2]',
                    $type, $cat->label, );
            },
        },
        for_current_user => {
            base      => '__virtual.hidden',
            label     => 'Trackbacks on My Entries/Pages',
            singleton => 1,
            terms     => sub {
                my ( $prop, $args, $db_terms, $db_args ) = @_;
                my $user = MT->app->user;
                $db_args->{joins} ||= [];
                push @{ $db_args->{joins} },
                    MT->model('trackback')->join_on(
                    undef,
                    {   id       => \"= tbping_tb_id",
                        entry_id => \"= entry_id",
                    },
                    {   join => MT->model('entry')
                            ->join_on( undef, { author_id => $user->id, } ),
                    },
                    );
            },
        },
        id => {
            base    => '__virtual.id',
            display => 'none',
        },
        content => {
            base    => '__virtual.content',
            fields  => [qw(title excerpt source_url ip blog_name)],
            display => 'none',
        },
        blog_id => {
            auto            => 1,
            col             => 'blog_id',
            display         => 'none',
            filter_editable => 0,
        },
    };
}

sub system_filters_ping {
    return {
        not_spam => {
            label => 'Non-spam trackbacks',
            items =>
                [ { type => 'status', args => { value => 'not_junk' }, }, ],
            order => 100,
        },
        not_spam_in_this_website => {
            label => 'Non-spam trackbacks on this website',
            view  => 'website',
            items => [
                { type => 'current_context' },
                { type => 'status', args => { value => 'not_junk' }, },
            ],
            order => 200,
        },
        pending => {
            label => 'Pending trackbacks',
            items =>
                [ { type => 'status', args => { value => 'pending' }, }, ],
            order => 300,
        },
        published => {
            label => 'Published trackbacks',
            items =>
                [ { type => 'status', args => { value => 'approved' }, }, ],
            order => 400,
        },
        on_my_entry => {
            label => 'Trackbacks on my entries/pages',
            items => sub {
                my $login_user = MT->app->user;
                [ { type => 'for_current_user' } ],;
            },
            order => 500,
        },
        in_last_7_days => {
            label => 'Trackbacks in the last 7 days',
            items => [
                { type => 'status', args => { value => 'not_junk' }, },
                {   type => 'created_on',
                    args => { option => 'days', days => 7 }
                }
            ],
            order => 600,
        },
        spam => {
            label => 'Spam trackbacks',
            items => [ { type => 'status', args => { value => 'junk' }, }, ],
            order => 700,
        },
        _trackbacks_by_entry => {
            label => sub {
                my $app   = MT->app;
                my $id    = $app->param('filter_val');
                my $entry = MT->model('entry')->load($id);
                return 'Trackbacks by entry: ' . $entry->title;
            },
            items => sub {
                my $app = MT->app;
                my $id  = $app->param('filter_val');
                return [
                    {   type => 'entry',
                        args => { option => 'equal', value => $id }
                    }
                ];
            },
        },
    };
}

1;
