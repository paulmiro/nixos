# Private Data

The `private.json` file contains private data, such as:

- usernames
- email adresses
- domain names

It does not contain "real" secrets, such as:

- passwords
- secret keys

The file is encrypted using [sops](https://github.com/getsops/sops) with [age](https://github.com/FiloSottile/age)

In order to build configurations that use this private data, you need to decrypt it. There are two ways to do this:

### Git Filter (Recommended)

1. Add this to the bottom of your `.git/config` file:

```conf
[filter "sopsfilter"]
    clean = sops encrypt --input-type json --output-type json /dev/stdin | cat
	smudge = sops decrypt --input-type json --output-type json /dev/stdin
[diff "catdiffer"]
	textconv = cat
```

2. Apply the filter with

```shell
git restore modules/private/private.json
```

This will always keep your local copy of the file decrypted at all times, and will automatically encrypt it when you commit.
If encryption fails, it will instead commit an empty file (that's what the `| cat` does) to ensure nothing gets leaked (this should only ever happen when sops is not installed)

Due to the fact that age encryption is non-deterministic, editing the file and then reverting the changes will result in it being _visually_ unchanged, but it will still be added to the git index. From git's perspective the file has been changed, because the re-encryption has resulted in a different encrypted file. If you find this annoying, you can ignore the change with

```shell
git update-index --assume-unchanged modules/private/private.json
```

Whenever you need to change the file in the future, simply undo this with

```shell
git update-index --no-assume-unchanged modules/private/private.json
```

### Manually (NOT RECOMENNDED, MAY LEAK DATA ON ACCIDENT)

You can of course always decrypt manually like this:

```shell
sops decrypt modules/private/private.json --in-place
```

And re-encrypt like this:

```shell
sops encrypt modules/private/private.json --in-place
```

However, if you accidentally commit in the decrypted state, this will of course leak the data. To avoid this, you can do the `update-index` step detailed in the Git Filter section above.

# Why do all of this in the first place?

This is my solution to a quite unique combination of problems:

1. My configuration contains some (semi-)private data that I do not want to be publicly visible on GitHub
2. Some of this data needs to exist at build time (for example domain names for the NGINX configuration), so I can't just use my deployment tool (currently [lollypops](https://github.com/pinpox/lollypops)) to place files with the data on the destination host before building, like I do with "real" secrets
3. Nix flakes use the git tree to find files, so I can't simply add the file(s) containing private data to .gitignore
4. I need my CI to have access to the data as well, so I can't use tools like [git-crypt](https://github.com/AGWA/git-crypt) or [transcrypt](https://github.com/elasticdog/transcrypt), as those tools do not have simple ways of manually decrypting files
5. I prefer having a clean way of accessing the private data from my configuration, instead of having to do a `builtins.readFile` everytime

After doing a lot of research about this topic, what I've built here is the best solution I was able to come up with. It is not perfect, but good enough for now.
