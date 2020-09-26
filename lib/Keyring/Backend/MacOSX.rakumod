use v6;

#
# Copyright © 2020 Joelle Maslak
# All Rights Reserved - See License
#

use Keyring::Backend;

unit class Keyring::Backend::MacOSX:ver<0.0.1>:auth<cpan:JMASLAK> is Keyring::Backend;

our $cmd = "security";
my $working;  # Cached "is this working" result

method get(Str:D $attribute, Str:D $label --> Str) {
    CATCH {
        return Str;
    }

    try {
        my $proc = run $cmd, "-i", :in, :out, :err;
        $proc.in.say("find-generic-password -a \"{ self.quote($attribute) }\" " ~
            "-s \"{ self.quote($label) }\" -w");
        $proc.in.close;
        my $out = $proc.out.slurp.chomp;
        return $out;
    }
}

method store(Str:D $attribute, Str:D $label, Str:D $secret --> Bool) {
    CATCH {
        return False;
    }

    try {
        my $proc = run $cmd, "-i", :in, :out, :err;
        $proc.in.say("add-generic-password -a \"{ self.quote($attribute) }\" " ~
            "-s \"{ self.quote($label) }\" -w \"{ self.quote($secret) }\" -U");
        $proc.in.close;
        $working = $proc.so;
        return $proc.so;
    }
}

method delete(Str:D $attribute, Str:D $label --> Bool) {
    CATCH {
        return False;
    }

    try {
        my $proc = run $cmd, "-i", :in, :out, :err;
        $proc.in.say("delete-generic-password -a \"{ self.quote($attribute) }\" " ~
            "-s \"{ self.quote($label) }\"");
        $proc.in.close;
        $working = $proc.so;
        return $proc.so;
    }
}

submethod works(--> Bool) {
    return $working if $working.defined;

    CATCH {
        $working = False;
        return False;
    }

    try {
        my $non-exist = "THIS SHOULD NOT ACTUALLY EXIST";
        my $proc = run $cmd, "-i", :in, :out, :err;
        $proc.in.say("add-generic-password -a \"$non-exist\" -s \"$non-exist\" -w \"Test\" -U");
        $proc.in.close;
        if ! $proc.so {
            $working = False;
            return False unless $proc.so;
        }

        $proc = run $cmd, "-i", :in, :out, :err;
        $proc.in.say("delete-generic-password -a \"$non-exist\" -s \"$non-exist\"");
        $proc.in.close;
        $working = $proc.so;
        return $proc.so;
    }

    $working = False;
    return False;
}

submethod quote(Str:D $in --> Str:D) {
    my $out = $in;
    $out ~~ s/\\/\\\\/;
    $out ~~ s/\"/\\\"/;
    return $out
}

=begin pod

=head1 NAME

Keyring::Backend::MacOSX - Raku Mac OS X Keyring Backend

=head1 SYNOPSIS

  use Keyring::Backend::MacOSX;

  my $keyring = Keyring.new;
  $keyring.store("MCP", "Root Password", "Pa$$w0rd");
  $value = $keyring.get("MCP", "Root Password");
  $keyring.delete("MCP", "Root Password");

=head1 DESCRIPTION

This module should generally not be used directly. Instead, look
at L<Keyring>.

This module uses the OSX keychain to store and retrieve secrets.

=head1 SECURITY NOTE

For the OS X keychain, the C<security> command is used to store and
retrieve the secrets. Note that any user process can use this CLI utility,
so, it's important to ensure untrusted programs cannot run as a user with
access to sensitive keychain contents!  Also, C<$ENV{PATH}> is used to
locate the C<security> executable, so it is important that the search path be
used in a secure way.

=head1 CONSTRUCTOR

  $keyring = Keyring::Backend::MacOSX.new;

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
