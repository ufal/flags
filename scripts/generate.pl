use strict;
use warnings;
use Cwd;
use YAML::Tiny;
use Getopt::Long;
use File::Spec;
use Text::MarkdownTable;
use File::Temp qw/ tempdir /;
use Image::Size;

my $height = 11;
my $cols = 15;

my ($config_file, $image_dir, $icon_file, $less_file);
my @input_files;

GetOptions('yaml|y=s' => sub { shift; $config_file = shift },
           'icon_file|I=s' => sub { shift; $icon_file = shift },
           'less_file|I=s' => sub { shift; $less_file = shift },
           'image_dir|i=s' => sub { shift; $image_dir = shift },
           'flag_height|h=s'=> sub { shift; $height = shift },
           'cols|c=s'=> sub { shift; $cols = shift },
           );

my $config = YAML::Tiny->read(Cwd::abs_path($config_file))->[0];
my @language_list = sort keys %$config; # IMPORTANT - this creates an order of flags

my $tmp_dir = tempdir( );

my $act_col=0;
my $act_x=0;
my $act_y=0;

for my $lang (@language_list){
  my $lang_conf = $config->{$lang};
  my $img = -s File::Spec->catdir(getcwd, $image_dir, $lang_conf->{flag}.'.png' ) ? $lang_conf->{flag}.'.png' : 'EMPTY.png';
  $lang_conf->{file} = $img;
  my $out_img = File::Spec->catfile($tmp_dir,$img);
  system('convert '.File::Spec->catfile(getcwd, $image_dir,$img).' -geometry x'.$height.' '.$out_img) unless -s $out_img;
  push @input_files, $out_img;

  my ($w,$h) = imgsize($out_img);
  print STDERR "$w\t$act_x\t$out_img\n";

  $lang_conf->{x} = -$act_x;
  $lang_conf->{y} = -$act_y;
  $lang_conf->{w} = $w;
  $lang_conf->{h} = $h;

  if($act_col == $cols -1){
    $act_col = 0;
    $act_y += $height;
    $act_x = 0;
  } else {
    $act_col += 1;
    $act_x += $w;
  }

}

system('montage '.join(' ',@input_files).' -tile '.$cols.'x -background none -mode concatenate '.Cwd::abs_path($icon_file));

my $fh;
open($fh, '>', Cwd::abs_path($less_file));

print $fh "\n// AUTOMATICALLY GENERATED ".localtime()."\n\n";



print $fh join(", \n",grep {$_} map {$_->{lcode} ? '.lang.'.$_->{lcode} : ''} values %$config );
print $fh "{background-image:url('./language-icons.png');background-repeat:no-repeat}\n\n";

for my $lang_conf (values %$config) {
  print $fh '.lang.'.($lang_conf->{lcode}//'empty').' {background-position:'.$lang_conf->{x}.'px '.$lang_conf->{y}.'px;width:'.$lang_conf->{w}.'px;height:'.$lang_conf->{h}.'px;}',"\n";
}




close $fh;

