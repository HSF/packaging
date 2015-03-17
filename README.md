# Packaging

Umbrella project to keep track of building / packaging related action items and eventually implementation.

## RFC

I think we agree that there are three separate "concerns" which we should take care of:

- Source management:
  - Should include a way to keep track of vanilla sources as well as experiment specific patches (when required), as they are used by the build systems. Do we all agree on this (+Giulio)?
  - My (Giulio's) modest proposal is to mimick what we do in CMS where we keep a (full or partial) mirror of any externals we use as a Git(Hub) repository per external and for a given `<commit-hash-or-tag>` which is customized we get a `<owner>/<commit-hash-or-tag>` branch which contains the `<owner>` specific patches. The net result of this is:
    - We have a nice web view for both vanilla and patched sources.
    - We keep track of changes (and changes history).
    - We can compare different versions, including a nice web view to do so.
    - Sources being used are uniquely identified by a commit ID.
    - In case of Github mirrors, contributing back is as trivial as PR.
    - In case of non Github mirrors, single patches to feed back are as easy a a URL.
    - Mirror size increase as patches do, not as full version.

- Build recipes:
  - IMHO (Giulio's), these should be as independent as possible from packaging and dependencies, so that they can be used "plug and play"  with more than one packaging system (e.g. LCG, CMS, homebrew ones). Doing so would simplify transition so that we can reuse recipes but still keep our own build infrastructure.
  - IMHO (Giulio's), it should be a clear mandate of the HSF to put effort in version / platform / compiler ports, given that's where 90% of the effort in the end goes.

- Configuration management (i.e. dependencies), packaging and distribution.
  - Do we want a unique configuration and packaging tool?
      - IMHO, (Giulio's), for the short term it is impossible, in particular due to fact that these things are very correlated the build infrastructure, distribution infrastructure and even platform. E.g., if I'm on a mac I want to use homebrew, not install a separate system.
