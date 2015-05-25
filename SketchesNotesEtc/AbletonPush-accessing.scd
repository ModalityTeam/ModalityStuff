MIDIIn.connectAll


MIDIClient.init;
q = q ? ();

q.lifePort = MIDIOut.newByName("Ableton Push", "Live Port");
q.userPort = MIDIOut.newByName("Ableton Push", "User Port");


// 240 71 127 21 {line} 0 69 0 {ASCII char1} {ASCII char2} … {ASCII char68} 247

(
q.colWidth = 17;
q.numCols  = 4;
q.numRows  = 4;

q.displayState = (32!(68*4));

q.stringToInt8 = {|q, string|
	string.as(Array).collect(_.ascii)
};

q.pr_updateDisplayState = {|q, string, startLineNum|
	// startLineNum == (0..15)
	// follows the rows of the display
	var chars  = q.stringToInt8(string);
	var offset = q.colWidth*startLineNum;

	// write chars to approproiate places
	q.displayState =
		q.displayState[ .. (offset-1)] ++
		chars ++
		q.displayState[(offset + chars.size) .. ];
};



q.pr_updateDisplay = {|q|
	q.displayState.clump(68).do{|line, i|
		q.lifePort.sysex(
			Int8Array.newFrom([240, 71, 127, 21, 24+(i), 0, 69, 0] ++ line ++ [ 247 ]);
		)
	}
};

q.writeToColumn = {|q, num, string, clearColumn = true|
	clearColumn.if({
		string = string ++ String.newFrom(($ !q.colWidth!q.numRows).flat);
	});
	string = string.clump(q.colWidth)[..q.numRows];
	string.do{|subString, i|
		q.pr_updateDisplayState(
			subString.postln,
			((q.numRows * i) + num)
		);
	};
	q.pr_updateDisplay;

};

q.clearDisplay = {
	3.do{|i|
		q.writeToColumn(i, "");
	}
}
)

q.pr_updateDisplayState("SuperCollider SuperCollider SuperCollider", 4);
q.pr_updateDisplay;

q.clearDisplay

