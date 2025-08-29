# I got an error, what do I do?

If you are reading this because you tried to evaluate my configuration and got an error, simply change the contents of ./allow_fake.nix to `true`.

This will replace the private data with fake data, allowing you to evaluate the config.

# Private Data

The `private.toml` file contains private data, such as:

- usernames
- email adresses
- domain names

It does not contain "real" secrets, such as:

- passwords
- secret keys

The file is encrypted using [git-agecrypt-armor](https://github.com/paulmiro/git-agecrypt-armor), which is my fork of [git-agecrypt](https://github.com/vlaci/git-agecrypt)

## Setup

In order to build configurations that use this private data, you need to decrypt it.

Files encrypted by `git-agecrypt-armor` can still be decrypted with `git-agecrypt`. `git-agecrypt-armor` is only needed if you want to push changes to the file.

Please refer to the documantation of git-agecrypt to see how to set it up.

If you used nix to install `git-agecrypt` or `git-agecrypt-armor`, make sure to remove the hardcoded store path in .git/config after, to avoid having it break on update

## Jank

git-agecrypt can be pretty weird about changing `git-agecrypt.toml` without also changing `private.toml`.

If you run into any errors here, just commit some small change (e.g. add a space at the end of the file) to `private.toml` alongside the change to `git-agecrypt.toml`.
