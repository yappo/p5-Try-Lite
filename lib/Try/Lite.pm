package Try::Lite;
use strict;
use warnings;
use parent 'Exporter';
use 5.008005;
our $VERSION = '0.0.1';

our @EXPORT = 'try';

use Scalar::Util;
use Carp;
$Carp::Internal{+__PACKAGE__}++;

sub try (&;%) {
    my($try, @catches) = @_;

    confess 'Unknown @catches values. Check your usage & try again'
        unless @catches;

    # check @catches
    for (my $i = 0; $i < @catches; $i += 2) {
        confess q{illegal @catches values. try {} 'ClassName' => sub {}, ...;}
            unless $catches[$i] && ref($catches[$i + 1]) eq 'CODE';
    }

    # we need to save this here, the eval block will be in scalar context due
    # to $failed
    my $wantarray = wantarray;

    # save the value of $@ so we can set $@ back to it in the beginning of the eval
    my $prev_error = $@;

    my(@ret, $error, $failed);
    {
        # localize $@ to prevent clobbering of previous value by a successful
        # eval.
        local $@;

        # failed will be true if the eval dies, because 1 will not be returned
        # from the eval body
        $failed = not eval {
            $@ = $prev_error;

            # evaluate the try block in the correct context
            if ( $wantarray ) {
                @ret = $try->();
            } elsif ( defined $wantarray ) {
                $ret[0] = $try->();
            } else {
                $try->();
            };

            return 1; # properly set $fail to false
        };

        # copy $@ to $error; when we leave this scope, local $@ will revert $@
        # back to its previous value
        $error = $@;
    }

    if ($failed) {
        for (my $i = 0;$i < @catches;$i += 2) {
            my($class, $code) = ($catches[$i], $catches[$i + 1]);
            next unless $class eq '*' || (Scalar::Util::blessed($error) && UNIVERSAL::isa($error, $class));

            local $@ = $error;
            $code->();
            return;
        }

        # rethrow
        die $error;
    }

    # no failure, $@ is back to what it was, everything is fine
    return $wantarray ? @ret : $ret[0];
}


1;
__END__

=encoding utf8

=head1 NAME

Try::Lite - easy exception catcher with auto rethrow

=head1 SYNOPSIS

  use Try::Lite;
  try {
      YourExceptionClass->throw;
  }
      'YourExceptionClass' => sub {
          say ref($@); # show 'YourExceptionClass'
      };

you can catch base exception class:

  package YourExceptionClass {
      use parent 'BaseExceptionClass';
  }
  
  try {
      YourExceptionClass->throw;
  }
      'BaseExceptionClass' => sub {
          say ref($@); # show 'YourExceptionClass'
      };

you can catch any exception:

  try {
      die "oops\n";
  }
      '*' => sub {
          say $@; # show "oops\n";
      };

auto rethrow:

  eval {
      try {
          die "oops\n";
      }
          'YourExceptionClass' => sub {};
  };
  say $@; # show "oops\n"

you can any exception catch:

  sub run (&) {
    my $code = shift;
  
    try { $code->() }
      'FileException'    => sub { say 'file exception' },
      'NetworkException' => sub { say 'network exception' };
  }
  
  run { FileException->throw };    # show 'file exception'
  run { NetworkException->throw }; # show 'network exception'
  run { die 'oops' };              # Died

=head1 DESCRIPTION

Try::Lite is easy exception catch with Exception classes.
Exception other than the all specified conditions are It run rethrow.

B<THIS IS A DEVELOPMENT RELEASE. API MAY CHANGE WITHOUT NOTICE>.

=head1 EXPORT

=head2 try $code_ref, %catche_rules

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo {@} shibuya {dot} plE<gt>

=head1 SEE ALSO

try function base is L<Try::Tiny>

=head1 LICENSE

Copyright (C) Kazuhiro Osawa

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
