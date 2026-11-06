use LWP::UserAgent();
use JSON::PP qw(decode_json);

my $ua = LWP::UserAgent->new(timeout => 10);
$ua->env_proxy;

my $input = "rit o fl a"; #rite of flame
$input =~ s/ /+/g;

my $response = $ua->get(
	"https://api.scryfall.com/cards/named?fuzzy=$input",
	'User-Agent' => 'mytestapp/1.0',
	'Accept' => 'application/json;q=0.9,*/*;q=0.8');

if ($response->is_success) {
	my $data = decode_json($response->decoded_content);
	
    print($data->{legalities}{pauper});

}
else {
    die $response->status_line;
}