q.writeToColumn(1, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
q.writeToColumn(1, "WOW, this is SuperCollider!", false);
q.writeToColumn(1, "WOW, is this SuperCollider?", true);


q.writeToColumn(0, "");
q.writeToColumn(1, "");
q.writeToColumn(2, "");




(
64.do{|i|
	q.userPort.noteOn(0, 36+i, (63)+i);
//	q.userPort.noteOn(0, 36+i, 5);
//	q.userPort.noteOn(0, 36+i, (64*1)+(7*8)-1);
}
)


//  0 off
//  1 dim on
//  2 dim blink 1Hz
//  3 dim blink 2Hz
//  4 mor on           (row launch buttons red)
//  5 mor blink 1Hz    all blink
//  6 mor blink 2Hz    all blink
//  7 mor on           (row launch buttons dim orange)
//  8 orange steady    (only launch buttons blin, rest steady
//  9 orange blink 2Hz only launch buttons blin, rest steady
// 10 orange steady    (row launch buttons mor orange)
// 11 orange blink 2Hz (row launch buttons mor orange)


(
q.buttonIntensity = IdentityDictionary[
	\dim -> 0,
	\full-> 1
];

q.buttonBlink = IdentityDictionary[
	\steady -> 0,
	\slow   -> 1,
	\fast   -> 2
];


q.launchButtonColor = IdentityDictionary[
	\red    -> 0,
	\orange -> 1,
	\yellow  -> 2,
	\green  -> 3,
];
)



// * 6




  (q.launchButtonColor[\green] * 6)
+ (q.buttonIntensity  [\full]  * 3)
+ (q.buttonBlink      [\slow]) + 1

 q.buttonIntensity[\full] + q.buttonBlink[\slow]

(
q.pr_buttonLightCode = {|q, intensity = \full, blink = \steady, color = 0|
	var result;
	intensity = q.buttonIntensity[intensity] ? intensity;
	blink = q.buttonBlink[blink] ? blink;
	color = q.launchButtonColor[color] ? color;

	intensity.notNil.if({
		(color * 6)
			+ (intensity  * 3)
			+ blink
			+ 1
	}, { // off
		0
	});

}
)

q.pr_buttonLightCode(1, \fast, \green)


q.setButton = {|q, which, intensity = 1, blink = 0, color = 0|
	q.pr_buttonLightCode(q.buttonKey[which], intensity, blink, color)

}


(
q.buttons.keysValuesDo{|key, val|
	q.userPort.control(1, key, q.pr_buttonLightCode(37, \full, 2, \red).postln);
}
)


(
q.buttons.keysValuesDo{|key, val|
	q.userPort.control(1, key, 15);
}
)



String.newFrom([$a, $b])

// ----------------------------------

/////////////////////////////
0   black / off
1   dark grey
2   grey
3   white

5   red [bright]
6   red
7   red [dim]

9   orange [bright]
10  orange
11  orange [dim]

13  yellow [bright]
14  yellow
15  yellow [dim]

21  green [bright]
22  green
23  green [dim]

33  cyan [bright]
34  cyan
35  cyan [dim]

45  blue [bright]
46  blue
47  blue [dim]

49  purple [bright]
50  purple
51  purple [dim]

57  pink [bright]
58  pink
59  pink [dim]
////////////////////////////



MKtl.find

MKtl('bltn0').openDescriptionFile


(
Tdef(\player, {
	loop{
	MKtl('bltn1').elementAt(\pad).flat.do{|el|
	el.rawValue_(30.rand).prMaybeSend;
	};
		0.1.wait;
}};
).play
)



MKtl('bltn1').mktlDevice.midiOut.latency = 0;

MKtl('bltn1').elementAt(\pad).flat.do{|el| el.rawValue_(30.rand).prMaybeSend;};




MKtl('bltn1').elementAt(\colorBut, 0).flat.do{|el| el.rawValue_(MPushHelper.topRowLightCode(intensity: \full, color: \green)).prMaybeSend;};


(
2.do{|i|
	MKtl('bltn1').elementAt(\colorBut, i).flat.do{|el| el.rawValue_(MPushHelper.lightCode(intensity: \full, color: \green, row: i)).prMaybeSend;};
};
8.do{|i|
	MKtl('bltn1').elementAt(\pad, i).flat.do{|el| el.rawValue_(MPushHelper.padLightCode(intensity: \full, color: \green)).prMaybeSend;};
}
)
// ------------------------------

q = ();

q.solid = ();
q.blink = ();
q.flink = ();

q.solid.put(1, Color.red(0.5));
q.blink.put(2, Color.red(0.5));
q.flink.put(3, Color.red(0.5));
q.solid.put(4, Color.red(1));
q.solid.put(5, Color.red(1));
q.solid.put(6, Color.red(1));

q.solid.put(6, Color.red(1));

// --------------------------

MKtl('bltn1').elementAt(\colorBut).action = {|el|
	(el.value > 0).if({
		el.rawValue_(4).prMaybeSend;
	}, {
		el.rawValue_(0).prMaybeSend;
	})
}



MKtl('bltn1').elementAt(\pad).action = {|el|
	(el.value < 0.0001).if({
		el.rawValue_(0).prMaybeSend;
	}, {
		(el.value < 0.5).if({
			el.rawValue_(7).prMaybeSend;
		}, {
			(el.value < 0.7).if({
				el.rawValue_(6).prMaybeSend;
			}, {
				el.rawValue_(5).prMaybeSend;
			})
		});
	});
}





MKtl('bltn1').elementsOfType(\button).do{|el| el.action = {|el| el.rawValue_(127).prMaybeSend;}};

MIDIEndPoint

inspect

.latency

MIDIOut.latency

MKtl('bltn1').elementAt(\pad).flat.do{|el|
	el.rawValue_(0).prMaybeSend;
};


a = MKtl('bltn0').elementAt(\pad).flat.first

a.source


MKtlElement

//////////////////////////////////////

MKtl('bltn1').trace(false)


MKtl('bltn1').elementAt(\pad).flat.do{|el|
	el.value_(1.0.rand)
}






MKtl('bltn1').elementAt(\pad, 3, 1).action = {|el| el.value.postln}
MKtl('bltn0').elementAt(\pad, 3, 1).rawValue_(3).prMaybeSend
MKtl('bltn0').elementAt(\pad, 3, 1).rawValue_(60).prMaybeSend






MKtl('bltn1').elementAt(\play).rawValue_(0).prMaybeSend // off
MKtl('bltn1').elementAt(\play).rawValue_(1).prMaybeSend // dim
MKtl('bltn1').elementAt(\play).rawValue_(2).prMaybeSend // dim slow blink
MKtl('bltn1').elementAt(\play).rawValue_(3).prMaybeSend // dim fast blink
MKtl('bltn1').elementAt(\play).rawValue_(4).prMaybeSend // bright
MKtl('bltn1').elementAt(\play).rawValue_(5).prMaybeSend // bright slow blink
MKtl('bltn1').elementAt(\play).rawValue_(6).prMaybeSend // bright fast blink


MKtl('bltn1').elementAt(\pad, 3, 1).rawValue_(3).prMaybeSend


MKtl('bltn1').elementAt(\play).value = 1
MKtl('bltn1').elementAt(\play).value = 0


MKtlElement


MKtl('bltn1').elements.keys

, 3, 1).value


MKtl('bltn1').openDescriptionFile


/////////////////////////////
0   black / off
1   dark grey
2   grey
3   white

5   red [bright]
6   red
7   red [dim]

9   orange [bright]
10  orange
11  orange [dim]

13  yellow [bright]
14  yellow
15  yellow [dim]

21  green [bright]
22  green
23  green [dim]

33  cyan [bright]
34  cyan
35  cyan [dim]

45  blue [bright]
46  blue
47  blue [dim]

49  purple [bright]
50  purple
51  purple [dim]

57  pink [bright]
58  pink
59  pink [dim]
////////////////////////////