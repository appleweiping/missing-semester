# Ex2 — Rust dependency version specifiers (Cargo semver)

> Take a look at the various ways to specify version requirements for
> dependencies in Rust's build system. Most package repositories support similar
> syntax to the one for Rust. For each one (caret, tilde, wildcard, comparison,
> and multiple requirements) come up with a use-case in which that particular
> kind of requirement makes sense to use.

Cargo interprets a bare `"1.2.3"` as a **caret** requirement. Given
`MAJOR.MINOR.PATCH` semver, here is each operator, what it allows, and when it
is the right choice.

| Spec | Example | Allows | Blocks |
|------|---------|--------|--------|
| Caret `^` (default) | `^1.2.3` | `>=1.2.3, <2.0.0` | breaking major bumps |
| Tilde `~` | `~1.2.3` | `>=1.2.3, <1.3.0` | minor bumps |
| Wildcard `*` | `1.2.*` | `>=1.2.0, <1.3.0` | anything outside `1.2` |
| Comparison | `>=1.2, <1.5` | exactly that range | outside the range |
| Multiple | `>=1.2.3, <1.8, !=1.5.0` | intersection of all | any clause's exclusions |

### Caret `^1.2.3` — the default, everyday dependency

**Use-case:** almost every normal library dependency. You trust the crate to
follow semver, so you happily accept any new **minor/patch** release (bug fixes,
backwards-compatible features) but refuse an automatic jump to `2.0` that could
break your build. This is why Cargo makes it the default — it maximises free
upgrades while staying API-compatible.

### Tilde `~1.2.3` — pin the minor, allow patches only

**Use-case:** a dependency you integrate against a *specific* minor API and only
want **patch-level** bug fixes for. E.g. a crate whose `1.3` added a feature that
subtly changes behaviour you depend on; `~1.2.3` keeps you on the `1.2` line and
still lets you pick up `1.2.4`, `1.2.5` security fixes.

### Wildcard `1.2.*` — accept any patch of a fixed minor

**Use-case:** similar to tilde but expressed as "any patch of 1.2". Handy in a
metapackage or template where you want to say "the 1.2 series" without caring
about the exact patch. (Note: crates.io **rejects** a bare `*` for published
crates — too dangerous — so wildcards are mostly for local/workspace use.)

### Comparison `>=1.2, <1.5` — an explicit window

**Use-case:** you know your code needs a feature introduced in `1.2` **and** you
know `1.5` dropped/changed an API you rely on. An explicit half-open range
documents exactly the compatibility window you validated against, independent of
the crate's own semver discipline.

### Multiple requirements `>=1.2.3, <1.8, !=1.5.0` — carve out a bad release

**Use-case:** you want a broad range but must **exclude a specific known-bad
version** (a release with a data-corruption bug or a yanked-but-cached
version). Combining clauses lets you say "anything from 1.2.3 up to but not
including 1.8, but never 1.5.0".

### Bottom line

- Reach for **caret** (the default) for ordinary deps.
- Use **tilde/wildcard** when a minor bump has bitten you and you want patches
  only.
- Use **comparison / multiple** requirements when you need to encode an exact
  validated window or dodge a specific broken release.
