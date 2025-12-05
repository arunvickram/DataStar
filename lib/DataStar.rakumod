unit module DataStar;

use DataStar::Constants;
use JSON::Fast::Hyper;

#constant SSE_HEADERS = %{
#    :Cache-Control<no-cache>,
#    :Content-Type<text/event-stream>,
#    :X-Accel-Buffering<no>
#};

subset Css-Id-Selector of Str where *.starts-with('#');

multi read-signals('GET', % (:Datastar-Request($)), % (:$datastar!), Str $) {
    from-json $datastar
}
multi read-signals(Str $method!, % (:Datastar-Request($), Str :$Content-Type! where 'application/json'), %params!, Str $body!) {
    from-json $body
}
multi read-signals($, %, %, $) { Nil }

sub js-bool(Bool $raku-bool) { lc ~?$raku-bool }

sub escape($s) {
    $s.subst('&', '&amp').subst("'", '&#39;').subst('"', '&#34;').subst(">", '&gt;').subst("<", '&lt;')
}

class SseGen is export {
    has @!response-lines; 

    method send(EventType:D $event-type, @data-lines, Str :$event-id, Int :$retry-duration) {
        @!response-lines.push("event: {$event-type.value}\n");
        @!response-lines.push("id: $_\n") with $event-id;

        with $retry-duration {
            @!response-lines.push("retry: $_\n") unless $_ == DEFAULT-SSE-RETRY-DURATION;
        }

        @!response-lines.push("data: $_\n") for @data-lines;
        @!response-lines.push("\n" x 2);
    }

    method Supply {
        supply { 
            emit($_) for @!response-lines; 
        }
    }

    method Str { [~] @!response-lines }
}

sub datastar(&f) is export {
    my $*INSIDE-DATASTAR-RESPONSE-GENERATOR = True;
    my $*render-as-supply = False;
    my SseGen $*response-generator .= new;

    f();

    $*render-as-supply ?? $*response-generator.Supply !! $*response-generator.Str
}

sub render-as-supply {
    fail 'You can only call this method inside a datastar { } block' unless $*INSIDE-DATASTAR-RESPONSE-GENERATOR;

    $*render-as-supply = True;
}

multi patch-elements(Str $elements, Str :$selector, ElementPatchMode :$mode, Bool :$use-view-transition, Str :$event-id, Int :$retry-duration) is export {
    fail 'You can only call this method inside a datastar { } block' unless $*INSIDE-DATASTAR-RESPONSE-GENERATOR;

    my @data-lines;

    with $mode {
        @data-lines.push("{MODE-DATALINE-LITERAL} {.value}") unless $_ == ElementPatchMode::OUTER;
    }

    @data-lines.push("{SELECTOR-DATALINE-LITERAL} $_") with $selector;
    @data-lines.push("{USE-VIEW-TRANSITION-DATALINE-LITERAL} {js-bool($use-view-transition)}") if $use-view-transition;

    with $elements {
        my @element-lines = "{ELEMENTS-DATALINE-LITERAL} " X~ $_.split("\n");
        @data-lines = |@data-lines, |@element-lines;
    }

    $*response-generator.send: EventType::PatchElements, @data-lines, :$event-id, :$retry-duration;
}

#
multi patch-signals(Str $signals, Str :$event-id, Bool :$only-if-missing, Int :$retry-duration) is export {
    fail 'You can only call this method inside a datastar { } block' unless $*INSIDE-DATASTAR-RESPONSE-GENERATOR;

    my @data-lines;

    if $only-if-missing {
        @data-lines.push("{ONLY-IF-MISSING-DATALINE-LITERAL} {js-bool($only-if-missing)}");
    }

    my @signal-lines = "{SIGNALS-DATALINE-LITERAL} " X~ $signals.split("\n");
    @data-lines = |@data-lines, |@signal-lines;

    $*response-generator.send: EventType::PatchSignals, @data-lines, :$event-id, :$retry-duration;
}

multi patch-signals(%signals, *%options) {
    samewith to-json(%signals, :!pretty), |%options;
}

sub remove-elements(Str $selector, Str :$event-id, Int :$retry-duration) is export {
    patch-elements Str, :$selector, :mode(ElementPatchMode::REMOVE), :$event-id, :$retry-duration
}

multi execute-script(Str $script, Bool :$auto-remove, Positional :$attributes, Str :$event-id, Int :$retry-duration) is export {
    my @attrs = [
        'data-effect="el.remove()"' if $auto-remove;
        |$attributes if $attributes
    ];

    my $attrs = @attrs ?? ' ' ~ @attrs.join(' ') !! '';

    my $script-tag = "<script$attrs>" ~ $script ~ "</script>";

    patch-elements $script-tag, :selector<body>, :mode(ElementPatchMode::APPEND), :$event-id, :$retry-duration
}

multi execute-script(Str $script, Bool :$auto-remove, Associative :$attributes, Str :$event-id, Int :$retry-duration) is export {
    my @attributes = [ "{escape(.key)}=\"{escape(.value)}\"" for $attributes.pairs ];
    samewith $script, :$auto-remove, :@attributes, :$event-id, :$retry-duration
}
