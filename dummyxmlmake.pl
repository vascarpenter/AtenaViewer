#!/usr/bin/perl
# CSV library is difficult to use

use utf8;
my $encoding = 'UTF-8';
my $file = shift;
open my $fh, "<", $file;

# skip 1 line
$_=<$fh>;

print qq(<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE ContactXML SYSTEM "ContactXML_01_01_20020615.dtd">\
<ContactXML xmlns="http://www.xmlns.org/2002/ContactXML" creator="http://www.agenda.co.jp/atena-shokunin/mac/2.0" version="1.1">);

while ($line=<$fh>) {
    @arr = split(/,/,$line);
        print qq(<ContactXMLItem><PersonName><PersonNameItem xml:lang="ja-JP">);
    printf ("<FullName pronunciation=\"%s %s\">%s %s</FullName>\n", $arr[2], $arr[3], $arr[0], $arr[1]);
    printf ("<FirstName pronunciation=\"%s\">%s</FirstName>\n", $arr[3], $arr[1]);
    printf ("<LastName pronunciation=\"%s\">%s</LastName>\n", $arr[2], $arr[0]);
print qq(</PersonNameItem>
</PersonName>
<Address>
<AddressItem locationType="Home" preference="True" xml:lang="ja-JP">
<AddressCode codeDomain="ZIP7">);
    printf("%s</AddressCode>\n<FullAddress>%s</FullAddress>",$arr[4],$arr[5]);
print qq(</AddressItem>
<AddressItem locationType="Office" xml:lang="ja-JP">
<AddressCode codeDomain="ZIP7"></AddressCode>
<FullAddress></FullAddress>
</AddressItem>
<AddressItem locationType="Others" xml:lang="ja-JP">
<AddressCode codeDomain="ZIP7"></AddressCode>
<FullAddress></FullAddress>
</AddressItem>
</Address>
<Phone></Phone>
<Extension></Extension>
</ContactXMLItem>
);

}

close($fh);

