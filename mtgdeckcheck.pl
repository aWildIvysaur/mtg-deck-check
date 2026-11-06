#!/usr/bin/perl

open( DATA, "<deck.txt" ) or die "Couldn't open file deck.txt, $!";

%mainboard;
%sideboard;

$mainboardFound = 0;
$sideboardFound = 0;
while (<DATA>) {
    if ( $mainboardFound == 0 ) {
        if ( $_ == 'Mainboard' ) {
            $mainboardFound = 1;
        }
    }
    elsif ($sideboardFound) {
        $cardname   = $_;
        $cardamount = $_;
        $cardname   =~ s/[0-9]//g;
        $cardname   =~ s/\n//g;
        $cardamount =~ s/[^0-9]//g;
        $sideboard{$cardname} = $cardamount;
    }
    elsif ($mainboardFound) {
        if ( $_ != 'Sideboard' ) {
            $cardname   = $_;
            $cardamount = $_;
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

print("DONE! \n");
print(%mainboard);
