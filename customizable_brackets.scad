/*
* Ultimate Customizable Corner Brackets
* https://www.thingiverse.com/thing:3007147
* By Daniel Hultgren https://www.thingiverse.com/Hultis
* Version 1.3
* 2020-05-07
*/

/* [Basic settings] */

// The width of your aluminium extrusion.
extrusion_width = 20;
// The side length of the bracket.
side_length = 30;
// The thickness of the wall facing the extrusion.
side_thickness = 4;
// How many screw holes are are on the top side.
top_screw_count = 1;
// How many screw holes are are on the bottom side.
bottom_screw_count = 1;
// Screw diameter (4 for M4, 5 for M5 and so on).
screw_hole_size = 5;
// Screw head diameter.
screw_head_size = 10;


/* [Advanced settings] */

// How deep screw heads should be recessed. Obviously don't make this larger than side_thickness.
recessed_screw_depth = 0;
// How much to elongate the holes on top.
top_screw_elongation = 0;
// How much to elongate the holes on bottom.
bottom_screw_elongation = 0;
// The part which goes into your extrusion. Generally this should be slightly smaller than the actual hole, but YMMV.
extrusion_insert_width = 6;
// Use this when you want multiple connected brackets, for 4020 and similar. 20 for 2020 extrusions, 30 for 3030 and so on.
extrusion_base = 20;
// Set how many walls you want. One wall doesn't play well with multiple bracket mode.
wall_count = 0; // [0 : 1 : 2]
// Set lower if you think the side walls are too thick.
max_wall_thickness = 8;
// Set this if you want to use these above your existing brackets. Typical 2020 brackets have a size of 20 and side thickness of 3.
cutout_size = 0;
cutout_side_thickness = 3;
// Decrease this if you don't want extrusion inserts on both sides. Intended for using these entirely or partially on non-extrusions.
extrusion_insert_count = 2; // [0 : 1 : 2]
// Set this to control how much space the nuts have. Hammer nuts should just work but for t nuts you will need to set a specific width.
specific_bottom_nut_space = 0;
// Bracket angle
bracket_angle = 90; // [90 : 1 : 180]





/**********************************
   End of config, here be dragons
**********************************/





/* [Hidden] */
// preview[view:north east, tilt:top diagonal]

// You might want to decrease this if you don't use hammer nuts
extrusion_insert_height = 3;

cutout_margin = 0.3;
screw_head_margin = 0.5;
e = 0.05;
top_screw_distance = screw_distance_from_edge(top_screw_count, top_screw_elongation);
bottom_screw_distance = screw_distance_from_edge(bottom_screw_count, bottom_screw_elongation);
screw_distance_from_edge = max(top_screw_distance, bottom_screw_distance);

echo(bridge(top_screw_count, screw_head_size+top_screw_elongation, top_screw_distance));
echo(bridge(bottom_screw_count, screw_head_size+bottom_screw_elongation, bottom_screw_distance));
bridge_size = min(
    bridge(top_screw_count, screw_head_size+top_screw_elongation, top_screw_distance),
    bridge(bottom_screw_count, screw_head_size+bottom_screw_elongation, bottom_screw_distance));

main();

module main() {
    bracket_count = round(extrusion_width / extrusion_base);
    extrusion_width = extrusion_width/bracket_count;
    wall_thickness = min([max_wall_thickness, (extrusion_width - screw_head_size - screw_head_margin) / 2]);
    union() {
        for(i=[0:bracket_count-1]) {
            translate([i*extrusion_width, 0, 0]) bracket(extrusion_width, wall_thickness);
        }
    }
}

