#!/usr/bin/perl
#
# Webcluster-Client DB0LJ-6
#
# (C) Hans-J. Barthen, DL5DI
#     Franz-Josef-Str. 20
#     D-56642 Kruft
#
# 07.02.2008  1.Beta-Version
# 08.02.2008  1.active version at dx.db0lj.de
# 10.02.2008  URL generation for qrz.com added
# 19.02.2008  1st release for download on the web
# 24.02.2008  automatic creation of cnt-file
# 25.02.2008  convert special characters to html-codes
# 09.03.2008  show newest records first
# 07.01.2010  show date in WCY and WWV datas to recognize entries older than a day
# 30.06.2010  typo in timestamp of WWV/WCY brought up wrong month - fixed
# 04.01.2013  url of qrz.com-database changed
#
# 19.02.2014  EA1NK Juan J. Lamas - modified script to form a valid XML document.
# 20.02.2014  EA1NK Juan J. Lamas - Url generation for HamQTH instead of QRZ.com.
# 21.02.2014  EA1NK Juan J. Lamas - New redesigned web interface using HTTP Request to retrieve XML content.
# 22.02.2014  EA1NK Juan J. Lamas - New CSS styles Cherry, Lemon, Mint and Sea.	
#

$| = 1;		# flush print and write
$rev = "20140219";
use HTML::Entities;    # Add HTML::Entities for escaping
# clear content of variables
$spot[1] = ""; $spot[2] = ""; $spot[3] = ""; $spot[4] = "";
$spot[5] = ""; $spot[6] = ""; $spot[7] = ""; $spot[8] = "";
$spot[9] = ""; $spot[10] = ""; $spot[11] = ""; $spot[12] = "";
$spot[13] = ""; $spot[14] = ""; $spot[15] = ""; $spot[16] = "";
$spot[17] = ""; $spot[18] = ""; $spot[19] = ""; $spot[20] = "";
$ann[1] = ""; $ann[2] = ""; $ann[3] = "";
$wcy[1] = ""; $wcy[2] = ""; $wcy[3] = "";
$wwv[1] = ""; $wwv[2] = ""; $wwv[3] = "";

