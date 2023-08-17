use utf8;
binmode STDOUT, ":utf8";

@code = ();
$blank = "<span style=\"background-color:#ccc;\">　</span>";
$kana = "イ";
$hangul = "가";

open FH, "<:utf8", "work/codepoint.txt";
while(<FH>){
  $_ =~ m/^u([0-9a-f]+)\n$/;
  $code[eval('0x'.$1)]++;
}
close FH;

print "<!DOCTYPE html><html><head><meta charset='utf8'><style>body{font-family:Jigmo3,Jigmo2,Jigmo;}span:hover{color:red;background-color:yellow;}</style></head><body>";
print "<h1>Jigmo fonts</h1>font version: 2023-08-16<br><br>";

foreach(0x00 .. 0x3ff){
  $high = $_;
  $buffer = "";
  $count = 0;
  foreach(0x00 .. 0xff){
    $low = $_;
    $code = $high * 256 + $low;
    if($low % 32 == 0){ $buffer .= "<br>"; }
    if($code[$code]){
      if(0x302a <= $code && $code <= 0x302d || $code == 0x3099 || $code == 0x309a){
        $buffer .= $kana;
      }
      if($code == 0x302e || $code == 0x302f){
        $buffer .= $hangul;
      }
      $buffer .= "<span title=\"".sprintf("U+%04X", $code)."\">".pack('U', $high * 256 + $low)."</span>";
      $count++;
    } else {
      $buffer .= $blank;
    }
  }
  if($count > 0){
    printf("U+%02Xxx ($count glyphs)\n", $high);
    print "<div>$buffer</div><br>\n";
  }
}

%ivd = ();

open FH, "<:utf8", "work/IVD_Sequences.txt";
while(<FH>){
  if($_ =~ m/^([0-9A-F]+) (E01[0-9A-F]{2}); ([^;]+);/){
    $ivd{lc($1)} .= $2.",";
  }
}
close FH;

foreach(sort {hex($a) <=> hex($b)} keys(%ivd)){
  $head = $_;
  print pack('U', eval('0x'.$head)).sprintf("(U+%04X) ", eval('0x'.$head));
  @temp = split(/,/, $ivd{$_});
  %temp = ();
  foreach(@temp){
    $temp{$_}++;
  }
  foreach(sort keys(%temp)){
    print("<span title=\"".sprintf("U+%04X ", eval('0x'.$head))."U+$_\">".pack('U',eval('0x'.$head)).pack('U',eval('0x'.$_))."</span>");
  }
  print("<br>");
}
print "</body></html>";
