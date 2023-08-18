#!/usr/bin/perl

use utf8;

my $version = "2023-08-16";
my $author = "Koichi Kamichi";

my $fontname;
if($ARGV[0] eq "2"){
  $fontname = "Jigmo2";
} elsif($ARGV[0] eq "3"){
  $fontname = "Jigmo3";
} else {
  $fontname = "Jigmo";
}

$FONTFORGE = "fontforge";
$PERL = "perl";
$TTX = "ttx";

$WORK_DIR = "work";
$GLYPH_DIR = "$WORK_DIR/glyph";
$FONT_DIR = "$WORK_DIR/font";
mkdir($FONT_DIR);

if(-e "$FONT_DIR/$fontname.ttf"){
  print(".ttf File exists.");
  exit;
}

$hankaku_data = `wget -nv https://glyphwiki.org/wiki/Group:HalfwidthGlyphs-BMP?action=edit -O- 2>> $WORK_DIR/stderr.txt`;
utf8::decode($hankaku_data);
$temp = `wget -nv https://glyphwiki.org/wiki/Group:HalfwidthGlyphs-SMP?action=edit -O- 2>> $WORK_DIR/stderr.txt`;
utf8::decode($temp);
$hankaku_data = $hankaku_data."\n".$temp;

$nsgh = `wget -nv https://glyphwiki.org/wiki/Group:NonSpacingGlyphs-Halfwidth?action=edit -O- 2>> $WORK_DIR/stderr.txt`;
utf8::decode($nsgh);
$nsgf = `wget -nv https://glyphwiki.org/wiki/Group:NonSpacingGlyphs-Fullwidth?action=edit -O- 2>> $WORK_DIR/stderr.txt`;
utf8::decode($nsgf);

my $baseline = 30;

my %glyphlist = ();
my %ivslist = ();
open my $fh, "<:utf8", "$WORK_DIR/codepoint.txt";
while(<$fh>){
  if($ARGV[0] eq "2"){
    if($_ =~ m/^(u00[0-9a-f]{2})\n$/){
      $glyphlist{$1} = $1;
    }
    if($_ =~ m/^(u2[0-9a-f]{4})\n$/){
      $glyphlist{$1} = $1;
    }
    if($_ =~ m/^(u2[0-9a-f]{4}-ue01[0-9a-f]{2})\n$/){
      $ivslist{$1} = $1;
    }
  } elsif($ARGV[0] eq "3"){
    if($_ =~ m/^(u00[0-9a-f]{2})\n$/){
      $glyphlist{$1} = $1;
    }
    if($_ =~ m/^(u3[0-9a-f]{4})\n$/){
      $glyphlist{$1} = $1;
    }
    if($_ =~ m/^(u3[0-9a-f]{4}-ue01[0-9a-f]{2})\n$/){
      $ivslist{$1} = $1;
    }
  } else {
    if($_ =~ m/^(u[0-9a-f]{4})\n$/){
      $glyphlist{$1} = $1;
    }
    if($_ =~ m/^(u1[0-9a-f]{4})\n$/){
      $glyphlist{$1} = $1;
    }
    if($_ =~ m/^(u[0-9a-f]{4}-ue01[0-9a-f]{2})\n$/){
      $ivslist{$1} = $1;
    }
  }
}
close $fh;

if($ARGV[0] eq "2"){
  $glyphlist{"u4e00"} = "u4e00";
} elsif($ARGV[0] eq "3"){
  $glyphlist{"u4e00"} = "u4e00";
} else {
  $glyphlist{"u20000"} = "u20000";
}

open my $fh, ">:utf8", "$FONT_DIR/$fontname.scr";
print $fh qq|Open("basefont.ttf")\n|;

