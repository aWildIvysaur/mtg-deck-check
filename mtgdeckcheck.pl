#!/usr/bin/perl

use LWP::UserAgent();
use JSON::PP qw(decode_json encode_json);

sub LoadFromTXT {
    open( DATA, "<deck.txt" ) or die "Couldn't open file deck.txt, $!";

    my $mainboardFound = 0;
    my $sideboardFound = 0;
    while (<DATA>) {
        if ( $mainboardFound == 0 ) {
            if ( $_ == 'Mainboard' ) {
                $mainboardFound = 1;
            }
        }
        elsif ($sideboardFound) {
            my $cardname   = $_;
            my $cardamount = $_;
            $cardname   =~ s/[0-9]//g;
            $cardname   =~ s/\n//g;
            $cardamount =~ s/[^0-9]//g;
            $sideboard{$cardname} = $cardamount;
        }
        elsif ($mainboardFound) {
            if ( $_ != 'Sideboard' ) {
                my $cardname   = $_;
                my $cardamount = $_;
                $cardname   =~ s/[0-9]//g;
                $cardname   =~ s/\n//g;
                $cardamount =~ s/[^0-9]//g;
                $mainboard{$cardname} = $cardamount;
            }
            else {
                $sideboardFound = 1;
            }
        }

    }
}

sub CardCount {    #1=>Mainboard 2=>Sideboard 3=>All
    my $count = 0;
    if ( $_[0] == "1" ) {
        foreach $cardamount ( values %mainboard ) {
            $count += $cardamount;
        }
        return $count;
    }
    elsif ( $_[0] == "2" ) {
        foreach $cardamount ( values %sideboard ) {
            $count += $cardamount;
        }
        return $count;
    }
    elsif ( $_[0] == "3" ) {
        foreach $cardamount ( values %mainboard ) {
            $count += $cardamount;
        }
        foreach $cardamount ( values %sideboard ) {
            $count += $cardamount;
        }
        return $count;
    }

}

sub BuildCollectionJSON {
    my ($names) = @_;
    my @identifiers = map { { name => $_ } } @$names;

    return encode_json({ identifiers => \@identifiers });
}

sub CheckLegalCards {
    my $legal = 1;
    
    my $ua = LWP::UserAgent->new(timeout => 10);
    $ua->env_proxy;

    my @cards = keys %mainboard;
    my $payload = BuildCollectionJSON(\@cards);

    my $response = $ua->post(
        "https://api.scryfall.com/cards/collection",
        'Content-Type' => 'application/json',
        'User-Agent' => 'IvyDeckCheck/0.3',
        'Accept' => 'application/json;q=0.9,*/*;q=0.8',
        Content => $payload);

        if ($response->is_success) {
            my $data = decode_json($response->decoded_content);

            if (exists $data->{not_found} && @{$data->{not_found}}) #if "not found" array exists and is not empty
            {
                foreach my $missing (@{$data->{not_found}}) {
                    my $name = $missing->{name};
                    print("Not found: $name\n");
                }
                $legal = 0;
                return $legal;
            }

            foreach my $card (@{$data->{data}}) {
                if (($card->{legalities}{pauper}) ne 'legal') {
                    $legal = 0;
                    return $legal;
                }
            }

        }
        else {
            print($response->status_line);
            $legal = 0;
            return $legal;
        }
    return $legal
}

LoadFromTXT();
if (CheckLegalCards() == 1){
    print("All cards are legal\n")
}
print("done\n");
