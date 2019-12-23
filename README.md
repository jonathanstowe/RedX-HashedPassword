# RedX::HashedPassword

A facility to allow the Red ORM to store and use hashed passwords in the database.

## Synopsis

```raku

use Red;
use RedX::HashedPassword;

model User {
    has Int $.id        is serial;
    has Str $.username  is column;
    has Str $.password  is password handles <check-password>;
}

...

User.^create( username => 'user', password => 'password'); # password is saved as a hash

...

my User $user = User.^rs.first( *.username eq 'user' );

$user.check-password('password');  # True

```

## Description

This provides a mechanism for [Red](https://github.com/FCO/Red) to store a password
as a cryptographic hash in the database, such that someone who gains access to the
database cannot see the plain text password that may have been entered by a user.

The primary interface provided is the ```is password``` trait that should be
applied to the column attribute in your model definition that you want to store the
hashed password in, this takes care of hashing the password before it is stored in
the database, on retrieval ("inflation") it also applies a role that provides a method
```check-password``` that checks a provided plaintext password against the stored hash.
You can make this appear to be a method of your (for example,) User model by applying
the ```handles <check-password>``` trait to your column attribute.

The hashing algorithm used will be the best one provided by
[Crypt::AnyPasswordHash](https://github.com/jonathanstowe/Crypt-AnyPasswordHash)
which has two implications, firstly the default provider is
[Crypt::Libcrypt](https://github.com/jonathanstowe/Crypt-Libcrypt) if no
other supported hashing module is installed, this will attempt to use the
mechanism suggested by the `libcrypt` but if this can't be determined,
it will fall back to SHA-512 which seems to be the best commonly provided
algorithm, except on `MacOS` where the `libcrypt` only appears to support
the "heritage" DES algorithm - which has been considered insecure for most
of this century, so you probably don't want to use this in production
on MacOS for the timebeing without installing one of the other modules
supported by `Crypt::AnyPasswordHash`. The second implication is that,
if you are going to access the hashed password from multiple hosts,
you should ensure that you have the same hashing module installed on
all the hosts in order that they can all verify the same methods.

## Installtion

Assuming you have a working Rakudo installation then you can install this with *zef*:


     zef install RedX::HashedPassword

     # or from a local copy

     zef install .

The module requires at least v0.1.0 of [Crypt::Libcrypt](https://github.com/jonathanstowe/Crypt-Libcrypt)
so you may want to upgrade that first if you already have it installed.

## Support

Suggestions/patches are welcomed via github at:

https://github.com/jonathanstowe/RedX-HashedPassword/issues

Ideally there should be a better choice of hashing algorithm from those
provided by the OS and installed modules, this will come after the initial
release.


## Licence

This is free software.

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2019

