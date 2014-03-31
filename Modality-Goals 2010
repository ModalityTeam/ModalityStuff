Document.current.font_(Font("Verdana",12)); Document.current.setTextColor(Color.black); 
Document.current.bounds_(Rect(50, 800, 800, 700)); /*

	
proposed program flow

	control input
	
		midi: cc, note, sysex, aftertouch, program
		hid
		arduino
		computer keyboard
		OSCresponders
		bowsense
		others?
		
	basic conditioning
	
	analysis modules - derived data
		assigned a signal as a source
		output as a new 'control input'
		
		ex
			analyze sensor data for directions changes to emmit a trigger
			convert trigger messages to on/off messages
			convert on/off messages to trigger
			onset detection of audio to derive on/off or trigger messages
		
	input to dispatcher
		makes control data available lang side
		modally sends data to required places on server (respirator)
		collects input messages
		determines when enough input is available emmit widget control messages
		network
			widget control messages
			control and derived data
		
	data / messages output
		lang side
		server busses
		network
	
	
	widgets invoked

		sound production details; 
			single or numerous synth events managed with simple commands				start stop pause resume

		managing controllers
			send sysex
			send midi (launchpad)
			program changes?
			
	music?





GUIs and editors for many things:

	server configuration editor
		memory
		file output specifications
		enabled in/out
		numWireBufs
		etc
		
	output speaker array configuration editor
		dynamically refactoring  elements of the instruments
			buss allocations per 'channel' (a synth with four outputs would need a 4 buss channel)
			number of enabled audio busses
			the panner/spatialization synthdef used in the mixer channels
		subs - aggregation of relavent channels for output to subs

	Buffer management editor
		named buffers
		set duration and number of channels
			allocation derived from server settings and input
		save buffer contents with instrument as needed
		recal samples as part of instrument preset

	mapping editors
		associate input to named filter
		named filter editor
		widget editor
		synthdef and preset editor	
		

special needs

	recording support
		record multichannel output
		record multitrack style
			each voice to own track
	
	instruments should work in the absence of required controllers
		gui version of physical hardware
		some kind of audio replacement for instruments requiring audio input

	settings files
		a whole instrument config spans many files?	
		different types of settings save in different files?
		users can exchange conguration files?
		


overal goal
	develop instrument from scrath via interfaces
	edit existing instruments via interfaces
	build and execute instruments from saved configurations
	
	
*/
