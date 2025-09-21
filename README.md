[![Actions Status](https://github.com/arunvickram/DataStar/actions/workflows/linux.yml/badge.svg)](https://github.com/arunvickram/DataStar/actions) [![Actions Status](https://github.com/arunvickram/DataStar/actions/workflows/macos.yml/badge.svg)](https://github.com/arunvickram/DataStar/actions) [![Actions Status](https://github.com/arunvickram/DataStar/actions/workflows/windows.yml/badge.svg)](https://github.com/arunvickram/DataStar/actions)

NAME
====

**DataStar** - the real-time hypermedia framework, Rakufied.

SYNOPSIS
========

```raku
use DataStar;

# in some Cro application
sub routes() is export {
    route {
        post -> 'validate' {
            my $response = patch-elements(
                "<div>Hello there</div>",
                :as-supply,
                :selector<.validation>,
                :mode(PatchMode::AFTER)
            );

            content 'text/event-stream', $response;
        }
    }
}
```

DESCRIPTION
===========

**DataStar** is an Raku-language SDK for [data-star](https://data-star.dev/), the reactive hypermedia framework that uses signals and server-sent events to integrate hypermedia applications with reactivity.

AUTHOR
======

    Arun Vickram L<arunvickram@proton.me|mailto:arunvickram@proton.me>

COPYRIGHT AND LICENSE
=====================

© 2025 Arun Vickram

