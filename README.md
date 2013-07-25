# NAME

Try::Lite - easy exception catcher with auto rethrow

# SYNOPSIS

    use Try::Lite;
    try {
        YourExceptionClass->throw;
    } (
        'YourExceptionClass' => sub {
            say ref($@); # show 'YourExceptionClass'
        }
    );

You can catch base exception class:

    package YourExceptionClass {
        use parent 'BaseExceptionClass';
    }
    

    try {
        YourExceptionClass->throw;
    } (
        'BaseExceptionClass' => sub {
            say ref($@); # show 'YourExceptionClass'
        }
    );

You can catch any exception:

    try {
        die "oops\n";
    } (
        '*' => sub {
            say $@; # show "oops\n";
        }
    );

If there is no matched catch clause, Try::Lite rethrow the exception automatically:

    eval {
        try {
            die "oops\n";
        } (
            'YourExceptionClass' => sub {}
        );
    };
    say $@; # show "oops\n"

You can receives the  try block return value and catechs subs return value:

    my $ret = try {
        'foo'
    } ( '*' => sub {} );
    say $ret; # show 'foo'
    

    my $ret = try {
        die 'foo'
    } ( '*' => sub { 'bar' } );
    say $ret; # show 'bar'

You can catch any exceptions:

    sub run (&) {
      my $code = shift;
    

      try { $code->() } (
        'FileException'    => sub { say 'file exception' },
        'NetworkException' => sub { say 'network exception' }
      );
    }
    

    run { FileException->throw };    # show 'file exception'
    run { NetworkException->throw }; # show 'network exception'
    run { die 'oops' };              # Died

# DESCRIPTION

Try::Lite is easy exception catch with Exception classes.
Exception other than the all specified conditions are It run rethrow.

__THIS IS A DEVELOPMENT RELEASE. API MAY CHANGE WITHOUT NOTICE__.

# EXPORT

## try $code\_ref, %catche\_rules

# AUTHOR

Kazuhiro Osawa <yappo {@} shibuya {dot} pl>

# SEE ALSO

try function base is [Try::Tiny](http://search.cpan.org/perldoc?Try::Tiny)

# LICENSE

Copyright (C) Kazuhiro Osawa

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
