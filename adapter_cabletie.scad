include <involute_gear.scad>; // to build gears and get some gear functions
include <custom_params.scad>; // customer parameters

// parameters by design
focusringDepth = 5.5; // depth of the focus ring in mm
engrave = true;

// parameters by constraints
ffMod = 0.8; // module
looseFit = 0.3; // padding to make 3D printed parts fit loosely on real objects
bestFit = 0.2; // padding to make 3D printed parts fit perfectly on real objects
antiFit = 1; // wall-on-wall does not work in openSCAD

// calculate grip cutout parameters
focusringRadius = focusringDiameter/2;
gripPeak = sqrt(pow(tabWidth/2, 2)+pow(focusringRadius+tabHeight, 2));
gripCutoutWidth = tabWidth+min(2*bestFit, tabWidth); // min to prevent cutout by fit when width/height 0
gripCutoutHeight = tabHeight+focusringRadius+min(2*bestFit, tabHeight);

// separator slit parameters
slitWidth = 3;

// cable tie slit parameters
cabletiePad = 1; // distance to focusring at separator slit center
cabletieDist = 10; // cable tie distance to separator slit
cabletieWidth = 1.5+2*looseFit;
cabletieHeight = 4.5+2*looseFit;
cabletieBoxWidth = focusringDepth/2+cabletieWidth;
cabletiePeak = sqrt(pow(cabletieDist, 2)+pow(focusringRadius+cabletieHeight+cabletiePad, 2));

// gear parameters
gearStability = 3; // gap between pitch radius grip to give some stability
minPeak = max(gripPeak, cabletiePeak, wantedPitchDiameter/2-gearStability); // minimum peak, either let cabletie or grip dominate
minPitchRadius = minPeak+gearStability; // minimum pitch radius
// calculate number of teeth for a wanted pitch radius
widthTooth = modToPitch(ffMod); // get circular pitch
numTeeth = ceil(2*pi*minPitchRadius/widthTooth); // round up tooths
// print informations
outerDiameter = 2*outerRadius(widthTooth, numTeeth);
pitchDiameter = 2*pitchRadius(widthTooth, numTeeth);
echo("Gear properties:");
echo("teeth = ", numTeeth);
echo("pitch-diameter = ", pitchDiameter);
echo("outer-diameter = ", outerDiameter);
// depth to cutout from gear
gearCutoutDepth = focusringDepth+antiFit;

// further slit parameters
slitHeight = outerDiameter/2;

// spring cutout parameters
springThickness = 3;
springWidth = 2*sqrt(pow(minPeak, 2)-pow(springThickness/2, 2));

// engraving parameters
engravingTextR1 = str("T", numTeeth);
engravingTextR2 = str("D", focusringDiameter);
engravingFont = "Liberation Mono";
engravingSize = 4.5;
engravingDepth = 0.5;
engravingPlace = focusringRadius+cabletiePad; // distance from center
engravingPad = slitWidth/2+1; // to move text from slit away

// build adapter
difference() {
    // gear
    gear(
        pitch=widthTooth, 
        teeth=numTeeth, 
        thickness=focusringDepth, 
        holeDiameter=focusringDiameter+bestFit*2);
    
    // grip cutout
    translate([0, gripCutoutHeight/2, 0]) cube([gripCutoutWidth, gripCutoutHeight, gearCutoutDepth], center=true);

    // cable tie slits
    for (i = [0:1]) {
		rotate(a=i*180, v=[0, 1, 0]) {
            translate([-(cabletieDist-cabletieBoxWidth/2), -(focusringRadius+cabletieHeight/2+cabletiePad), 0]) {
                difference() {
                    // slit
                    cube([cabletieBoxWidth, cabletieHeight, focusringDepth+antiFit], center=true);
                    // rounding
                    translate([cabletieBoxWidth/2, 0, 0]) rotate(a=90, v=[1, 0, 0]) cylinder(h=cabletieHeight, d=focusringDepth+0.1, center=true, $fn=24);
                }
            }
        }
    }
    
    // separator slit
    translate([0, -slitHeight/2, 0]) cube([slitWidth, slitHeight+antiFit, gearCutoutDepth], center=true);
    
    // spring
    cube([springWidth, springThickness, gearCutoutDepth], center=true);

    if (engrave) {
        // generated text
        rotate(a=-90, v=[0, 0, 1]) translate([0, -engravingPlace, focusringDepth/2-engravingDepth]) rotate(a=180, v=[0, 0, 1]) linear_extrude(height=engravingDepth+antiFit) {
            // left bottom
            translate([-(slitWidth/2+1), 0, 0]) text(text=engravingTextR1, font=engravingFont, size=engravingSize, halign="right", valign="bottom");
            // right bottom
            translate([slitWidth/2+1, 0, 0]) text(text=engravingTextR2, font=engravingFont, size=engravingSize, halign="left", valign="bottom");
        }
    
        // custom text
        rotate(a=90, v=[0, 0, 1]) translate([0, -engravingPlace, focusringDepth/2-engravingDepth]) rotate(a=180, v=[0, 0, 1]) linear_extrude(height=engravingDepth+antiFit) {
            // left bottom
            translate([-(slitWidth/2+1), 0, 0]) text(text=engravingTextL1, font=engravingFont, size=engravingSize, halign="right", valign="bottom");
            // right bottom
            translate([slitWidth/2+1, 0, 0]) text(text=engravingTextL2, font=engravingFont, size=engravingSize, halign="left", valign="bottom");
        }
    }
}