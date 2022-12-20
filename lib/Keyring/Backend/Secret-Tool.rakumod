use v6;

#
# Copyright © 2020 Joelle Maslak
# All Rights Reserved - See License
#

use Keyring::Backend;

unit class Keyring::Backend::Secret-Tool:ver<0.1.0>:auth<zef:jmaslak> is Keyring::Backend;

our $cmd = "secret-tool";
my $working;  # Cached "is this working" result

method get(Str:D $attribute, Str:D $label --> Str) {
    my $proc = run $cmd, "lookup", $attribute, $label, :out, :err;
    my $out = $proc.out.slurp;
    if $out eq "" {
        return Str;
    } else {
        return $out;
    }
}

method store(Str:D $attribute, Str:D $label, Str:D $secret --> Bool) {
    my $proc = run $cmd, "store", "--label=$attribute-$label", $attribute, $label, :in, :err;
    $proc.in.print($secret);
    $proc.in.close;
    return $proc.so;
}

method delete(Str:D $attribute, Str:D $label --> Bool) {
    my $proc = run $cmd, "clear", $attribute, $label, :err;
    return $proc.so;
}

submethod works(--> Bool) {
    return $working if $working.defined;

    CATCH {
        $working = False;
        return False;
    }

    try {
        my $non-exist = "THIS SHOULD NOT ACTUALLY EXIST";
        my $proc = run $cmd, "store", "--label=$non-exist", $non-exist, $non-exist, :in, :err;
        $proc.in.say($non-exist);
        $proc.in.close;
        if ! $proc.so {
            $working = False;
            return False unless $proc.so;
        }

        $proc = run($cmd, "clear", $non-exist, $non-exist, :err);
        $working = $proc.so;
        return $proc.so;
    }

    $working = False;
    return False;
}

=begin pod

=head1 NAME

Keyring::Backend::Secret-Tool - Raku Secret-Tool (Gnome Keyring) Backend

=head1 SYNOPSIS

  use Keyring::Backend::Secret-Tool;

  my $keyring = Keyring.new;
  $keyring.store("MCP", "Root Password", "Pa$$w0rd");
  $value = $keyring.get("MCP", "Root Password");
  $keyring.delete("MCP", "Root Password");

=head1 DESCRIPTION

This module should generally not be used directly. Instead, look
at L<Keyring>.

This module uses the Gnome keychain to store and retrieve secrets.

It requires C<secret-tool> to be installed.  To install this package on
a Debian-like system:

  sudo apt-get install libsecret-tools

=head1 SECURITY NOTE

For the Gnome keychain, the C<secret-tool> command is used to store and
retrieve the secrets. Note that any user process can use this CLI utility,
so, it's important to ensure untrusted programs cannot run as a user with
access to sensitive keychain contents!  Also, C<$ENV{PATH}> is used to
locate the C<secret-tool> executable, so it is important that the search path be
used in a secure way.

=head1 CONSTRUCTOR

  $keyring = Keyring::Backend::Secret-Tool.new;

The constructor does not take any arguments.

=head1 METHODS

=head2 get(Str:D $attribute, Str:D $label -->Str)

  say("Password is: " ~ $keyring.get("foo", "bar"));

This queries the backend for a corresponding attribute and label's password.
Note that both the attribute and label must match the data store's values
to return a password.  Either the password is returned (if found), or an
undefined C<Str> object is returned.  Note that you should generally handle
the case where this module returns an undefined value, as it is possible
for keyrings to be deleted by the end user or other processes.

=head2 store(Str:D $attribute, Str:D $label, Str:D $secret -->Bool)

  $keyring.store("foo", "bar", "password")

This stores a secret (password) in the keyring being used, which will
be associated with the attribute and label provided.

=head2 delete(Str:D $attribute, Str:D $label -->Bool)

  $keyring.delete("foo", "bar")

This deletes the secret for the corresponding attribute and label from
the user's keyring.

=head2 works(-->Bool)

  die("Keyring doesn't work!") if ! $keyring.works;

Returns C<True> if this keyring will work for the user, C<False> otherwise.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2020 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