print $fh qq|Reencode("UnicodeFull")\n|;
print $fh qq|SetTTFName(0x411,0,"$author")\n|;
print $fh qq|SetTTFName(0x411,1,"$fontname")\n|;
print $fh qq|SetTTFName(0x411,2,"Regular")\n|;
print $fh qq|SetTTFName(0x411,4,"$fontname Regular")\n|;
print $fh qq|SetTTFName(0x411,5,"$version")\n|;
print $fh qq|SetTTFName(0x411,6,"$fontname")\n|;
print $fh qq|SetTTFName(0x409,0,"$author")\n|;
print $fh qq|SetTTFName(0x409,1,"$fontname")\n|;
print $fh qq|SetTTFName(0x409,2,"Regular")\n|;
print $fh qq|SetTTFName(0x409,4,"$fontname Regular")\n|;
print $fh qq|SetTTFName(0x409,5,"$version")\n|;
print $fh qq|SetTTFName(0x409,6,"$fontname")\n|;
print $fh qq|SetFontHasVerticalMetrics(1)\n|;

foreach(sort(keys(%glyphlist))){
  my $name = $glyphlist{$_};
  my $dir = "$GLYPH_DIR/".substr($name,0,length($name)-3)."/".substr($name,0,length($name)-2);
  print $fh qq|Print(0$_)\n|;
  print $fh qq|Select(0$_)\n|;
  print $fh qq|Import("$dir/$glyphlist{$_}.svg")\n|;
#  print $fh qq|Simplify()\n|;
  print $fh qq|Scale(105,105,512,307)\n|;
  if(index($nsgh.$nsgf, "\[\[$name\]\]") != -1){
    print $fh qq|SetWidth(0)\n|;
  } elsif(index($hankaku_data, "\[\[$name\]\]") != -1){
    print $fh qq|SetWidth(512)\n|;
  } else {
    print $fh qq|SetWidth(1024)\n|;
  }
  if(index($nsgh, "\[\[$name\]\]") != -1){
    print $fh qq|Move(-512, $baseline)\n|;
  } elsif(index($nsgf, "\[\[$name\]\]") != -1){
    print $fh qq|Move(-1024, $baseline)\n|;
  } else {
    print $fh qq|Move(0, $baseline)\n|;
  }
  print $fh qq|SetVWidth(1024)\n|;
  print $fh qq|RoundToInt()\n|;
  print $fh qq|DontAutoHint()\n|;
  print $fh qq|ClearHints()\n|;
  print $fh qq|AutoInstr()\n|;
}

if(scalar(keys(%ivslist)) > 0){
  $ivs_offset = 0x100000;
  open my $fh2, ">$FONT_DIR/$fontname.ivs";
  print $fh2 "<cmap_format_14 platformID=\"0\" platEncID=\"5\" format=\"14\" length=\"0\" numVarSelectorRecords=\"0\">\n";
  foreach(sort(keys(%ivslist))){
    my $ucswithivs = $_;
    my @temp = split(/-/, $ucswithivs);
    my $ucswithoutivs = $temp[0];
    my $uv = "0x".substr($temp[0], 1);
    my $uvs = "0x".substr($temp[1], 1);
    
    my $name = $ivslist{$ucswithivs};
    my $dir = "$GLYPH_DIR/".substr($name,0,length($name)-10)."/".substr($name,0,length($name)-9);
    
    if($dummy = `diff $dir/$ucswithivs.svg $dir/$ucswithoutivs.svg`){
      my $cp = sprintf("0u%x", $ivs_offset);
      my $cpname = "u".uc(substr($cp, 2));
      
      print $fh qq|Print($cp)\n|;
      print $fh qq|Select($cp)\n|;
      print $fh qq|Import("$dir/$ivslist{$ucswithivs}.svg")\n|;
#      print $fh qq|Simplify()\n|;
      print $fh qq|Scale(105,105,512,307)\n|;
      print $fh qq|SetWidth(1024)\n|;
      print $fh qq|Move(0, $baseline)\n|;
      print $fh qq|SetVWidth(1024)\n|;
      print $fh qq|RoundToInt()\n|;
      print $fh qq|DontAutoHint()\n|;
      print $fh qq|ClearHints()\n|;
      print $fh qq|AutoInstr()\n|;
      
      print $fh2 "<map uvs=\"$uvs\" uv=\"$uv\" name=\"$cpname\"/>\n";
      
      $ivs_offset++;
    } else {
      my $cpname;
      if(length($ucswithoutivs) > 5){
        $cpname = "u".uc(substr($ucswithoutivs, 1));
      } else {
        $cpname = "uni".uc(substr($ucswithoutivs, 1));
      }
      print $fh2 "<map uvs=\"$uvs\" uv=\"$uv\" name=\"$cpname\"/>\n";
    }
  }
  print $fh2 "</cmap_format_14>\n";
  close $fh2;
}

