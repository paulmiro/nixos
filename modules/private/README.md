# Private Data

The `private.json` file contains private data, such as:

- usernames
- email adresses
- domain names

It does not contain "real" secrets, such as:

- passwords
- secret keys

The file is encryptet using [sops](https://github.com/getsops/sops) with [age](https://github.com/FiloSottile/age)

In order to build configurations that use this private data, you need to decrypt it. There are two ways to do this:

### Git Filter (Recommended)

1. Add this to the bottom of your `.git/config` file:

```conf
[filter "sopsfilter"]
    clean = sops encrypt --input-type json --output-type json /dev/stdin | cat
	smudge = sops decrypt --input-type json --output-type json /dev/stdin
```

2. Apply the filter with

```shell
git restore modules/private/private.json
```

This will always keep your local copy of the file decrypted at all times, and will automatically encrypt it when you commit.
If encryption fails, it will instead commit an empty file to ensure nothing gets leaked (this should only ever happen when sops is not installed)

### Manually (NOT RECOMENNDED, MAY LEAK DATA ON ACCIDENT)

You can of course always decrypt manually like this:

```shell
sops decrypt modules/private/private.json --in-place
```

And re-encrypt like this:

```shell
sops encrypt modules/private/private.json --in-place
```

However, if you accidentally commit in the decrypted state, this will of course leak the data.
