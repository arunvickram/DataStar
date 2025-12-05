unit module DataStar::Constants;

enum EventType is export (
    PatchElements => 'datastar-patch-elements',
    PatchSignals  => 'datastar-patch-signals'
);

enum ElementPatchMode is export (
    OUTER   => 'outer',
    INNER   => 'inner',
    REMOVE  => 'remove',
    REPLACE => 'replace',
    PREPEND => 'prepend',
    APPEND  => 'append',
    BEFORE  => 'before',
    AFTER   => 'after'
);

constant SELECTOR-DATALINE-LITERAL             is export = "selector";
constant MODE-DATALINE-LITERAL                 is export = "mode";
constant ELEMENTS-DATALINE-LITERAL             is export = "elements";
constant USE-VIEW-TRANSITION-DATALINE-LITERAL  is export = "useViewTransition";
constant SIGNALS-DATALINE-LITERAL              is export = "signals";
constant ONLY-IF-MISSING-DATALINE-LITERAL      is export = "onlyIfMissing";
constant DEFAULT-SSE-RETRY-DURATION            is export = 1000;
constant DEFAULT-ELEMENTS-USE-VIEW-TRANSITIONS is export = False;
constant DEFAULT-PATCH-SIGNALS-ONLY-IF-MISSING is export = False;
