use v6.d;

#
# Copyright © 2020-2022 Joelle Maslak
# All Rights Reserved - See License
#

unit class Keyring:ver<0.2.0>:auth<zef:jmaslak>;

use Keyring::Backend;
use Keyring::Backend::MacOSX;
use Keyring::Backend::Memory;
use Keyring::Backend::Secret-Tool;

our @default-backends = [
    Keyring::Backend::Secret-Tool,
    Keyring::Backend::MacOSX,
    Keyring::Backend::Memory,
];

has Keyring::Backend:U @.backend-priority = @default-backends;
has Keyring::Backend   $.backend is rw;


#
# Procedural Interface
#

method get(Str:D $attribute, Str:D $label --> Str) {
    self.init_backend() unless $!backend.defined;
    return $!backend.get($attribute, $label);
}

method store(Str:D $attribute, Str:D $label, Str:D $secret --> Bool) {
    self.init_backend() unless $!backend.defined;
    return $!backend.store($attribute, $label, $secret);
}

method delete(Str:D $attribute, Str:D $label --> Bool) {
    self.init_backend() unless $!backend.defined;
    return $!backend.delete($attribute, $label);
}


#
# Subscript Interface
#

method EXISTS-KEY(Pair:D $key) {
    self.init_backend() unless $!backend.defined;

    return $!backend.get($key.key, $key.value).defined;
}

method ASSIGN-KEY(Pair:D $key, $secret) {
    self.init_backend() unless $!backend.defined;

    return $!backend.store($key.key, $key.value, $secret).defined;
}

method AT-KEY(Pair:D $key) {
    self.init_backend() unless $!backend.defined;

    return $!backend.get($key.key, $key.value);
}

method DELETE-KEY(Pair:D $key) {
    self.init_backend() unless $!backend.defined;

    return $!backend.delete($key.key, $key.value);
}


#
# Internal Methods
#

method init_backend(-->Nil) {
    for self.backend-priority<> -> $back {
        if $back.works() {
            $!backend = $back.new;
            return;
        }
    }

    die("Could not configure a keyring backend");
}

=begin pod

=head1 NAME

Keyring - Raku OS Keyring Support Library

=head1 SYNOPSIS

  use Keyring;

  my $keyring = Keyring.new;

  #
  # Using Procedural Interface
  #
  $keyring.store("MCP", "Root Password", "Pa$$w0rd");
  $value = $keyring.get("MCP", "Root Password");
  $keyring.delete("MCP", "Root Password");

  #
  # Using Subscript Interface
  #
  $keyring{"MCP" => "Root Password"} = "Pa$$w0rd";
  $value = $keyring{"MCP" => "Root Password");
  $keyring{"MCP" => "Root Password"}:delete;


=head1 DESCRIPTION

This module uses the Gnome keyring (the standard keyring used on most Linux
distributions) or the OSX keychain, if able, to store and retrieve secrets,
such as passwords.

To use the Gnome keyring, the C<libsecret-tools> package must be installed (so
the C<secret> command is available).  On Debian-based systems, this can be
installed as follows:

  sudo apt-get install libsecret-tools

If neither the Gnome keyring or the OSX keychain is available, an in-process
keychain is used instead (this keychain is implemented as an in-memory hash
table, so all contents are erased when the process exits).

Additional keychain backends can be used, see L<Keychain::Backend> for more
information.

=head1 SECURITY NOTE

For the Gnome keyring, the C<secret> command is used to store and retrieve
secrets. Note that any user process can use the C<secret> CLI utility, so
it is important to keep untrusted programs from executing this utility when
the keychain is unlocked.  In addition, it uses the search path to locate
the C<secret> utility, so ensure that your C<$ENV{PATH}> settings are
secure.

For the OS X keychain, the C<security> command is used to store and
retrieve the secrets. Note that any user process can use this CLI utility,
so, like with Gnome keyring, it's important to ensure untrusted programs
cannot run as a user with access to sensitive keychain contents!  Also,
like the Gnome keyring support, C<$ENV{PATH}> is used to locate
the C<security> executable, so it is important that the search path be
used in a secure way.

For both environments, the secrets (but not necessarily the attributes or
labels) are transferred in a secure way via a pipe/socket with the
external application.

=head1 VARIABLES

=head2 @default-backends

  # Configure Keyring to not use the in-memory backend
  @Keyring.default-backends .= grep( { $_ !~~ Keyring::Backend::Memory } );
  $keyring = Keyring.new;  # Will not use in-memory backend

This variable contains a list of classes, in priority order, to be considered
for usage.  The example above removes the L<Keyring::Backend::Memory> backend,
so that the keyring module won't fall-back to that module.  You can also add
additional keyring backend modules to this list. Generally, it's recommended
you add them to the front of the array to use them (the first backend with
a C<works()> method that returns true will be used; the C<Memory> backend
always "works" so any backend listed after the C<Memory> backend won't be
used).

Note that the keyring backend is selected during the first call to any of
the methods in this class.

=head1 CONSTRUCTOR

  $keyring = Keyring.new;

The constructor typically does not take an argument, but will accept a
named argument of C<backend> containing an instance of a L<Keyring::Backend>
class, if you desire to directly use a backend.

=head1 ATTRIBUTES

=head2 backend

  $keyring.backend($backend)
  if $keyring.backend.defined {
      say("Backend successfully initialized");
  }

This attribute allows access to the backend used by this module.  It should
be an instance of a C<Keyring::Backend> object.  If this attribute is not
set, it is initialized on the first method call to the C<Keyring> instance,
using the C<@default-backends> variable to determine which backends to
query.

=head1 PROCEDURAL INTERFACE METHODS

=head2 get(Str:D $attribute, Str:D $label -->Str)

  say("Password is: " ~ $keyring.get("foo", "bar"));

This queries the backend for a corresponding attribute and label's password.
Note that both the attribute and label must match the data store's values
to return a password.  Either the password is returned (if found), or an
undefined C<Str> object is returned.  Note that you should generally handle
the case where this module returns an undefined value, as if the module is
executed on a machine without a usable keyring, it will default to using
the in-memory beckend, which is empty when first used.

If this method is called while the C<backend> attribute is not yet
initialized, it will attempt to locate a suitable keystore using
the C<@default-backends> variable.  Should no backend be suitable, this
method will C<die()>.

=head2 store(Str:D $attribute, Str:D $label, Str:D $secret -->Bool)

  $keyring.store("foo", "bar", "password")

This stores a secret (password) in the keyring being used, which will
be associated with the attribute and label provided.

If this method is called while the C<backend> attribute is not yet
initialized, it will attempt to locate a suitable keystore using
the C<@default-backends> variable.  Should no backend be suitable, this
method will C<die()>.

=head2 delete(Str:D $attribute, Str:D $label -->Bool)

  $keyring.delete("foo", "bar")

This deletes the secret for the corresponding attribute and label from
the user's keyring.

If this method is called while the C<backend> attribute is not yet
initialized, it will attempt to locate a suitable keystore using
the C<@default-backends> variable.  Should no backend be suitable, this
method will C<die()>.

=head1 SUBSCRIPT INTERFACE METHODS

The standard subscript methods (like a C<Hash>) will work with this object.
Note that the hash "key" is really the attribute and label passed as a C<Pair>
object (the "key" of the pair is the attribute, the value is the label).
All standard hash methods work except for binding a value.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2020-2022 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
