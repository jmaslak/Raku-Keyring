use v6;

#
# Copyright © 2020 Joelle Maslak
# All Rights Reserved - See License
#

unit class Keyring:ver<0.0.1>:auth<cpan:JMASLAK>;

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

method init_backend(-->Nil) {
    for self.backend-priority<> -> $back {
        if $back.works() {
            $!backend = $back.new;
            return;
        }
    }

    die("Could not configure a keyring backend");
}
