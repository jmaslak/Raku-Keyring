use v6;

#
# Copyright © 2020 Joelle Maslak
# All Rights Reserved - See License
#

use Keyring::Backend;

unit class Keyring::Backend::Memory:ver<0.0.1>:auth<cpan:JMASLAK> is Keyring::Backend;

has %!items;

method get(Str:D $attribute, Str:D $label --> Str) {
    return Str unless %!items{$attribute}:exists;
    return Str unless %!items{$attribute}{$label}:exists;

    return %!items{$attribute}{$label};
}

method store(Str:D $attribute, Str:D $label, Str:D $secret --> Bool) {
    %!items{$attribute} = {} unless %!items{$attribute}:exists;
    %!items{$attribute}{$label} = $secret;

    return True;
}

method delete(Str:D $attribute, Str:D $label --> Bool) {
    return True unless %!items{$attribute}:exists;
    %!items{$attribute}{$label}:delete;
    %!items{$attribute}:delete unless %!items.keys.elems;

   return True;
}

submethod works(--> Bool) { True }

=begin pod

=head1 NAME

Keyring::Backend::Memory - Raku Memory Keyring Backend

=head1 SYNOPSIS

  use Keyring::Backend::Memory;

  my $keyring = Keyring.new;
  $keyring.store("MCP", "Root Password", "Pa$$w0rd");
  $value = $keyring.get("MCP", "Root Password");
  $keyring.delete("MCP", "Root Password");

=head1 DESCRIPTION

This module should generally not be used directly. Instead, look
at L<Keyring>.

This module uses an in-process keyring.  This keyring starts empty and
will cease to exist when th𝑒 instance is destroyed.

=head1 CONSTRUCTOR

  $keyring = Keyring::Backend::Memory.new;

The constructor does not take any arguments.

=head1 METHODS

=head2 get(Str:D $attribute, Str:D $label -->Str)

  say("Password is: " ~ $keyring.get("foo", "bar"));

This queries the instance for a corresponding attribute and label's password.
Note that both the attribute and label must match the data store's values
to return a password.  Either the password is returned (if found), or an
undefined C<Str> object is returned.

=head2 store(Str:D $attribute, Str:D $label, Str:D $secret -->Bool)

  $keyring.store("foo", "bar", "password")

This stores a secret (password) in the keyring being used, which will
be associated with the attribute and label provided.

=head2 delete(Str:D $attribute, Str:D $label -->Bool)

  $keyring.delete("foo", "bar")

This deletes the secret for the corresponding attribute and label from
the keyring.

=head2 works(-->Bool)

Always returns C<True> (this backend can always work).

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2020 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
