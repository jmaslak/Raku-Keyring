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

my $result = $keyring.get($attribute, $value);
ok !$result.defined, "Result doesn't exist";

$result = $keyring.store($attribute, $value, 'pa$$w0rd');
ok $result, "Store executed properly";

$result = $keyring.get($attribute, $value);
is $result, 'pa$$w0rd', "Password validates";

$result = $keyring.delete($attribute, $value);
ok $result, "Delete executed properly";

$result = $keyring.get($attribute, $value);
ok !$result.defined, "Result doesn't exist";

diag "Class type: {$keyring.backend.^name}";

done-testing;

