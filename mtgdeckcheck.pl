#!/usr/bin/perl

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

LoadFromTXT();
print( "mainboard count = " . CardCount("1") . "\n" );
print( "sideboard count = " . CardCount("2") . "\n" );
print( "whole deck count = " . CardCount("3") . "\n" );

