# Low-resource impact

A dependency changes the cost of every future install, build, and test run on a
constrained machine. Weigh that recurring cost against the one-time code it
avoids.

## Costs to weigh

- Install time and disk footprint, including the transitive tree
- Build cost: native compilation, code generation, or bundling steps
- Runtime cost: memory and startup time added to every run
- Bundle or container size increase
- Whether it forces a heavier toolchain (a compiler, a specific runtime)

## Cheap versus expensive signals

- Cheap: a small pure-language package with no build step and few transitives
- Expensive: a package with native builds, large transitive trees, prebuilt
  binaries, or post-install scripts

## Decision implications

- A large recurring build or install cost weighs toward **do not add** when a
  small local function or an existing dependency suffices
- When the dependency avoids substantial correct-by-construction code (crypto,
  parsers, protocol clients), its cost is usually justified
- If the cost cannot be estimated without installing, **defer pending evidence**
  rather than install to measure
