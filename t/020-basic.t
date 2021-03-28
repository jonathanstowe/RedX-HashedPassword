#!/usr/bin/env raku

use v6;

use Test;

use Red;
use RedX::HashedPassword;


my $*RED-DEBUG = %*ENV<RED_DEBUG> // False;
my $*RED-DB = database "SQLite";

model M is table<mmm> { 
    has Int $.id is serial;
    has Str $.username      is column{:unique, :!nullable};
    has Str $.password      is password handles <check-password> is rw;
    has Str $.text_column   is column{:nullable} is rw;
}

M.^create-table;

my $password = ('a' .. 'z').pick(10).join;

my $a = M.^create(username => 'testuser', password => $password);

isnt $a.password, $password, 'should get back the hashed password';

ok $a.check-password($password), "check-password";

my $b = M.^rs.first(*.username eq 'testuser');
is $b.password, $a.password, "retrieved the same hashed password";

$b.text_column = "some text";
$b.^save;

$b = M.^rs.first(*.username eq 'testuser');
is $b.password, $a.password, "retrieved the same hashed password (after update)";

$password = ('a' .. 'z').pick(10).join;


$b.password = $password;
$b.^save(:update);

ok $b.check-password($password), "check-password (updated password)";

my $c = M.^rs.first(*.username eq 'testuser');
is $c.password, $b.password, "retrieved the same hashed password as the one in the object";

done-testing;

# vim: expandtab shiftwidth=4 ft=raku
