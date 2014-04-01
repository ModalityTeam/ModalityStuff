///// still incomplete!

//// make model first, put all the logic there


// 16 sound locations - proxies

// 3 source locations, 12 destinations, .
// each can have its own sound,
// keeps its settings,
// knows which param to set from slider

// each can be started, held, released by button

q = q ? ();

// make 16 locations
q.allSnds = 16.collect {
	NodeProxy.audio().addHalo(\isOn, false);
};

z = q.allSnds[0];
z.play;
z.source_({ PinkNoise.ar * 0.25 });
z.put(0, { PinkNoise.ar * 1 });


// take 12 destinations from them
q.dests = q.allSnds.drop(4);
// and 3 privileged sources (cant be overwritten)
q.sources = q.allSnds.keep(3);

// prepare 3 of them:

q.sources.do { |proxy, i|
	proxy.prime( {
		var snd = RLPF.ar(Pulse.ar(\freq.kr(200), 0.2), 2500, 0.3);
		var env = EnvGen.kr(Env.asr, \gate.kr(1), doneAction: 2);
		snd * env;
	});
	proxy.addHalo(\sliderParam, \freq);
};

q.sources[0].addSpec(\freq, [200, 2000, \exp]);
q.sources[1].addSpec(\freq, [60, 6000, \exp]);

/*
q.sources[0].getHalo;
*/

q.srcTrigRel = { |q, index, value|
	var proxy = q.allSnds[index];
	[\srcTrigRel, index, value].postln;
	if (value > 0) {
		proxy.send;
		q.lastSelected = proxy;
	} {
		proxy.release;
	};
	proxy.addHalo(\isOn, value > 0)
};

q.sources[0].send.play;
q.sources[0].release;

q.srcTrigRel(0, 1);
q.srcTrigRel(0, 0);
q.srcTrigRel(1, 1);
q.srcTrigRel(0, 0);
q.sources[1].play

q.sliderSet = { |q, normValue|
	q.allSnds.do { |src, i|
		var specname, spec;
		if (src.getHalo(\isOn)) {
			specname = src.getHalo(\sliderParam);
			spec = src.getSpec(specname);
			// later: better to keep lastvalue of slider around
			src.softSet(
				*[specname,
				spec.map(normValue),
					0.05].postln
			);
		};
	};
};

q.sources[0].setUni(\freq, 0.25);
q.sources[1].setUni(\freq, 0.5);
q.sliderSet(0.48);
q.sliderSet(0.3);

//
fork { (0.0, 0.01 .. 0.6).do { |n| q.sliderSet(n); 0.02.wait; }; };
fork { (0.6, 0.59 .. 0.1).do { |n| q.sliderSet(n); 0.02.wait; }; };


q.sources[0].gui;


// copy snd from one loc to another
q.copySnd = { |q, src, destIndex, mute = false|
	var dest = q.dests[destIndex];
	if (mute) {
		dest.prime(src.source);
	} {
		dest.source_(src.source);
	};
	dest.addHalo(\sliderParam, src.getHalo(\sliderParam));
	dest.addHalo(\spec, src.getSpec.copy);
};


// copy src0 to dest 0
q.copySnd(q.sources[0], 0, true);
q.srcTrigRel(3, 1);
q.dests[0].release;

// trig first dest to see it is really there
q.srcTrigRel(3, 1);
q.srcTrigRel(0, 0);

q.getActives = { q.allSnds.select { |x| x.getHalo(\isOn) == true } };
q.getActives;

q.mode = \play;
// q.mode = \copyGet;
// q.mode = \copyPut;

q.copyPlayMode = \loud; // or mute

// press shift to enter copy mode
q.enterCopyMode = {
	if (q.getActives.notEmpty) {
		q.copyPlayMode = \loud;
	} {
		q.copyPlayMode = \mute;
	};
	q.mode = \copyGet;
};

q.copyGet = { |q, index, value|
	if (value > 0) {
		q.copyPlayMode.switch(
			\loud, { q.srcTrigRel(index, value); },
			\mute, { q.lastSelected = q.allSnds[index]; }
		);
	} {
		// release in any case
		q.srcTrigRel(index, value);
		if (q.getActives.isEmpty) {
			q.mode = \copyPut;
		};
	};
};

q.copyPut = { |q, index, value|
	var proxy = q.lastSelected;
	q.copyPlayMode.switch(
		\loud, { q.copySndLoud(proxy, index); },
		\mute, { q.copySndMute(proxy, index); }
	);
	q.mode = \play;
};


// simplest copy logic
// do loud copy first, mute later

q.pressSndBut = { | sndIndex, value|
	[\pressSndBut, q.mode].postln;
	q.mode.switch(
		\play, { q.srcTrigRel(sndIndex, value) },
		\copyGet, { q.copyGet; },
		\copyPut, { q.copyPut; }
	);
};


/// varation 2 - copy multiple sources to a single destination
// smart list of proxies ...




q = q ? ();
q.mpdwin = Window("MPD18 use case (JNCv2)").front;
q.butvals = 0!4!4;

q.buts = 4.collect { |i|
	4.collect {|j|
		Button(q.mpdwin, Rect(i * 80 + 5, 240 - (j * 80) + 5, 75, 75))
		.states_([["up" + (i + 1 + (j * 4)), Color.black], ["DOWN", Color.black, Color.green]]);
	}
}.flop;

q.sl = Slider(q.mpdwin, Rect(340, 25, 40, 280));

q.sl.action = { |sl| q.sliderSet(sl.value) };
//
q.sourceButs = q.buts [0].keep(3);
q.shifter = q.buts [0][3];
q.shifter.states_([["shift", Color.black], ["SHIFT", Color.black, Color.green]]);

q.shifter.action = { |b|
	if (b.value > 0) {
		q.enterCopyMode
	} {
		q.mode = \play;
	}
} ;

// make button actions really simple
q.sourceButs.do { |but, i| but.action = { q.pressSndBut(i, but.value) } };

