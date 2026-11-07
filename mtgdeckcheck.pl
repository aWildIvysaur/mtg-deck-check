#!/usr/bin/perl

use LWP::UserAgent();
use JSON::PP qw(decode_json encode_json);

#hash of all MTG formats
my %magic_formats = map { $_ => 1 } qw(
  standard future historic timeless gladiator pioneer explorer modern legacy
  pauper vintage penny commander oathbreaker standardbrawl brawl alchemy
  paupercommander duel oldschool premodern predh
);
my $format = 'none';

#Loads deck from "deck.txt"
#Mainboard and Sideboard must be headed and in that order
#If no mtg format is at the top of the list, the user will be asked
sub LoadFromTXT {
    open( DATA, "<deck.txt" ) or die "Couldn't open file deck.txt, $!";

    my $mainboardFound = 0;
    my $sideboardFound = 0;
    while (<DATA>) {    #go through the data line by line
        if ( $mainboardFound == 0 ) {    #find the start of the mainboard
            if ( lc $_ == 'mainboard' ) {
                $mainboardFound = 1;

                #Find format or ask
                my $line = lc $_;
                $line =~ s/^\s+|\s+$//g;
                if ( $magic_formats{$line} ) {
                    $format = $line;
                }
                else {    #ask user for format
                    while ( $format eq 'none' ) {
                        print("\nWhat format is this list for?\n");
                        my $input = <STDIN>;
                        $input =~ s/^\s+|\s+$//g;
                        if ( $magic_formats{$input} ) {
                            $format = $input;
                        }
                        else {
                            print("Sorry, that isnt a recognised format");
                        }
                    }
                }
            }
        }
        elsif ($sideboardFound) {    #populate sideboard
            my $cardname   = $_;
            my $cardamount = $_;
            $cardname   =~ s/[0-9]//g;
            $cardname   =~ s/\n//g;
            $cardamount =~ s/[^0-9]//g;
            $sideboard{$cardname} = $cardamount;
        }
        elsif ($mainboardFound) {    #populate mainboard or move onto sideboard
            if ( lc $_ != 'sideboard' ) {
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

#Count how many cards in mainboard/ sideboard/ both
sub CardCount {    #1=>Mainboard 2=>Sideboard 3=>All
    my $count = 0;
    if ( $_[0] == "1" ) {    #counting mainboard
        foreach $cardamount ( values %mainboard ) {
            $count += $cardamount;
        }
        return $count;
    }
    elsif ( $_[0] == "2" ) {    #counting sideboard
        foreach $cardamount ( values %sideboard ) {
            $count += $cardamount;
        }
        return $count;
    }
    elsif ( $_[0] == "3" ) {    #counting all
        foreach $cardamount ( values %mainboard ) {
            $count += $cardamount;
        }
        foreach $cardamount ( values %sideboard ) {
            $count += $cardamount;
        }
        return $count;
    }

}

#Build a JSON used to ask scryfall API for card details from list of card names
sub BuildCollectionJSON {
    my ($names) = @_;
    my @identifiers = map { { name => $_ } } @$names;

    return encode_json( { identifiers => \@identifiers } );
}

#Check if each card in deck is legal in the format/ exists
sub CheckLegalCards {
    my $legal = 1;

    my $ua = LWP::UserAgent->new( timeout => 10 );
    $ua->env_proxy;

    my @cards   = ( keys %mainboard, keys %sideboard ); #array of all card names
    my $payload = BuildCollectionJSON( \@cards );

    my $response = $ua->post(    #construct post request as per specification
        "https://api.scryfall.com/cards/collection",
        'Content-Type' => 'application/json',
        'User-Agent'   => 'IvyDeckCheck/0.3',
        'Accept'       => 'application/json;q=0.9,*/*;q=0.8',
        Content        => $payload
    );

    if ( $response->is_success ) {
        my $data = decode_json( $response->decoded_content );
        if ( exists $data->{not_found}
            && @{ $data->{not_found} }
          )    #if "not found" array exists and is not empty
        {
            foreach my $missing ( @{ $data->{not_found} } ) {
                my $name = $missing->{name};
                print("Not found: $name\n");
            }
            $legal = 0;
            return $legal;
        }
        @illegalcards = ();    #check all cards are legal in format
        foreach my $card ( @{ $data->{data} } )
        {                      #foreach card in the returned json
            if ( ( $card->{legalities}{$format} ) ne 'legal' ) {    #if illegal
                push( @illegalcards, $card->{name} );
                $legal = 0;
            }
        }
        if (@illegalcards) {    #if any illegal cards
            print("These cards are not legal: \n");
            foreach my $card (@illegalcards) {
                print("$card\n");
            }
        }

    }
    else {    #if scryfall rejected the request
        print( $response->status_line );
        $legal = 0;
        return $legal;
    }
    return $legal;
}

LoadFromTXT();
if ( CheckLegalCards() == 1 ) {
    print("All cards are legal\n");
}

