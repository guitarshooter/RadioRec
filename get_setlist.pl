use LWP::UserAgent;
use Jcode;

#my $url = "http://www.media-click.net/PC/FM/BAY-FM/site/OnAirList.asp?SEARCH=01";
my $url = "http://yahoo.co.jp";
my $ua = LWP::UserAgent->new(
			agent =>'Mozilla/4.0 (compatible; MSIE 6.0)',
			timeout =>15,
			max_size =>128 * 1024,
			);
#my $response = $ua->get( $url );
my $req = HTTP::Request->new(GET => 'http://www.ksknet.net');
my $response = $ua->request($req);
print $response;
if ( !$response->is_success ){
	my $eucContent;
}
else{
print $response->status_line . "\n";
};
eval {
	$eucContent = jcode( $response->content )->h2z->euc;
};
if ( $@ ){
$eucContent =~ s/\x0D\x0A|\x0D|\x0A/\n/g;
print $eucContent;
};
