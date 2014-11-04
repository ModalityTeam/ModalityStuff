Modality project
----------------

* Explores the idea of highly modal performance instruments i.e., setups where a small set of controllers can be used to play a wide variety of sound processes by changing control constellations on the fly.
* Dedicated to modal interaction via on-the-fly remapping with synthesis processes for physical control in performance and musical practice.

Goals
-----
    
* Data acquisition from commercially available controllers (currently HID and MIDI) by providing a common software interface.
* Processing of control data streams using non-trivial event logic.
* Sending control data to these controllers (e.g., fader positions, LED states).
* Graphical feedback of the current state in the form of a GUI of connected to the device, as well as replacing a controller with a GUI substitute.
* Mapping the output of these data streams to input parameters of sound engines.


Implementation
--------------

* Individual physical controls have simple short human-readable element names, which are hierarchically ordered where applicable.
* element names, characteristics and position in hierarchy defined in a text file using simple syntax. 
* Devices automatically recognized and instantiated; accessible through auto-generated names persistent across sessions.
* Incoming values automatically converted to [0,1] range.
    
    
Data dispatching and event logic approaches:
--------------------------------------------

* MDispatch - virtual device with internal logic
* FRP - Functional Reactive Programming
* Influx - lose control, gain influence
* SenseWorld DataNetwork - easy data exchange
    
Code example:
-------------

```
k = MKtl('nnkn0');

// first slider of first page of 
// NanoKONTROL controller
~el = MKtl('nnkn0').elements[\sl][0][0];

//add action
~el.action = { |e|
  var freq = e.value.linlin(0.0,1.0,300,3000);
  x.set(\freq, freq)
};

//remove action
~el.action.action = nil
```
