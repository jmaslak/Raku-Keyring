use v6;

#
# Copyright © 2020 Joelle Maslak
# All Rights Reserved - See License
#

use Keyring::Backend;

unit class Keyring::Backend::Secret-Tool:ver<0.0.1>:auth<cpan:JMASLAK> is Keyring::Backend;

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

