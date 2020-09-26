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

