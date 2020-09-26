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