my $flag;
if(scalar(keys(%ivslist)) > 0){
  $flag = 0b111111111111111111111111 & 0x80;
} else {
  $flag = 0b111111111111111111111111 & (0x4 | 0x80);
}
print $fh qq|Generate("$FONT_DIR/$fontname.raw.ttf", "", $flag)\n|;
print $fh qq|Quit()\n|;
close $fh;

if(scalar(keys(%ivslist)) > 0){
  my $dummy = `$FONTFORGE -script $FONT_DIR/$fontname.scr 2>> $WORK_DIR/stderr.txt`;
  $dummy .= `$TTX -t cmap -t OS\\/2 -t post $FONT_DIR/$fontname.raw.ttf 2>> $WORK_DIR/stderr.txt`;
  $dummy .= `$PERL divide_ttx.pl $FONT_DIR/$fontname.raw`;
  $dummy .= `cat $FONT_DIR/$fontname.raw.pre > $FONT_DIR/$fontname.ivs.ttx`;
  $dummy .= `cat $FONT_DIR/$fontname.ivs >> $FONT_DIR/$fontname.ivs.ttx`;
  $dummy .= `cat $FONT_DIR/$fontname.raw.post >> $FONT_DIR/$fontname.ivs.ttx`;
  $dummy .= `$TTX -m $FONT_DIR/$fontname.raw.ttf $FONT_DIR/$fontname.ivs.ttx 2>> $WORK_DIR/stderr.txt`;
  $dummy .= `cp gsub_dummy.txt $FONT_DIR/$fontname.ttx`;
  $dummy .= `$TTX -m $FONT_DIR/$fontname.ivs.ttf $FONT_DIR/$fontname.ttx 2>> $WORK_DIR/stderr.txt`;
  
  my $filesize = -s "$FONT_DIR/$fontname.ttf";
  my $padding = (4 - $filesize % 4) % 4;
  if($padding > 0){
    $dummy .= `head -c $padding /dev/zero >> 
$FONT_DIR/$fontname.ttf`;
  }
} else {
  my $dummy = `$FONTFORGE -script $FONT_DIR/$fontname.scr 2>> $WORK_DIR/stderr.txt`;
  $dummy .= `$TTX -t cmap -t OS\\/2 -t post $FONT_DIR/$fontname.raw.ttf 2>> $WORK_DIR/stderr.txt`;
  $dummy .= `$PERL divide_ttx.pl $FONT_DIR/$fontname.raw`;
  $dummy .= `cat $FONT_DIR/$fontname.raw.pre > $FONT_DIR/$fontname.ttx`;
  $dummy .= `cat $FONT_DIR/$fontname.raw.post >> $FONT_DIR/$fontname.ttx`;
  $dummy .= `$TTX -m $FONT_DIR/$fontname.raw.ttf $FONT_DIR/$fontname.ttx 2>> $WORK_DIR/stderr.txt`;
  
  my $filesize = -s "$FONT_DIR/$fontname.ttf";
  my $padding = (4 - $filesize % 4) % 4;
  if($padding > 0){
    $dummy .= `head -c $padding /dev/zero >> $FONT_DIR/$fontname.ttf`;
  }
}

unlink("$FONT_DIR/$fontname.raw.ttf");
unlink("$FONT_DIR/$fontname.raw.ttx");
unlink("$FONT_DIR/$fontname.raw.pre");
unlink("$FONT_DIR/$fontname.raw.post");
unlink("$FONT_DIR/$fontname.ivs.ttf");
