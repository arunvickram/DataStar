unit class DataStar;

use JSON::Fast::Hyper;

constant DEFAULT_RETRY_DURATION = 1000;

enum EventType is export (:Patch-Elements<datastar-patch-elements>, :Patch-Signals<datastar-patch-signals>);

enum PatchMode is export (
    :OUTER('outer'),
    :INNER('inner'),
    :REMOVE('remove'),
    :REPLACE('replace'),
    :PREPEND('prepend'),
    :APPEND('append'),
    :BEFORE('before'),
    :AFTER('after')
);

role HTMLRenderer {
    method HTML( --> Str:D ) {}
    method Str ( --> Str:D ) {}
}

sub js-bool($x) {
    if $x { 'true' } else { 'false' }
}

sub escape($s) {
    $s.subst('&', '&amp').subst("'", '&#39;').subst('"', '&#34;').subst(">", '&gt;').subst("<", '&lt;')
}

sub send(EventType:D $event-type, @data-lines, Str:_ :$event-id, Int:_ :$retry-duration) {
    my @prefix = ["event: {$event-type.value}"];

    with $event-id {
        @prefix.push("id: $_");
    }

    with $retry-duration {
        @prefix.push("retry: $_") unless $_ == DEFAULT_RETRY_DURATION;
    }

    my @data = "data: " X~ @data-lines;

    [ |@prefix, |@data ].join("\n") ~ ("\n" x 2)
}

sub send-supply(EventType:D $event-type, @data-lines, Str:_ :$event-id, Int:_ :$retry-duration) {
    supply {
        emit("event: {$event-type.value}\n");
        emit("id: $_\n") with $event-id;

        with $retry-duration {
            emit("retry: $_\n") unless $_ == DEFAULT_RETRY_DURATION;
        }

        emit("data: $_\n")  for @data-lines;
        emit("\n" x 2)
    }
}

sub patch-elements(Str(HTMLRenderer) $elements, Str :$selector, PatchMode :$mode, Bool :$use-view-transition, Str :$event-id, Int :$retry-duration, Bool :$as-supply) is export {
    my @data-lines;

    with $mode {
        @data-lines.push("mode: {.value}") unless $_ == PatchMode::OUTER;
    }

    @data-lines.push("selector: $_") with $selector;

    @data-lines.push("useViewTransition: {js-bool($use-view-transition)}") if $use-view-transition;

    with $elements {
        my @element-lines = "elements: " X~ $_.split("\n");
        @data-lines = |@data-lines, |@element-lines;
    }

    if $as-supply {
        send-supply(EventType::Patch-Elements, @data-lines, :$event-id, :$retry-duration)
    } else {
        send(EventType::Patch-Elements, @data-lines, :$event-id, :$retry-duration)
    }
}

multi sub patch-signals(Str $signals, Str :$event-id, Bool :$only-if-missing, Int :$retry-duration, Bool :$as-supply) is export {
    my @data-lines;

    if $only-if-missing {
        @data-lines.push("onlyIfMissing: {js-bool($only-if-missing)}");
    }

    my @signal-lines = "signals: " X~ $signals.split("\n");
    @data-lines = |@data-lines, |@signal-lines;

    if $as-supply {
        send-supply(EventType::Patch-Signals, @data-lines, :$event-id, :$retry-duration)
    } else {
        send(EventType::Patch-Signals, @data-lines, :$event-id, :$retry-duration)
    }
}

multi sub patch-signals(%signals, Str :$event-id, Bool :$only-if-missing, Int :$retry-duration, Bool :$as-supply) {
    patch-signals(to-json(%signals), :$event-id, :$only-if-missing, :$retry-duration, :$as-supply)
}

sub remove-elements(Str $selector, Str :$event-id, Int :$retry-duration, Bool :$as-supply) is export {
    patch-elements(Str, :$selector, :mode(PatchMode::REMOVE), :$event-id, :$retry-duration, :$as-supply)
}

multi sub execute-script(Str $script, Bool :$auto-remove, Array :$attributes, Str :$event-id, Int :$retry-duration, Bool :$as-supply) is export {
    my $attr-str = "";

    $attr-str ~= ' data-effect="el.remove()"' if $auto-remove;
    $attr-str ~= $attributes.join(" ") if $attributes;

    my $script-tag = "<script $attr-str>" ~ $script ~ "</script>";

    patch-elements($script-tag, :selector<body>, :mode(PatchMode::APPEND), :$event-id, :$retry-duration, :$as-supply)
}


multi sub execute-script(Str $script, Bool :$auto-remove, :@attributes, Str :$event-id, Int :$retry-duration, Bool :$as-supply) {
    my $attr-str = "";

    $attr-str ~= ' data-effect="el.remove()"' if $auto-remove;
    $attr-str ~= @attributes.join(" ") if @attributes;

    my $script-tag = "<script $attr-str>" ~ $script ~ "</script>";

    patch-elements($script-tag, :selector<body>, :mode(PatchMode::APPEND), :$event-id, :$retry-duration, :$as-supply)
}

multi sub execute-script(Str $script, Bool :$auto-remove, :%attributes, Str :$event-id, Int :$retry-duration, Bool :$as-supply) {
    my @attributes = [ "{escape(.key)}=\"{escape(.value)}\"" for %attributes.pairs ];
    execute-script($script, :$auto-remove, :@attributes, :$event-id, :$retry-duration, :$as-supply)
}

multi sub execute-script(Str $script, Bool :$auto-remove, Hash :$attributes, Str :$event-id, Int :$retry-duration, Bool :$as-supply) {
    my @attributes = [ "{escape(.key)}=\"{escape(.value)}\"" for $attributes.pairs ];
    execute-script($script, :$auto-remove, :@attributes, :$event-id, :$retry-duration, :$as-supply)
}
