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