module bracket(width, wall_thickness, is_first) {
    difference() {
        union() {
            translate([-width/2, 0, 0]) cube([width, side_length, side_thickness]); // Bottom wall
            rotate([bracket_angle-90,0,0]) {
                translate([-width/2, side_thickness, 0]) rotate([90, 0, 0]) cube([width, side_length, side_thickness]); // Top wall
            }
            if (wall_count >= 1) {
                translate([width/2 - wall_thickness, 0, 0]) rotate([90, 0, 90]) wall(width, side_length, wall_thickness); // Left wall
            }
            if (wall_count >= 2) {
                translate([-width/2, 0, 0]) rotate([90, 0, 90]) wall(width, side_length, wall_thickness); // Right wall
            }
            
            // Make the parts which go into the extrusions, with chamfers
            if (extrusion_insert_count > 0) difference() {
                union() {
                    if (extrusion_insert_count > 0) {
                        translate([0, 0, 0]) rotate([90, 0, 180]) extrusion_insert();
                    }
                    if (extrusion_insert_count > 1) {
                        rotate([bracket_angle-90,0,0]) extrusion_insert();
                        extrusion_insert_corner();
                    }
                    
                }
                // Make chamfers
                rotate([bracket_angle-90,0,0]) extrusion_chamfer();
                translate([0, 0, 0]) rotate([90, 0, 180]) extrusion_chamfer();
            }
            bridge(bridge_size, width, wall_thickness);
        };

        // Cutoff for easier printing
        cutoff_amount = 0.5*(180-bracket_angle)/90 * side_thickness;
        angle = (180-bracket_angle)/2;
        magic_height_number = 42;
        translate([0, side_length+e, side_thickness-cutoff_amount])
            rotate([90-angle, 0, 0])
            linear_extrude(height=(side_length+e)*2, convexity=2)
            polygon(points = [
                [width/2+e, 0],
                [-width/2-e, 0],
                [-width/2-e, magic_height_number],
                [width/2+e, magic_height_number]
            ]);
        
        // Make screw holes
        side_screw_holes(bottom_screw_count, bottom_screw_distance, bottom_screw_elongation); // Bottom screws
        rotate([bracket_angle-90,0,0]) {
            rotate([270, 180, 0]) side_screw_holes(top_screw_count, top_screw_distance, top_screw_elongation); // Top screws
        }
        cutout();
    }
}

module side_screw_holes(screw_count, screw_distance_from_edge, screw_elongation, screw_distance) {
    screw_total_distance = side_length - screw_distance_from_edge - bridge_size - side_thickness - screw_head_size/2 - screw_head_margin - screw_elongation/2;
    screw_distance = screw_total_distance/(max(1, screw_count-1));
    for(i=[0:screw_count-1]) {
        translate([0, side_length - screw_distance_from_edge - i*screw_distance, -e]) screw(screw_hole_size, screw_head_size, screw_elongation);
    }
}

module cutout() {
    zero = -e-extrusion_insert_height;
    full_width = cutout_size+cutout_margin;
    if (cutout_size > 0) translate([extrusion_width/2+e, 0, 0]) rotate([0, -90, 0]) linear_extrude(height = extrusion_width+2*e, convexity = 2) polygon(points = [
        [zero, zero],
        [zero, full_width],
        [cutout_side_thickness+cutout_margin, full_width],
        [full_width, cutout_side_thickness+cutout_margin],
        [full_width, zero]]);
}

module wall(w, l, wall_thickness) {
    linear_extrude(height = wall_thickness, convexity = 2)
        polygon(points = [[side_thickness*tan((180-bracket_angle)/2), side_thickness],
                          [side_length, side_thickness],
                          [-side_length*sin(bracket_angle-90)+side_thickness*cos(bracket_angle-90), side_length*cos(bracket_angle-90)+side_thickness*sin(bracket_angle-90)]]);
    }

module screw(hole_size, head_size, screw_elongation = 0) {
    if (screw_elongation > 0) {
        translate([0,screw_elongation/2,-0.5]) cylinder(h = side_thickness + 1, r = hole_size / 2 + 0.4, $fn = 32); // Screw hole
        translate([-hole_size/2-0.4,-screw_elongation/2,-0.5]) cube([hole_size + 0.8, screw_elongation, side_thickness + 1]); // Hole mid part
        translate([0,-screw_elongation/2,-0.5]) cylinder(h = side_thickness + 1, r = hole_size / 2 + 0.4, $fn = 32); // Screw hole
    } else {
        translate([0,0,-0.5]) cylinder(h = side_thickness + 1, r = hole_size / 2 + 0.4, $fn = 32); // Screw hole
    }
    if(recessed_screw_depth > 0) {
        assert(screw_elongation == 0, "Can't use recessed screws with elongated screws");
        translate([0, 0, side_thickness - recessed_screw_depth]) cylinder(h = recessed_screw_depth+1, r = (head_size + screw_head_margin)/2, $fn = 32);
    }
    bottom_nut_space = specific_bottom_nut_space > 0
        ? specific_bottom_nut_space
        : max(screw_hole_size*2+1, screw_hole_size+screw_elongation+1); // This works for typical hammer nuts
    translate([-extrusion_insert_width/2-e, -bottom_nut_space/2, -extrusion_insert_height-e]) cube([extrusion_insert_width + 2*e, bottom_nut_space,extrusion_insert_height+2*e]); // Remove extrusion insert below screw
    #translate([0, 0, side_thickness+2*e]) cylinder(h = 3, r = head_size / 2, $fn = 32); // Screw head, to make sure they don't hit each other
}

