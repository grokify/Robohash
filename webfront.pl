#!/usr/local/env perl;

=head1 SYNOPSIS

	$ cd path/to/e1ven-Robohash
	$ ln -s static public
	$ morbo webfront.pl

=head1 COPYRIGHT AND LICENSE

Perl port by John Wang

Copyright 2011 Pluric

=cut

use Mojolicious::Lite;
use lib "./lib";
use Image::Robohash;

get '/static/*staticpath' => sub {
	$_[0]->render_not_found unless
	$_[0]->render_static($_[0]->param('staticpath'))
};

get '/' => sub {
	$_[0]->stash( robo => get_ascii_robo() );
	$_[0]->render('root');
};

get '/(.string)'  => sub {
	my $self  = shift;
	my $robot = Image::Robohash->new(
		input     => $self->param('string')   ||'',
		ignoreext => $self->param('ignoreext')||'',
		size      => $self->param('size')     ||'',
		bgset     => $self->param('bgset')    ||'',
		app_path  => '.',
	);
	my $ext     = $robot->ext;
	my $outfile = $robot->hex_digest.".$ext";
	my $outpath = "./static/tmp/$outfile";
	$robot->image->Write( $outpath );
	$self->render( data => do { local(@ARGV,$/)=$outpath;<> }, format => $ext );
	unlink $outpath;
};

sub get_ascii_robo {
	my @robo = (
q{
              ,     ,
             (\\____/)
              (_oo_)
                (O)
              __||__    \\)
           []/______\\[] /
           / \\______/ \\/
          /    /__\\
         (\\   /____\\ },
q[
                 _______
               _/       \\_
              / |       | \\
             /  |__   __|  \\
            |__/((o| |o))\\__|
            |      | |      |
            |\\     |_|     /|
            | \\           / |
             \\| /  ___  \\ |/
              \\ | / _ \\ | /
               \\_________/
                _|_____|_
           ____|_________|____
          /                   \\  -- Mark Moir

 
],
q{
                        .andAHHAbnn.
                     .aAHHHAAUUAAHHHAn.
                    dHP^~"        "~^THb.
              .   .AHF                YHA.   .
              |  .AHHb.              .dHHA.  |
              |  HHAUAAHAbn      adAHAAUAHA  |
              I  HF~"_____        ____ ]HHH  I
             HHI HAPK""~^YUHb  dAHHHHHHHHHH IHH
             HHI HHHD> .andHH  HHUUP^~YHHHH IHH
             YUI ]HHP     "~Y  P~"     THH[ IUP
              "  `HK                   ]HH'  "
                  THAn.  .d.aAAn.b.  .dHHP
                  ]HHHHAAUP" ~~ "YUAAHHHH[
                  `HHP^~"  .annn.  "~^YHH'
                   YHb    ~" "" "~    dHF
                    "YAb..abdHHbndbndAP"
                     THHAAb.  .adAHHF
                      "UHHHHHHHHHHU"
                        ]HHUUHHHHHH[
                      .adHHb "HHHHHbn.
               ..andAAHHHHHHb.AHHHHHHHAAbnn..
          .ndAAHHHHHHUUHHHHHHHHHHUP^~"~^YUHHHAAbn.
            "~^YUHHP"   "~^YUHHUP"        "^YUP^"
                 ""         "~~"
},
q{
                                    /~@@~\\,
                  _______ . _\\_\\___/\\ __ /\\___|_|_ . _______
                 / ____  |=|      \\  <_+>  /      |=|  ____ \\
                 ~|    |\\|=|======\\\\______//======|=|/|    |~
                  |_   |    \\      |      |      /    |    |
                   \\==-|     \\     |  2D  |     /     |----|~~)
                   |   |      |    |      |    |      |____/~/
                   |   |       \\____\\____/____/      /    / /
                   |   |         {----------}       /____/ /
                   |___|        /~~~~~~~~~~~~\\     |_/~|_|/
                    \\_/        [/~~~~~||~~~~~\\]     /__|\\
                    | |         |    ||||    |     (/|[[\\)
                    [_]        |     |  |     |
                               |_____|  |_____|
                               (_____)  (_____)
                               |     |  |     |
                               |     |  |     |
                               |/~~~\\|  |/~~~\\|
                               /|___|\\  /|___|\\
                              <_______><_______>},
q{ 
                                         _____
                                        /_____\\
                                   ____[\\`---'/]____
                                  /\\ #\\ \\_____/ /# /\\
                                 /  \\# \\_.---._/ #/  \\
                                /   /|\\  |   |  /|\\   \\
                               /___/ | | |   | | | \\___\\
                               |  |  | | |---| | |  |  |
                               |__|  \\_| |_#_| |_/  |__|
                               //\\\\  <\\ _//^\\\\_ />  //\\\\
                               \\||/  |\\//// \\\\\\\\/|  \\||/
                                     |   |   |   |
                                     |---|   |---|
                                     |---|   |---|
                                     |   |   |   |
                                     |___|   |___|
                                     /   \\   /   \\
                                    |_____| |_____|
                                    |HHHHH| |HHHHH|
                              }, 
q[
                                           ()               ()
                                            \\             /
                                           __\\___________/__
                                          /                 \\
                                         /     ___    ___    \\
                                         |    /   \\  /   \\   |
                                         |    |  H || H  |   |
                                         |    \\___/  \\___/   |
                                         |                   |
                                         |  \\             /  |
                                         |   \\___________/   |
                                         \\                   /
                                          \\_________________/
                                         _________|__|_______
                                       _|                    |_
                                      / |                    | \\
                                     /  |            O O O   |  \\
                                     |  |                    |  |
                                     |  |            O O O   |  |
                                     |  |                    |  |
                                     /  |                    |  \\
                                    |  /|                    |\\  |
                                     \\| |                    | |/
                                        |____________________|
                                           |  |        |  |
                                           |__|        |__|
                                          / __ \\      / __ \\
                                          OO  OO      OO  OO
                              ]
	);
	$robo[rand(@robo)];
}

app->start;
