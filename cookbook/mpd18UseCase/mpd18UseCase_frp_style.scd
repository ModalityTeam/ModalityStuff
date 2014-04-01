

(
q = ();

q.n = 15;

q.sources = [
	{
		var snd = RLPF.ar(Pulse.ar(\freq.kr(200), 0.2), 2500, 0.8) * 0.3;
		var env = EnvGen.kr(Env.asr, \gate.kr(1), doneAction: 2);
		Out.ar(0, snd * env);
	},
	{
		var snd = SinOsc.ar(\freq.kr(200)) * 0.3;
		var env = EnvGen.kr(Env.asr, \gate.kr(1), doneAction: 2);
		Out.ar(0, snd * env);
	},
	{
		var snd = Saw.ar(\freq.kr(200)) * 0.3;
		var env = EnvGen.kr(Env.asr, \gate.kr(1), doneAction: 2);
		Out.ar(0, snd * env);
	}
];

q.names = [\def1, \def2, \def3];

[q.sources, q.names].flopWith{ |func, name|
	SynthDef(name, func).add
};

q.synths = 15.collect{ [] };

//GUIS
q.mpdwin = Window("MPD18 use case (JNCv2)").front;
q.butvals = 0!4!4;

q.buts = 4.collect { |i|
	4.collect {|j|
		Button(q.mpdwin, Rect(i * 80 + 5, 240 - (j * 80) + 5, 75, 75))
		.states_([["up" + (i + 1 + (j * 4)), Color.black], ["DOWN", Color.black, Color.green]]);
	}
}.flop;

q.playButs = q.buts[0][..2];
q.memButs = q.buts[1..].flatten;

q.sl = Slider(q.mpdwin, Rect(340, 25, 40, 280));

q.shifter = q.buts [0][3];
q.shifter.states_([["shift", Color.black], ["SHIFT", Color.black, Color.green]]);

CmdPeriod.add{ q.mpdwin !? _.close };

q[\startSynths] = { |i| { |freqs, sources, play|
	IO{
		q.synths[i] = [sources[i], freqs[i]].flopWith{ |j, freq|
			Synth(q.names[j], [\freq, freq.linlin(0.0,1.0,300,2000)])
		};
	}
} };

q[\stopSynths] = { |i| {
	IO{ q.synths[i].do(_.release); q.synths[i] = [] }
}};

q[\setFreq] = { |i| { |freqs|
	IO{ [q.synths[i], freqs].flopWith{ |s,v| s.set(\freq,v.linlin(0.0,1.0,300,2000)) } }
}};

//FRP
EventNetwork(ENDef({

	//
	var all = q.buts.flat;
	var allButtonsESs = (all[0..2]++all[4..]).collect( _.enInES );
	var shiftES = q.shifter.enInES.collect(_.booleanValue); //mimics just press start
	var shiftSig = shiftES.hold(false);
	var playButsESs = allButtonsESs[..2];
	var memButsESs = allButtonsESs[3..];

	//                            T(\pickUp,aFloat) or T(\normal,aFloat)
	//  copyDescs :: EventStream ([T(Symbol,Float)] -> [T(Symbol,Float)])
	var copyDescs =
	//merge all button pressing events gated with shift
	//state is T([],Option Int)
	(shiftSig.when(
		(playButsESs.collect({ |es,i| es.select(_==1).collect{
			{|state|
				//already made assignment so clean state
				if(state.at2.isDefined) {
					T([i],None())
				}
				//collecting things to assign
				{
					if(state.at1.includes(i).not){
						T(state.at1++[i],None())
					}{
						state
					}
				}
		} } }) ++
		memButsESs.collect({ |es,i| es.select(_==1).collect{
			{|state|
				if(state.at2.isDefined) {
					state
				} {
					T(state.at1, Some(i+3) )
				}
	} } })).mreduce )
	| shiftES.collect{ { T([],None()) } })
	//run a statefull function on those events
	.injectF( T([],None()) )
	//.enDebug("state")
	//extract copyDescription
	//only let through when we have pushed two buttons in sequence
	.select{ |tup| tup.at2.isDefined };
	//.enDebug("swap");
	//copying the settings causes pickup mode


	var copyFreqs = copyDescs.collect{ |tup|
		{|state| state[tup.at2.get] = T(\pickup, state[tup.at1].collect(_.at2)); state }
	};


	//  buttonsAsArraySig :: FPSignal [Boolean]
	var buttonsAsArraySig = allButtonsESs.flat.collect{ |es|
		es.collect(_.booleanValue).hold(false)
	} // :: [ FPSignal Boolean ]
	.sequence; // :: FPSignal [Boolean]knobsArray

	//  sliderES :: EventStream Float
	var sliderES = q.sl.enInES;
	//  sliderSig :: FPSignal Float
	var sliderSig = sliderES.hold(0);

	var playButsArraySig = allButtonsESs.collect{ |es|
		es.collect(_.booleanValue).hold(false)
	} // :: [ FPSignal Boolean ]
	.sequence; // :: FPSignal [Boolean]knobsArray
	/*
	slider should only affect current playing synths
	buttonsAsArrayES contains an array of booleans determining which synths are playing
	we only store the slider value for those that are playing
	*/
	//                            T(\pickUp,aFloat) or T(\normal,aFloat)
	//  sliderForPlayingSynths :: EventStream ([T(Symbol,Float)] -> [T(symbol,Float)])
	var sliderForPlayingSynths = { |plays, sliderVal|
		 { |freqs|
			[freqs, plays].flopWith{ |freq, bool|
				if(bool){
					if(freq.at2.size > 1) {
						T(\normal, [sliderVal])
					} {
						if(freq.at1 == \normal) { T(\normal,[sliderVal]) } {
							//pick up mode, have to check if value is close enough
							if( (freq.at2[0] - sliderVal).abs < 0.1 ){
								T(\normal, [sliderVal])
							} {
								freq
							}
						}
					}
				}{freq}
			}
		}
	} <%> playButsArraySig <@> sliderES;

	var playButtonsFilterShift = allButtonsESs.collect{ |es|
		//buttons only start or stop synths if shift is off
		when( shiftSig.collect(_.not), es);
	};

	var stopCausesPickupMode = (playButtonsFilterShift.collect{ |es, i|
		es.select(_==0).collect{ { |state| state[i] = T(\pickup, state[i].at2.asCollection ); state } }
	}).mreduce;
	/*
	There are only 2 things that can cause a change in the frequency of a synth:
	a) slider changes
	b) freq copied from other synth
	we assign a function to each event, merge them
	and feed them to statefull computation
	stopping a synth causes it's freq value to go into pickup mode

	freqs is where the current value of the frequencies is kept
	*/
	//  freqs :: EventStream [Float]
	var freqsPlay = ( copyFreqs | sliderForPlayingSynths | stopCausesPickupMode )
	.injectF( q.n.collect{ T(\normal,[0.0]) } )
	.collect{ |xs| xs.collect(_.at2) };
	//.enDebug("freqs");

	//  freqSigs :: FPSignal [Float]
	var freqsPlaySig = freqsPlay.hold(q.n.collect{ [0.0] });
	//.enDebug("freqsSig");

	/*
	we split the array containing all freqs into separate streams for each synth
	we only output values if the freq actually changed
	q[\setFreq] returns the actual IO to be performed
	*/
	// freqsArray :: [ EventStream Float ]
	var freqsPlayArray = q.n.collect{ |i|
		freqsPlay //::EventStream [Float]
		.collect(_[i]) //::EventStream Float
		.onlyChanges
	};

	var sources = copyDescs.collect{ |tup|
		{ |state| state[tup.at2.get] = tup.at1; state }
	}.injectFSig( (0..14).collect({ |x| [x.mod(3)] }) );
	//.enDebug("sources"); // [ EventStream [Int] ]

	freqsPlayArray.collect{ |es, i|
		es
		.collect( q[\setFreq].(i) ) //:: EventStream IO ()
		//.enDebug("freq "++i)
		.enOut;
	};

	playButtonsFilterShift.collect{ |es,i|
		/* when we start synths we need to use the current value of the freq
		for that synth which is stored in freqsSig
		<@> samples the value of freqsSig on an incoming button event
		*/
		( q[\startSynths].(i) <%> freqsPlaySig <*> sources <@> es.select(_ == 1) ) //:: EventStream IO ()
		//.enDebug("start "++i)
		.enOut;
		es.select(_ == 0).collect(q[\stopSynths].(i)) //:: EventStream IO ()
		//.enDebug("stop "+i)
		.enOut;
	};

}),true ).start
)

q.synths
