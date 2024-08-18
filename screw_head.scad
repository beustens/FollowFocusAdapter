// constraints
looseFit = 0.3; // padding to make 3D printed parts fit loosely on real objects
tightFit = 0.1; // padding to make 3D printed parts fit tightly on real objects
antiFit = 1; // wall-on-wall does not work in openSCAD
screwDiameter = 3+2*tightFit; // M3 screw
nutWidth = 5.5+2*tightFit; // M3 hex nut short width

// design parameters
headDiameter = 10;
headHeight = 5;
paddingBottom = 1;

// dent parameters
dents = 12;
dentDiameter = 1.5;
dentRadius = headDiameter/2+0.5*dentDiameter/2;

// build head
difference() {
    // base
    cylinder(d=headDiameter, h=headHeight, $fn=96);
    
    // cutout hex nut
    translate([0, 0, paddingBottom]) cylinder(d=nutWidth/sqrt(3)*2, h=headHeight, $fn=6);
    
    // cutout screw hole
    translate([0, 0, -antiFit]) cylinder(d=screwDiameter, h=paddingBottom+2*antiFit, $fn=24);
    
    // cutout dents
    for (i = [1:dents]) {
       rotate([0, 0, i*(360/dents)]) translate([dentRadius, 0, -antiFit]) cylinder(d=dentDiameter, h=headHeight+2*antiFit, $fn=24);
    }
}