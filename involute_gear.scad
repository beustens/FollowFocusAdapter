///////////////////////////////////////////////////////////////////////////////////////////////////
//  Involute gear
//  Based on:
//  Public Domain Parametric Involute Spur Gear (and involute helical gear and involute rack)
//  version 1.1
//  by Leemon Baird, 2011, Leemon@Leemon.com
//  http:// www.thingiverse.com/thing:5505
///////////////////////////////////////////////////////////////////////////////////////////////////

module gear (
	pitch = 3, // this is the "circular pitch", the circumference of the pitch circle divided by the number of teeth
	teeth = 11, // total number of teeth around the entire perimeter
	thickness = 6, // thickness of gear in mm
	holeDiameter = 3, // diameter of the hole in the center, in mm
	twist = 0, // teeth rotate this many degrees from bottom of gear to top.  360 makes the gear a screw with each thread going around once
	teethHide = 0, // number of teeth to delete to make this only a fraction of a circle
	pressureAngle = 20, // Controls how straight or bulged the tooth sides are. In degrees.
	clearance = 0.0, // gap between top of a tooth on one gear and bottom of valley on a meshing gear (in millimeters)
	backlash = 0.0 // gap between two meshing teeth, in the direction along the circumference of the pitch circle
) {
	p = pitchRadius(pitch, teeth); // radius of pitch circle
	c = p + pitch / pi - clearance; // radius of outer circle
	b = p*cos(pressureAngle); // radius of base circle
	r = p-(c-p)-clearance; // radius of root circle
	t = pitch/2-backlash/2; // tooth thickness at pitch circle
	k = -iang(b, p) - t/2/p/pi*180; // angle to where involute meets base circle on each side of tooth
	difference() {
		union() {
			for (i = [0:teeth-teethHide-1]) {
				rotate([0,0,i*360/teeth]) {
					linear_extrude(height=thickness, center=true, convexity=10, twist=twist) {
						polygon(
							points=[
								[0, -holeDiameter/10],
								polar(r, -181/teeth),
								polar(r, r<b ? k : -180/teeth),
								q7(0/5,r,b,c,k, 1),q7(1/5,r,b,c,k, 1),q7(2/5,r,b,c,k, 1),q7(3/5,r,b,c,k, 1),q7(4/5,r,b,c,k, 1),q7(5/5,r,b,c,k, 1),
								q7(5/5,r,b,c,k,-1),q7(4/5,r,b,c,k,-1),q7(3/5,r,b,c,k,-1),q7(2/5,r,b,c,k,-1),q7(1/5,r,b,c,k,-1),q7(0/5,r,b,c,k,-1),
								polar(r, r<b ? -k : 180/teeth),
								polar(r, 181/teeth)
							],
 							paths=[[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]]
						);
					}
				}
			}
		};
		cylinder(h=2*thickness+1, r=holeDiameter/2, center=true, $fn=64);
	}
};
// constants
pi = 3.1415926;

// functions used by gear
function polar(r, theta) = r*[sin(theta), cos(theta)]; // convert polar to cartesian coordinates
function iang(r1, r2) = sqrt((r2/r1)*(r2/r1) - 1)/pi*180 - acos(r1/r2); // unwind a string this many degrees to go from radius r1 to radius r2
function q7(f, r, b, r2, t, s) = q6(b, s, t, (1-f)*max(b, r)+f*r2); // radius a fraction f up the curved side of the tooth 
function q6(b, s, t, d) = polar(d, s*(iang(b, d)+t)); // point at radius d on the involute curve

// These functions let the user find the derived dimensions of the gear.
// A gear fits within a circle of radius outerRadius, and two gears should have
// their centers separated by the sum of their pictch_radius.
function modToPitch (mod) = mod * pi; // circular pitch based on module
function pitchRadius (pitch, teeth) = pitch * teeth / pi / 2;
function outerRadius (pitch, teeth, clearance=0.0) // The gear fits entirely within a cylinder of this radius.
	= pitch*(1+teeth/2)/pi  - clearance;