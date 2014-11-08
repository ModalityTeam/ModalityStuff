// still incomplete, but moving toward more clarity.

Access examples LPD8:

physical layout:

*                 PAD5  PAD6  PAD7  PAD8    K1  K2  K3  K4
PROGRAM    PAD    PAD1  PAD2  PAD3  PAD4    K5  K6  K7  K8
PROG_CHNG  CC

mode buttons - just flat as names
\PROGRAM, \PAD,
\PROGCHNG  \CC

pads :
  by label as printed on them, PAD1 .. PAD8
  as array of 8 ordered items -> index 0 .. 7
as 4x2 grid - down-Up (as label numbering), then left->right,
 so e.g. 0,1 is pad2
////// likely not: also access first 4 as tags PROG1 etc?

controls:
* by label, K1, etc
* as array of 8 ordered items, index 0.. 7
* as 4x2 grid, up-down, then left-right,
  so e.g. 0, 1 is pad2



4 MODE BUTTONS:
  they all do not send anything via MIDI by itself.

PROGRAM button:
  enables pads 1-4 to switch between 4 hardware pages,
  which are just on midi chans 0..3.
  cc numbers and program numbers stay the same across pages,
  midiNote numbers from the pads change:

prog1:  chan 0,  36 .. 43
prog2:  chan 1,  35, 36, 42, 39, 37, 38, 46, 44
prog3:  chan 2,  60, 62, 64, 65, 67, 69, 71, 72
prog4:  chan 3,  36, 38, 40, 41, 43, 45, 47, 48

PROGCHNG button:
  does not send anything via MIDI by itself.
  switches all 8 pads to program mode,
  so they send MIDI program change values 0-7 on
  on midichan of hardware scene, 0-3.
  controls of current page unchanged.

PAD button:
  does not send anything via MIDI by itself.
   switches pads in current scene to noteOnOff mode,
   notes as in current scene

CC button:
  does not send anything via MIDI by itself.

K1 .. K8
- always send controls as on current page.

PAD1 .. PAD8
- three modes affect the pads,
   PAD mode send notes of curr page
   CC mode sends ccs [1,2,3,4,5,6,8,9]
   PROG mode sends program changes 0..7 on scene chan.

k = MKtl(\lpd80);


ACCESS VARIANTS:

// as direct as possible - by unique name

k.scene
k.atName(\PAD8, \scene0);

// raw with scene and 0-based index
k.rawAt(\PAD_0_7);

k.at(\PAD8);

k.at(\scene1).at(\PAD8)
k.at(0).at(\pad).at(7);
k.at(0).at(\PAD8);
  // if there are scenes, and  this not finding a scene
  // with that name or index, it jumps to the current scene
k.at(\PAD8);

// option: continue extending numbering,
// so scene 0 is PAD1-8, scene 1 is PAD9-16 etc
// e.g. Mackie control could really use this

// Q: scene? is there a current scene in the background?
// Q: how can we access things in a non-current scene?
// have a current scene implied when not given

k.at(\pad) // pad element group
k.at(\pad).at(3); // by index in array

k.makeGroup(\top4pads, [
	\p5 -> k.at(\PAD5),
	\p6 -> k.at(\PAD6),
	\p7 -> k.at(\PAD7),
	\p8 -> k.at(\PAD8)
);
k.at(\top4pads).at(0); //
k.at(\top4pads).at(\p8); //


k.makeGroupFromLabels(\top4pads, [ \PAD5, \PAD6, \PAD7, \PAD8 ]);
k.at(\top4pads).at(0); //
k.at(\top4pads).at(\PAD8); //

// ordered dict style
k.makeGroupFromLabels(\top4pads, [
	\x -> \PAD5,
	\y-> \PAD6,
	\z -> \PAD7,
	\w -> \PAD8 ]);

k.makeGroupFromRawNames(\top4pads, [
	\x -> \pad_0_5,
	\y-> \pad_0_6,
	\z -> \pad_0_7,
	\w -> \pad_0_8 ]);


// grid as example for personalized access scheme:

k.makeGroupFromLabels(\padGrid, [
	[\PAD1, \PAD2 \PAD3, \PAD4],
	[ \PAD5, \PAD6, \PAD7, \PAD8]
], scene: 0);

k.at(\padGrid).at(0); // elArray
k.at(\padGrid).elementAt(0, 1); // element

k.makeGroup(\padGrid, [
	[\PAD1, \PAD2 \PAD3, \PAD4],
	[ \PAD5, \PAD6, \PAD7, \PAD8]
]);
