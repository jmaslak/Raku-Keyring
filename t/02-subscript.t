#!/usr/bin/env raku
use v6.c;
use Test;

#
# Copyright © 2020 Joelle Maslak
# All Rights Reserved - See License
#

use Keyring;

my $attribute = "Raku Keyring test $*PID";
my $value     = "foo $*PID";

my $keyring = Keyring.new();
isa-ok $keyring, Keyring, "Keyring is proper type";

my $result = $keyring{$attribute => $value}:exists;
ok !$result, "Result doesn't exist";

$keyring{$attribute => $value} = 'pa$$w0rd';
$result = $keyring{$attribute => $value}:exists;
ok $result, "Password added";

$result = $keyring{$attribute => $value};
is $result, 'pa$$w0rd', "Password validates";

$keyring{$attribute => $value}:delete;
$result = $keyring{$attribute => $value}:exists;
ok !$result, "Result deleted";

$result = $keyring{$attribute => $value};
ok !$result.defined, "Result doesn't exist";

done-testing;

