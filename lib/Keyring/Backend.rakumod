use v6.d;

#
# Copyright © 2020 Joelle Maslak
# All Rights Reserved - See License
#

unit class Keyring::Backend:ver<0.0.1>:auth<cpan:JMASLAK>;

method get(Str:D $attribute, Str:D $label --> Str) { … }
method store(Str:D $attribute, Str:D $label, Str:D $secret --> Bool) { … }
method delete(Str:D $attribute, Str:D $label --> Bool) { … }
method works(-->Bool) { … }

=begin pod

=head1 NAME

Keyring::Backend - Raku OS Keyring Backend Parent Class

=head1 DESCRIPTION

This is a virtual class that can be used to define Keyring backends.  To
implement a new backend, inherit from this class and define
the C<get>, C<store>, C<delete>, and C<works> methods.

This class should never be instantiated directly.

=head1 METHODS

=head2 get(Str:D $attribute, Str:D $label -->Str)

Implementations should create this method.

This queries the backend for a corresponding attribute and label's password.
Note that both the attribute and label must match the data store's values
to return a password.  Either the password is returned (if found), or an
undefined C<Str> object is returned.

=head2 store(Str:D $attribute, Str:D $label, Str:D $secret -->Bool)

Implementations should create this method.

This stores a secret (password) in the keyring being used, which will
be associated with the attribute and label provided.

=head2 delete(Str:D $attribute, Str:D $label -->Bool)

Implementations should create this method.

This deletes the secret for the corresponding attribute and label from
the user's keyring.

=head2 works(-->Bool)

Implementations should create this method.

Returns C<True> if this implementation appears able to work for the user. I.E.
if the backend depends on the existance of command line tools, libraries,
etc, this method should validate that these things are working.  This lets
the L<Keyring> module select a "working" backend for the user, allowing more
portable code.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2020 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
