include <involute_gear.scad>; // to build gears and get some gear functions
include <custom_params.scad>; // customer parameters

// parameters by design
focusringDepth = 5.5; // depth of the focus ring in mm
engrave = true;

// parameters by constraints
ffMod = 0.8; // module
looseFit = 0.3; // padding to make 3D printed parts fit loosely on real objects
bestFit = 0.2; // padding to make 3D printed parts fit perfectly on real objects
tightFit = 0.1; // padding to make 3D printed parts fit tightly on real objects
screwDiameter = 3+2*looseFit; // M3 screw
screwLength = 11; // screw shaft length
screwHeadDiameter = 10; // screw head diameter
screwHeadLength = 5; // screw head length
nutWidth = 5.4+2*tightFit; // M3 quad nut width
nutDepth = 2.5+2*tightFit; // M3 nut height
antiFit = 1; // wall-on-wall does not work in openSCAD

// calculate grip cutout parameters
focusringRadius = focusringDiameter/2;
gripPeak = sqrt(pow(tabWidth/2, 2)+pow(focusringRadius+tabHeight, 2));
gripCutoutWidth = tabWidth+min(2*bestFit, tabWidth); // min to prevent cutout by fit when width/height 0
gripCutoutHeight = tabHeight+focusringRadius+min(2*bestFit, tabHeight);

// separator slit parameters
slitWidth = 3;

// screw box parameters
screwboxStability = 2; // pad to slit
screwboxPad = 3; // minimum distance to focusring
screwboxWidth = screwLength+screwHeadLength+2*looseFit; // total length of the hexagon screw (including head)
screwboxHeight = screwHeadDiameter+2*looseFit;
screwboxOffset = slitWidth/2+screwboxStability+screwboxWidth/2; // shift in x to make use of the availably space in the gear area
screwboxPeak = sqrt(pow(screwboxWidth/2, 2)+pow(focusringRadius+screwboxHeight+screwboxPad, 2));

// gear parameters
gearStability = 5; // gap between pitch radius grip to give some stability
minPeak = max(gripPeak, screwboxPeak, wantedPitchDiameter/2-gearStability); // minimum peak, either let screwbox or grip dominate
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
engravingPlace = focusringRadius+screwboxPad; // distance from center
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
    
    // separator slit
    translate([screwboxOffset, -slitHeight/2, 0]) cube([slitWidth, slitHeight+antiFit, gearCutoutDepth], center=true);
    
    // spring
    cube([springWidth, springThickness, gearCutoutDepth], center=true);
    
    // screwbox
    translate([screwboxOffset, -(focusringRadius+screwboxPad+screwboxHeight/2), 0]) union() {
        // screwcase
        translate([-(screwboxWidth/2+screwboxStability+slitWidth/2), 0, 0]) cube([screwboxWidth, screwboxHeight, gearCutoutDepth], center=true);
        // nut slit
        translate([slitWidth/2+screwboxStability+nutDepth/2, 0, 0]) cube([nutDepth, nutWidth, gearCutoutDepth], center=true);
        // screw hole
        translate([-(slitWidth/2+screwboxStability+antiFit), 0, 0]) rotate(a=90, v=[0, 1, 0]) cylinder(d=screwDiameter, h=screwLength+slitWidth+1+antiFit, center=false, $fn=24);
    }
    
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