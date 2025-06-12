# Private Data

The `private.json` file contains private data, such as:

- usernames
- email adresses
- domain names

It does not contain "real" secrets, such as:

- passwords
- secret keys

The file is encrypted using [git-agecrypt](https://github.com/vlaci/git-agecrypt)

## Setup

In order to build configurations that use this private data, you need to decrypt it.

Please refer to the documantation of git-agecrypt to see how to set this up.

## Jank

git-agecrypt can be pretty weird about changing `git-agecrypt.toml` without also changing `private.json`.

If you run into any errors here, just commit some small change (e.g. add a space at the end of the file) to `private.json` alongside the change to `git-agecrypt.toml`.
