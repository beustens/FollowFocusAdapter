include <involute_gear.scad>; // to build gears and get some gear functions

// parameters by standard
ffMod = 0.8; // module

depth = 10;
numTeeth = 30;
// print informations
pitchDiameter = numTeeth*ffMod;
outerDiameter = pitchDiameter+2*ffMod;
echo("Gear properties:");
echo("teeth = ", numTeeth);
echo("pitch-diameter = ", pitchDiameter);
echo("outer-diameter = ", outerDiameter);

// build gear
gear(
    pitch=modToPitch(ffMod), 
    teeth=numTeeth, 
    thickness=depth, 
    holeDiameter=5);