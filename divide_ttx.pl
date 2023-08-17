my $file = $ARGV[0];

open FH1, ">$file.pre";
open FH2, ">$file.post";
open FH3, "<$file.ttx";

my $mode = 0;
my $post = 0;
while(<FH3>){
  if($_ eq "  </cmap>\n"){
    $mode = 1;
  }
  if($mode == 0){
    if($_ !~ m/      <map code=\"0x10[c-f][0-9a-f]{3}\" name=\"u10[C-F][0-9A-F]{3}\"\/><!-- Plane 16 Private Use -->\n/){
      print FH1 $_;
    }
  } else {
    if($_ !~ m/<\/?psNames>|<\/?extraNames>|<psName name=/){
      if($post == 0 && $_ =~ m/<post>/){
        $post++;
      } elsif($post == 1 && $_ =~ m/<formatType value=\"2.0\"\/>/) {
        $_ =~ s/<formatType value=\"2.0\"\/>/<formatType value=\"3.0\"\/>/;
        $post++;
      }
      $_ =~ s/<xAvgCharWidth value=\"[0-9]+\"\/>/<xAvgCharWidth value=\"512\"\/>/;
      print FH2 $_;
    }
  }
}

close FH1;
close FH2;
close FH3;
