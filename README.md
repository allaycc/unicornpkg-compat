# allay-unicornpkg-compat

Translator that lets [allay](https://github.com/allaycc/allay) read
unicornpkg-format packages.

## Install

    allay install allay-unicornpkg-compat

Reboot afterwards. Then add a unicornpkg-format source:

    allay source add unicornpkg/unicornpkg-main

allay will fetch and translate packages from there using the same
install pipeline (auto-deps, hash verification, atomic install) as
native allay packages.

## What translates cleanly

Most unicornpkg packages from `unicornpkg-main` use the `com.github`,
`com.github.release`, `com.github.gist`, or `com.pastebin` providers.
All four are supported.

Other providers (`com.gitlab`, `org.bitbucket`, `org.codeberg`, `ht.sr`,
`org.softwareheritage.archive`, etc.) are not supported in v1. Packages
using them will fail to install with a clear error.

## What's lossy in translation

- **Author install scripts** (`script.preinstall`, `script.postinstall`,
  etc.) are skipped. allay's install pipeline runs no scripts from
  unicornpkg packages. If a package needs its scripts to function, use
  hoof for that package or wait for an allay-native version.
- **Some unusual install paths** are categorized as `raw` (literal
  absolute path) instead of one of allay's structured kinds. This
  preserves the unicornpkg behavior at the cost of allay's namespacing
  guarantees.

## Spec version

This translator targets `unicornpkg/v1.0.0`. If unicornpkg's spec
changes, an updated version of this package will be released.

## Acknowledgements

unicornpkg's package format is the work of the unicornpkg project
(<https://unicornpkg.madefor.cc>). This compat layer reads that format
under its open-source license; the translator is independent.

## License

MIT.