# get actual date and time to create the dxspider directory and filenames
($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=gmtime(time);
$mon++;
$yday++;
$year+=1900;

# save a copy for the timestamp in the bottom of the page
$stamp=sprintf("%2.2d:%2.2d:%2.2d UTC",$hour,$min,$sec);

# create filenames
$spotfile=sprintf("/spider/data/spots/%4.4d/%3.3d.dat",$year,$yday);
$annfile=sprintf("/spider/data/log/%4.4d/%2.2d.dat",$year,$mon);
$wcyfile=sprintf("/spider/data/wcy/%4.4d/%2.2d.dat",$year,$mon);
$wwvfile=sprintf("/spider/data/wwv/%4.4d/%2.2d.dat",$year,$mon);
$dxccfile=sprintf("/spider/data/dxcc.list");

# read and increase hit counter
if (open(CNTFILE, "/var/local/httpd/cgi-bin/webclusterXML.cnt")) {
    $cnt = <CNTFILE>;
    close(CNTFILE);
    chop($cnt);
    $cnt++;
} else {
    $cnt = 1;
}    

# write counter back to file
if (open(CNTFILE, ">/var/local/httpd/cgi-bin/webclusterXML.cnt")) {
    printf(CNTFILE "$cnt\n");
    close(CNTFILE);
}

##################### Number of spots, min, max, default ##############

    if ($ARGV[0] > 0) { # min
	$n = $ARGV[0];
	if($n > 50) {
	    $n = 50;	# max
	}
    } else {
	$n = 20;	# default
    }

###################### XML-Header ########################

    print("<?xml version='1.0' encoding='UTF-8'?>");
    print("<DATA>");


######################################################################
#
# Create dynamic tables / be careful with changes here!
#
######################################################################


#################### DX-Spots ##########################

if(open(SPOTS, $spotfile)) {
    while($line = <SPOTS>) {
        chomp($line);  # Use chomp instead of chop
        for($i = $n; $i > 1; $i--) {
            $spot[$i] = $spot[$i-1];
        }
        $spot[1] = $line;
    }

    $i = 1;

    # Table start
    print("<SPOTS>");

    while($i <= $n) {
        ($qrg,$call,$zeit,$text,$spotter,$dxcc,$dummy,$dummy,$itu,$cq,$dummy) = split(/\^/,$spot[$i],11);

        # Use HTML::Entities to encode special characters
        $text = encode_entities($text);
        $spotter = encode_entities($spotter);
        $call = encode_entities($call);

        $dbi = 1;
        if(open(DXCC, $dxccfile)) {
            while($dbi < $dxcc) {
                $dbline = <DXCC>;
                $dbi++;
            }
            $pfx = <DXCC>;
            chomp($pfx);  # Remove newline
            close(DXCC);
        }

        if((length($spotter) > 0)) {
            print("<SPOT>");
            printf("<FROM>DX de %s:</FROM>", $spotter);
            printf("<QRG>%10.1f</QRG>", $qrg);
            if(index($call,'/') > 0){
                ($teil1,$teil2) = split(/\//,$call,2);
                if(length($teil2) < length($teil1)) {
                    $qrzcall = $teil1;
                } else {
                    ($qrzcall,$dummy) = split(/\//,$teil2,2);
                }
            } else {
                $qrzcall = $call;
            }

            $tmp = $qrzcall;
            $num = $tmp =~ tr/0-9//;
            $tmp = $qrzcall;
            $abc = $tmp =~ tr/A-Za-z//;

            if((index($qrzcall,'/') > 0) || ($num == 0) || ($abc < 2)) {
                printf("<DX>%15.15s</DX>", $call);
            } else {
                printf("<DX>%15.15s</DX>", $call);
            }
            printf("<TEXT>%30.30s</TEXT>", $text);    
            printf("<PREFIX>%2.2s</PREFIX>", $pfx);
            printf("<CQ>%2.2s</CQ>", $cq);
            ($sec,$min,$std,$mtag,$jahr,$wtag,$jtag,$somzeit) = gmtime($zeit);
            printf("<UTC>%2.2d%2.2dZ</UTC>", $std, $min);
            print("</SPOT>");
        }
        $i++;
    }    
    
    close(SPOTS);

    # Table end
    print("</SPOTS>");
	}
	$i++;

    }    
    
    close(SPOTS);

# Table end

    print("</SPOTS>");
}

#################### WCY-Datas ##########################

if(open(WCYS, $wcyfile)) {


    while($line = <WCYS>) {
	chop($line);
	$wcy[3] = $wcy[2];
	$wcy[2] = $wcy[1];
	$wcy[1] = $line;
    }
    $i = 1;

# Table start

    print("<WCYS>");

    while($i <= 3) {

	($zeit,$sfi,$a,$k,$expk,$r,$sa,$gmf,$aurora,$spotter,$dummy) = split(/\^/,$wcy[$i],11);
	if($sa eq "qui") {
	    $sa = "quiet";
	} elsif ($sa eq "act") {
	    $sa = "active";
	}
	
	if($gmf eq "qui") {
	    $gmf = "quiet";
	} elsif ($gmf eq "act") {
	    $gmf = "active";
	}
	($sec,$min,$std,$mtag,$monat,$jahr,$wtag,$jtag,$somzeit) = gmtime($zeit);

	if((length($spotter) > 0)) {
	    print("<WCY>");
	    printf("<FROM>WCY de %s</FROM>",$spotter);
	    printf("<DATE>%4.4d/%2.2d/%2.2d %2.2d%2.2dZ</DATE>",$jahr+1900,$monat+1,$mtag,$std,$min);
	    printf("<SFI>SFI=%d</SFI>",$sfi);
	    printf("<A>A=%d</A>",$a);
	    printf("<K>K=%d</K>",$k);
	    printf("<expK>expK=%1d</expK>",$expk);
	    printf("<R>R=%d</R>",$r);
	    printf("<SA>SA: %s</SA>",$sa);
	    printf("<GMF>GMF: %s</GMF>",$gmf);
	    if($aurora eq "yes") {
		printf("<AURORA>Aurora: YES!</AURORA>");
	    } else {	    
	        printf("<AURORA>Aurora: %s</AURORA>",$aurora);
	    }
	    print("</WCY>");
	}
	$i++;
    }    
    
    close(WCYS);

# Table end

    print("</WCYS>");
}


#################### WWV-Datas ##########################

if(open(WWVS, $wwvfile)) {


    while($line = <WWVS>) {
	chop($line);
	$wwv[3] = $wwv[2];
	$wwv[2] = $wwv[1];
	$wwv[1] = $line;
    }
    $i = 1;

# Table start

    print("<WWVS>");

    while($i <= 3) {
#	print "$wwv[$i]\n";
	($spotter,$zeit,$sfi,$a,$k,$text,$dummy) = split(/\^/,$wwv[$i],7);
	($sec,$min,$std,$mtag,$monat,$jahr,$wtag,$jtag,$somzeit) = gmtime($zeit);

	if((length($spotter) > 0)) {
	    print("<WWV>");
	    printf("<FROM>WWV de %s</FROM>",$spotter);
	    printf("<DATE>%4.4d/%2.2d/%2.2d %2.2d%2.2dZ</DATE>",$jahr+1900,$monat+1,$mtag,$std,$min);
	    printf("<SFI>SFI=%d</SFI>",$sfi);
	    printf("<A>A=%d</A>",$a);
	    printf("<K>K=%d</K>",$k);
	    $text =~ tr/<>/ /;
	    printf("<TEXT>%s</TEXT>",$text);
	    print("</WWV>");
	}
	$i++;

    }    
    
    close(WWVS);

# Table end

    print("</WWVS>");
}


#################### Announcements ##########################

if(open(ANNS, $annfile)) {

# Table start

    print("<ANNS>");

    while($line = <ANNS>) {
	chop($line);
	($zeit,$flag,$dummy) = split(/\^/,$line,3);
	if($flag eq 'ann') {
	    $ann[3] = $ann[2];
	    $ann[2] = $ann[1];
	    $ann[1] = $line;
	}
    }
    $i = 1;
    while($i <= 3) {    
	($zeit,$flag,$dest,$spotter,$text,$dummy) = split(/\^/,$ann[$i],6);
	($sec,$min,$std,$mtag,$jahr,$wtag,$jtag,$somzeit) = gmtime($zeit);
	if((length($spotter) > 0)) {
	    print("<ANN>");
	    printf("<PATH>To %s de %s</PATH>",$dest,$spotter);
	    printf("<DATE>%2.2d%2.2dZ</DATE>",$std,$min);
	    printf("<TEXT>%s</TEXT>",$text);
	    print("</ANN>");
	}
	$i++;
    }
    
    close(ANNS);

# Table end

    print("</ANNS>");
}

print("</DATA>");


exit;
