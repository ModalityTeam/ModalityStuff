
/// issues:
// - behaviour of control
// - hierarchy labels
// - multiple devices / ports
// - templates
// - gui hints

// general properties:
\type - // be clear for human beings to understand what it is
* \button
* \switch - like a slide switch/toggle switch

* \knob
//* \knobButton
( ...
  (
    elementType: \combined,
    elements: (
        kn: ( type: \knob )
        bt: ( type: \button )
    )
  ),
  ...
);

( ...
  (
    midiChan: 0,
    type: \pianoKeyboard, // could be a known type
    elements: (0..127).collect{ |it|
        (
            type: \pianoKey,
            midiNum: it,
            elements: (
                on: ( midiMsgType: \noteOn ),
                off: ( midiMsgType: \noteOff )
            );
        );
    }
  ),
  ...
);

* \slider
( elements:
(
\sl: ( \type: \slider ),
\touch: ( \type, \touch )
)
)

* \stickAxis - joysticks/thumbsticks
//* \stickButton - (when you press a thumbstick)
(
\joy: (
\type: \joy
    elements:
    (
        \type: \stick,
        \elements: (
            \x: ( \type: \stickAxis ),
            \y: ( \type: \stickAxis )
        )
    ),
    (
        \bt: ( \type: \button )
    )
)
);


* \hatSwitch - (compass on gamepads, on top of joysticks)
* \throttle - the sideways knob on a joystick, 'bumpers' on the run'n'drive

* \encoder - endless knob, often with a led ring around it
* \pad - drum pads
* \pianoKey - velocity sensitive (like what you play Fuer Elise on)
* \keyboardKey - not velocity sensitive (like what you write the letters to your mom on)

* \mouseAxis
* \wheel

\spec - how values are mapped to 0-1
\ioType - [ \in, \out, \inout ] - is there
\mode - reflects behaviour
- [\toggle,\latch] : hit button, and it stays in its state, until you hit it again (latch)
- \momentary : press button: on, release: off
- \relative : element only sends relative data (up/down)
- \snapBack : default value should be reflected in the spec (e.g. at the center, minimum, maximum)


// -- (( hardware specific:
// MIDI:
\midiMsgType (used to \midiType)
\midiChan
\midiNum
-- specific specs for midi messages, like \midiCC

// HID:
'hidUsage'
'hidUsagePage'
// or:
'hidElementID'
// ---- hardware specific )) --