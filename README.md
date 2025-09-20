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

**DataStar** is an Raku-language SDK for [data-star](https://data-star.dev/), the reactive hypermedia framework that uses
signals and server-sent events to integrate hypermedia applications with reactivity.

AUTHOR
======

arunvickram [arunvickram@proton.me](mailto:arunvickram@proton.me)

COPYRIGHT AND LICENSE
=====================

© 2025 Arun Vickram

[![Hippocratic License HL3-BDS-BOD-ECO-EXTR-FFD-LAW-MEDIA-MIL-MY-SOC-SV-USTA-XUAR](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-BDS-BOD-ECO-EXTR-FFD-LAW-MEDIA-MIL-MY-SOC-SV-USTA-XUAR&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/bds-bod-eco-extr-ffd-law-media-mil-my-soc-sv-usta-xuar.html)

