package Image::Robohash;
use Moose;
use namespace::autoclean;
no  warnings 'portable';
use Digest::SHA qw/sha512_hex/;
use Graphics::Magick;

our $VERSION = 0.01;

=head1 NAME

Image::Robohash - Generate Robohash image

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

	use Image::Robohash;

	my $robot = Image::Robohash->new(
		input        => $sting, 
		client_bgset => 'bg1',
		app_path     => '/path/to/robohash_package',
		geometry     => '100x100'
	);

	$robot->image->Write( '/path/to/image.png' );

=head1 DESCRIPTION

Image::Robohash is a Perl port of the Robohash library in Python. It creates
images locally using a local copy of the Robohash image files available on
GitHub.

This library does not generate Robohash.org URLs.

=head1 EXPORT

No functions are exported.

=head1 METHODS

=head1 $robot->write_file( '/path/to/image.png' )

Write the robot file

=head1 AUTHOR

Colin Davis created Robohash.org project in Python in 2011. John Wang created the Perl port in 2011.

=head1 COPYRIGHT & LICENSE

This code is offered under the Open Source BSD license

Perl port by John Wang

Copyright 2011 Pluric

=head1 SEE ALSO

=item * Robohash.org

L<http://robohash.org/>

=item * Robohash.org GitHub repository

L<https://github.com/e1ven/Robohash>

=cut

has app_path  => ( isa => 'Str', is => 'rw', default => '.'   );

has input     => ( isa => 'Str', is => 'rw', default => ''    );
has bgset     => ( isa => 'Str', is => 'rw', default => ''    );
has size      => ( isa => 'Str', is => 'rw', default => 300   );
has ignoreext => ( isa => 'Str', is => 'rw', default => ''    );
has ext       => ( isa => 'Str', is => 'rw', default => 'png' );

has hash_count    => ( isa => 'Int', is => 'rw', default => 11  );
has hash_index_bg => ( isa => 'Int', is => 'rw', default => 3   );
has iter          => ( isa => 'Int', is => 'rw', default => 4   );

has sets   => ( isa => 'ArrayRef[Str]', is => 'rw', default => sub { [qw/set1 set2 set3/] } );
has bgsets => ( isa => 'ArrayRef[Str]', is => 'rw', default => sub { [qw/bg1 bg2/] } );
has colors => ( isa => 'ArrayRef[Str]', is => 'rw', traits  => ['Array'], handles => { colors_count => 'count' },
	default => sub { [qw/blue brown green grey orange pink purple red white yellow/] }
);

sub BUILD {
	my $self = shift;
	if ($self->input =~ m!\.(png|gif|jpg|jpeg|bmp|im|pcx|ppm|tiff|xbm)\Z!i) {
		$self->ext( lc $1 );
		if ($self->ignoreext) {
			my $str = $self->input;
			$str =~ s|\.[a-z]+\Z||i;
			$self->input( $str );
		}
	}
}

has client_set  => ( isa => 'Str', is => 'rw', lazy => 1,
	default => sub { $_[0]->colors->[ $_[0]->hash_array->[0] % $_[0]->colors_count ] }
);

has hex_digest  => ( isa => 'Str', is => 'rw', lazy => 1, default => sub { sha512_hex $_[0]->input } );
has hash_array  => ( isa => 'ArrayRef[Str]', is => 'rw', lazy => 1, default => sub { $_[0]->create_hashes( $_[0]->hash_count ) } );

has dir_count   => ( isa => 'Int', is => 'rw', lazy => 1,
	default => sub {
		my $self = shift;
		opendir (my $dh, $self->app_path) or die "Cannot open dir $!";
		my @dirs = grep -d $self->app_path."/$_", grep !/\A\.\.?\Z/, readdir $dh;
		closedir $dh;
		return scalar @dirs;
	}
);

sub create_hashes {
	my ($self,$count) = @_;
	my $input = $self->input;
	my $hex   = $self->hex_digest;
	my @hashes;
	for my $i (0..$count-1) {
		my $block_size = int( length( $self->hex_digest ) / $count);
		my $start      = ( 1 + $i ) * $block_size - $block_size;
		push @hashes, hex substr( $self->hex_digest, $start, $block_size );
	}
	return \@hashes;
}

has lucky_robot_images => ( isa => 'ArrayRef[Str]', is => 'rw', lazy => 1,
	default => sub {
		my $self  = shift;
		my $order = [qw/body face accessory eyes mouth/];
		my %map   = map {$order->[$_] => $_+1} 0..$#$order;
		my $list  = $self->get_hash_list( $self->app_path.'/'.$self->client_set );
		my %h_list;
		for my $item (@$list) {
			if ($item =~ m|\-([a-z]+)\-\d\d\.png\Z|) {
				my $part = $1;
				my $part_rank = $map{ $part };
				$h_list{ $item } = $part_rank;
			}
		}
		my @sorted = sort {$h_list{$a} <=> $h_list{$b}} keys %h_list;
		return \@sorted;
	}
);

sub get_hash_list {
	my ($self,$path) = @_;
	return [] unless $path && -d $path;
	my @complete;
	my @local;
	opendir (my $dh, $path) or die "cannot open directory $!";
	my @items = grep !/\A\./, readdir $dh;
	closedir $dh;
	for my $item (sort @items) {
		if (-d "$path/$item") {
			my $sub_files = $self->get_hash_list( "$path/$item" );
			push @complete, @$sub_files if @$sub_files;
		} else {
			push @local, "$path/$item";
		}
	}

	if (my $count = scalar @local) {
		my $element_choice = $self->hash_array->[ $self->iter ] % $count;
		push @complete, $local[ $element_choice ];
		$self->iter( $self->iter + 1 );
	}
	return \@complete;
}

has lucky_background_image => ( isa => 'Str', is => 'rw', lazy => 1,
	default => sub {
		my $self = shift;
		return '' unless my $bgset = $self->bgset;
		my $bgsets = $self->bgsets;
		my $gotit  = 0;
		for my $try (@$bgsets) {
			if ($bgset eq $try) {
				$gotit++;
				last;
			}
		};
		my $dir = $self->app_path."/$bgset";
		return '' unless $gotit && -d $dir;
		opendir (my $dh,$dir);
		my @pngs = sort grep /\.png\Z/, readdir $dh;
		closedir $dh;
		my $lucky = $pngs[ $self->hash_array->[ $self->hash_index_bg ] % scalar @pngs ];
		$lucky = join('/',$self->app_path,$bgset,$lucky);
	}
);

has image => ( isa => 'Graphics::Magick', is => 'rw', lazy => 1,
	default => sub {
		my $self = shift;
		my $img  = Graphics::Magick->new;
		if (my $bg = $self->lucky_background_image) {
			$img->Read("png:$bg");
			$img->Resize(geometry => '300x300');
		} else {
			$img->Set(size => '300x300');
			$img->Read('xc:transparent');
		}
		my $limages = $self->lucky_robot_images;
		for my $image (@$limages) {
			my $gmi = Graphics::Magick->new;
			$gmi->Set(size=>'300x300');
			$gmi->Read("png:$image");
			$img->Composite( image => $gmi, compose => 'over' );
		}
		if ( my $geo = $self->size ){
			if ( $geo =~ m|\A[0-9]+\Z|) {
				$geo = $geo.'x'.$geo;
			} elsif ( $geo !~ m|\A[0-9]+x[0-9]+\Z|) {
				$geo = '300x300';
			}
			$img->Resize( geometry => $geo );
		}
		return $img;
	}
);

__PACKAGE__->meta->make_immutable;
1; # End of Image::Robohash