module bridge(size, width, wall_thickness) {
    right = width - 2*wall_thickness + 2;
    c = screw_head_size / 3;
    top = size + c;
    x = width/2-wall_thickness-c;
    union() {
        translate([width/2 - e, 0, 0])
            rotate([0, 270, 0])
            linear_extrude(height = width - 2*e, convexity = 2)
             polygon([[side_thickness, side_thickness*tan((180-bracket_angle)/2)],
                       [size*cos(bracket_angle-90)+side_thickness*sin(bracket_angle-90), -(size)*sin(bracket_angle-90)+side_thickness*cos(bracket_angle-90)], 
                       [side_thickness, side_thickness + size]]); // Main bridge
        if (wall_count >= 1) {
            translate([width/2-wall_thickness-c, 0, 0]) bridge_side(size, [[0, 0], [c, 0], [c, c]]); // Left
        }
        if (wall_count >= 2) {
            translate([-width/2+wall_thickness, 0, 0]) bridge_side(size, [[0, 0], [c, 0], [0, c]]); // Right
        }
    }
}

module bridge_side(size, polygon_points){
    hull() {
        translate([0, size+side_thickness, side_thickness]) linear_extrude(height = e, convexity = 2) polygon(points = polygon_points);
        translate([0, -(size)*sin(bracket_angle-90)+side_thickness*cos(bracket_angle-90), size*cos(bracket_angle-90)+side_thickness*sin(bracket_angle-90)]) 
            rotate([bracket_angle,0,0])
                linear_extrude(height = e, convexity = 2)
                    polygon(points = polygon_points);
    }
}

module extrusion_insert() {
    translate([-extrusion_insert_width/2, -extrusion_insert_height, 0]) cube([extrusion_insert_width, extrusion_insert_height, side_length]);
}

module extrusion_chamfer(height = .5) {
    x = extrusion_insert_width;
    z = side_length + extrusion_insert_height;
    length = sqrt(height * height * 2);
    translate([-extrusion_insert_width/2, -extrusion_insert_height, -extrusion_insert_height]) union() {
        translate([0, -height, -e]) rotate([0, 0, 45]) cube([length, length, z+2*e]);
        translate([x, -height, -e]) rotate([0, 0, 45]) cube([length, length, z+2*e]);
    }
}
module extrusion_insert_corner() {
    translate([extrusion_insert_width/2,0,-extrusion_insert_height])
        rotate([90,0,-90])
        linear_extrude(extrusion_insert_width, center = false, convexity = 10, twist = 0)
            polygon(points=[[0,0],
                           [0,extrusion_insert_height],
                           [extrusion_insert_height*cos(bracket_angle-90),(extrusion_insert_height-extrusion_insert_height*sin(bracket_angle-90))],
                           [extrusion_insert_height*tan((180-bracket_angle)/2),0]]);
    }

function screw_distance_from_edge(screw_count, screw_elongation) =
    screw_count > 1
        ? max(screw_head_size/2 + screw_elongation/2, min(6.5, side_length/3)) + screw_head_margin/2
        : max((side_length-side_thickness)/2.5, screw_hole_size+screw_elongation/2);

function bridge(screw_count, total_screw_size, screw_distance_from_edge) =
    screw_count > 1
        ? min((side_length - side_thickness - 2*total_screw_size + cutout_size + cutout_margin) / (side_length/20),
            max(side_length - side_thickness - total_screw_size*screw_count, 0))
        : side_length - screw_distance_from_edge - total_screw_size / 2 - side_thickness - screw_head_margin;

