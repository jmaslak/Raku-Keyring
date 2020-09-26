NAME
====

Keyring - Raku OS Keyring Support Library

SYNOPSIS
========

    use Keyring;

    my $keyring = Keyring.new;
    $keyring.store("MCP", "Root Password", "Pa$$w0rd");
    $value = $keyring.get("MCP", "Root Password");
    $keyring.delete("MCP", "Root Password");

DESCRIPTION
===========

This module uses the Gnome keyring (the standard keyring used on most Linux distributions) or the OSX keychain, if able, to store and retrieve secrets, such as passwords.

To use the Gnome keyring, the `libsecret-tools` package must be installed (so the `secret` command is available). On Debian-based systems, this can be installed as follows:

    sudo apt-get install libsecret-tools

If neither the Gnome keyring or the OSX keychain is available, an in-process keychain is used instead (this keychain is implemented as an in-memory hash table, so all contents are erased when the process exits).

Additional keychain backends can be used, see [Keychain::Backend](Keychain::Backend) for more information.

SECURITY NOTE
=============

For the Gnome keyring, the `secret` command is used to store and retrieve secrets. Note that any user process can use the `secret` CLI utility, so it is important to keep untrusted programs from executing this utility when the keychain is unlocked. In addition, it uses the search path to locate the `secret` utility, so ensure that your `$ENV{PATH}` settings are secure.

For the OS X keychain, the `security` command is used to store and retrieve the secrets. Note that any user process can use this CLI utility, so, like with Gnome keyring, it's important to ensure untrusted programs cannot run as a user with access to sensitive keychain contents! Also, like the Gnome keyring support, `$ENV{PATH}` is used to locate the `security` executable, so it is important that the search path be used in a secure way.

For both environments, the secrets (but not necessarily the attributes or labels) are transferred in a secure way via a pipe/socket with the external application.

VARIABLES
=========

@default-backends
-----------------

    # Configure Keyring to not use the in-memory backend
    @Keyring.default-backends .= grep( { $_ !~~ Keyring::Backend::Memory } );
    $keyring = Keyring.new;  # Will not use in-memory backend

This variable contains a list of classes, in priority order, to be considered for usage. The example above removes the [Keyring::Backend::Memory](Keyring::Backend::Memory) backend, so that the keyring module won't fall-back to that module. You can also add additional keyring backend modules to this list. Generally, it's recommended you add them to the front of the array to use them (the first backend with a `works()` method that returns true will be used; the `Memory` backend always "works" so any backend listed after the `Memory` backend won't be used).

Note that the keyring backend is selected during the first call to any of the methods in this class.

CONSTRUCTOR
===========

    $keyring = Keyring.new;

The constructor typically does not take an argument, but will accept a named argument of `backend` containing an instance of a [Keyring::Backend](Keyring::Backend) class, if you desire to directly use a backend.

ATTRIBUTES
==========

backend
-------

    $keyring.backend($backend)
    if $keyring.backend.defined {
        say("Backend successfully initialized");
    }

This attribute allows access to the backend used by this module. It should be an instance of a `Keyring::Backend` object. If this attribute is not set, it is initialized on the first method call to the `Keyring` instance, using the `@default-backends` variable to determine which backends to query.

METHODS
=======

get(Str:D $attribute, Str:D $label -->Str)
------------------------------------------

    say("Password is: " ~ $keyring.get("foo", "bar"));

This queries the backend for a corresponding attribute and label's password. Note that both the attribute and label must match the data store's values to return a password. Either the password is returned (if found), or an undefined `Str` object is returned. Note that you should generally handle the case where this module returns an undefined value, as if the module is executed on a machine without a usable keyring, it will default to using the in-memory beckend, which is empty when first used.

If this method is called while the `backend` attribute is not yet initialized, it will attempt to locate a suitable keystore using the `@default-backends` variable. Should no backend be suitable, this method will `die()`.

store(Str:D $attribute, Str:D $label, Str:D $secret -->Bool)
------------------------------------------------------------

    $keyring.store("foo", "bar", "password")

This stores a secret (password) in the keyring being used, which will be associated with the attribute and label provided.

If this method is called while the `backend` attribute is not yet initialized, it will attempt to locate a suitable keystore using the `@default-backends` variable. Should no backend be suitable, this method will `die()`.

delete(Str:D $attribute, Str:D $label -->Bool)
----------------------------------------------

    $keyring.delete("foo", "bar")

This deletes the secret for the corresponding attribute and label from the user's keyring.

If this method is called while the `backend` attribute is not yet initialized, it will attempt to locate a suitable keystore using the `@default-backends` variable. Should no backend be suitable, this method will `die()`.

AUTHOR
======

Joelle Maslak <jmaslak@antelope.net>

COPYRIGHT AND LICENSE
=====================

Copyright © 2020 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

