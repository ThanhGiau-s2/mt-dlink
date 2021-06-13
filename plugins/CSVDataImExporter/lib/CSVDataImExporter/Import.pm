package CSVDataImExporter::Import;

use strict;
use warnings;

use MT::I18N qw( const );

sub do_excel_import_cd {
    my $app = shift;

    require MT::Blog;
    my $blog_id = $app->param('blog_id')
        or return $app->return_to_dashboard( redirect => 1 );

    my $blog = MT::Blog->load($blog_id)
        or return $app->error(
        $app->translate(
            "Loading site '[_1]' failed: [_2]", $blog_id,
            MT::Blog->errstr
        )
        );

    return $app->permission_denied()
        unless $app->user->permissions($blog_id)->can_do('import_blog');

    my $import_as_me = $app->param('import_as_me');

    ## Determine the user as whom we will import the entries.
    my $author    = $app->user;
    my $author_id = $author->id;

    $app->validate_magic() or return;

    $app->add_breadcrumb(
        $app->translate('Import CSV'),
#        $app->uri(
#            mode => 'import_contents_cd',
#            args => { blog_id => $blog_id },
#        ),
    );
    $app->add_breadcrumb( $app->translate('Import') );

    my $plugin = MT->component("CSVDataImExporter");
    my $content_type_id = $app->param('content_type_id');

    my ($fh) = $app->upload_info('file');
    my $stream = $fh ? $fh : $app->config('ImportPath');

    $app->{no_print_body} = 1;

    local $| = 1;
    $app->send_http_header('text/html');

    my $param;
    $param
        = { import_upload => ( $fh ? 1 : 0 ) };

    $app->print_encode(
        $app->build_page( 'import_excel_start.tmpl', $param ) );

    require MT::ContentData;
    require MT::Permission;

    my $import_type = $app->param('import_type') || '';
    require MT::Import;
    my $imp      = MT::Import->new;
    my $importer = $imp->importer($import_type);

    return $app->error(
        $app->translate( 'Importer type [_1] was not found.', $import_type ) )
        unless $importer;

    my %options;
    %options = map { $_ => scalar $app->param($_); } @{ $importer->{options} }
        if $importer->{options};
    my $import_result = $imp->import_contents(
        Key      => $import_type,
        Blog     => $blog,
        ContentTypeID => $content_type_id,
        same_id_process => $app->param('same_id_process'),
        no_id_process => $app->param('no_id_process'),
        null_id_process => $app->param('null_id_process'),
        Stream   => $stream,
        Callback => sub { $app->print_encode(@_) },
        (%options) ? (%options) : (),
    );

    $param->{import_success} = $import_result;
    $param->{error} = $importer->{type}->errstr unless $import_result;

    if ($import_result) {
        my $rebuild_url = $app->uri(
            mode => 'rebuild_confirm',
            args => { blog_id => $blog_id, }
        );
        $param->{rebuild_open}
            = qq!window.open('$rebuild_url', 'rebuild_blog_$blog_id', 'width=400,height=400,resizable=yes'); return false;!;
    }

    $app->print_encode(
        $app->build_page( "import_excel_end.tmpl", $param ) );

    close $fh if $fh;
    1;
}

1;
