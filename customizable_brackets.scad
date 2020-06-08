/*
* Ultimate Customizable Corner Brackets
* https://www.thingiverse.com/thing:3007147
* By Daniel Hultgren https://www.thingiverse.com/Hultis
* Version 1.4
* 2020-06-08
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
wall_count = 2; // [0 : 1 : 2]
// Set lower if you think the side walls are too thick.
max_wall_thickness = 10;
// Set this if you want to use these above your existing brackets. Typical 2020 brackets have a size of 20 and side thickness of 3.
cutout_size = 0;
cutout_side_thickness = 3;
// Decrease this if you don't want extrusion inserts on both sides. Intended for using these entirely or partially on non-extrusions.
extrusion_insert_count = 2; // [0 : 1 : 2]
// Set this to control how much space the nuts have. Hammer nuts should just work but for t nuts you will need to set a specific width.
specific_bottom_nut_space = 0;
// Bracket angle for all your non-90 degree needs.
bracket_angle = 90; // [45 : 1 : 180]





/**********************************
   End of config, here be dragons
**********************************/





/* [Hidden] */
// preview[view:north east, tilt:top diagonal]

// How far into the extrusions the inserts go. Should be fine as it is.
extrusion_insert_height = 3;

cutout_margin = 0.3;
screw_head_margin = 0.5;
e = 0.05;
top_screw_distance = screw_distance_from_edge(side_length, side_thickness, top_screw_count, screw_hole_size, screw_head_size, screw_head_margin, top_screw_elongation, cutout_size);
bottom_screw_distance = screw_distance_from_edge(side_length, side_thickness, bottom_screw_count, screw_hole_size, screw_head_size, screw_head_margin, top_screw_elongation, cutout_size);
screw_distance_from_edge = max(top_screw_distance, bottom_screw_distance);

bridge_size = min(
    bridge(side_length, side_thickness, top_screw_count, screw_head_margin, top_screw_elongation+screw_head_size, top_screw_distance, cutout_size),
    bridge(side_length, side_thickness, bottom_screw_count, screw_head_margin, bottom_screw_elongation+screw_head_size, bottom_screw_distance, cutout_size));

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

module bracket_sides(width) {
    difference() {
        union() {
            translate([-width/2, 0, 0]) cube([width, side_length, side_thickness]); // Bottom wall
            rotate([bracket_angle, 0, 0]) translate([-width/2, 0, -side_thickness]) cube([width, side_length, side_thickness]); // Top wall
        }
        if (bracket_angle < 90) {
            translate([-width/2-e, 0, -side_thickness]) cube([width+2*e, side_length, side_thickness]); // Bottom wall cutoff
            rotate([bracket_angle, 0, 0]) translate([-width/2-e, 0, 0]) cube([width+2*e, side_length, side_thickness]); // Top wall cutoff
        }
    }
}

module bracket(width, wall_thickness, is_first) {
    difference() {
        union() {
            bracket_sides(width);
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
        magic_height_number = 42;
        translate([0, side_length+e, side_thickness-cutoff_amount])
            rotate([90-(180-bracket_angle)/2, 0, 0])
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
    if (cutout_size > 0) {
        assert(bracket_angle == 90, "Can't use cutout with bracket angles other than 90 degrees");
        translate([extrusion_width/2+e, 0, 0])
            rotate([0, -90, 0])
            linear_extrude(height = extrusion_width+2*e, convexity = 2)
            polygon(points = [
            [zero, zero],
            [zero, full_width],
            [cutout_side_thickness+cutout_margin, full_width],
            [full_width, cutout_side_thickness+cutout_margin],
            [full_width, zero]]);
    }
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
    translate([0, 0, side_thickness+2*e]) display_screw_head(head_size, screw_elongation);
}

module display_screw_head(head_size, screw_elongation) {
    // Screw head, to make sure they don't hit each other
    #hull() {
        translate([0, screw_elongation/2, 0]) cylinder(h = 3, r = head_size / 2, $fn = 32);
        translate([0, -screw_elongation/2, 0]) cylinder(h = 3, r = head_size / 2, $fn = 32);
    }
}

module bridge(size, width, wall_thickness) {
    c = screw_head_size / 3;
    union() {
        translate([width/2, 0, 0])
            rotate([0, 270, 0])
            linear_extrude(height = width, convexity = 2)
             polygon([[side_thickness, side_thickness*tan((180-bracket_angle)/2)],
                       [(side_thickness+size)*cos(bracket_angle-90)+side_thickness*sin(bracket_angle-90), -(side_thickness+size)*sin(bracket_angle-90)+side_thickness*cos(bracket_angle-90)],
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
        translate([0, size+side_thickness, side_thickness-e]) linear_extrude(height = e, convexity = 2) polygon(points = polygon_points);
        translate([0, -(side_thickness+size)*sin(bracket_angle-90)+side_thickness*cos(bracket_angle-90), (side_thickness+size)*cos(bracket_angle-90)+side_thickness*sin(bracket_angle-90)])
            rotate([bracket_angle,0,0])
                linear_extrude(height = e, convexity = 2)
                    polygon(points = polygon_points);
    }
}

module extrusion_insert() {
    translate([-extrusion_insert_width/2, -extrusion_insert_height, 0]) cube([extrusion_insert_width, extrusion_insert_height, side_length]);
}

module extrusion_chamfer(height = .5) {
    added_length_for_low_angles = extrusion_insert_height;
    x = extrusion_insert_width;
    z = side_length + extrusion_insert_height + added_length_for_low_angles;
    length = sqrt(height * height * 2);
    translate([-extrusion_insert_width/2, -extrusion_insert_height, -extrusion_insert_height]) union() {
        translate([0, -height, -added_length_for_low_angles-e]) rotate([0, 0, 45]) cube([length, length, z+2*e]);
        translate([x, -height, -added_length_for_low_angles-e]) rotate([0, 0, 45]) cube([length, length, z+2*e]);
    }
}
module extrusion_insert_corner() {
    difference() {
        translate([extrusion_insert_width/2,0,-extrusion_insert_height])
            rotate([90,0,-90])
            linear_extrude(extrusion_insert_width, center = false, convexity = 10, twist = 0)
                polygon(points=[[0,0],
                               [0,extrusion_insert_height],
                               [extrusion_insert_height*cos(bracket_angle-90),(extrusion_insert_height-extrusion_insert_height*sin(bracket_angle-90))],
                               [extrusion_insert_height*tan((180-bracket_angle)/2),0]]);
        if (bracket_angle < 90) {
            rotate([bracket_angle/2+90, 0, 0]) translate([-extrusion_insert_width/2-e, -extrusion_insert_height, sqrt(2)*extrusion_insert_height]) cube([extrusion_insert_width+2*e, extrusion_insert_height*2, 20]);
        }
    }
}

function screw_distance_from_edge(side_length, side_thickness, screw_count, screw_hole_size, screw_head_size, screw_head_margin, screw_elongation, cutout_size) =
    let(screw_head_height = 3,
    screw_required_length = screw_elongation+screw_head_size,
    usable_side = side_length-side_thickness*(cutout_size > 0 ? 0.5 : 1.5)-cutout_size-screw_required_length*screw_count,
    min_screw_distance = side_thickness*0.5+screw_required_length/2)
    screw_count > 1
        ? min_screw_distance
        : (usable_side-screw_head_height)*0.4+min_screw_distance;

function bridge(side_length, side_thickness, screw_count, screw_head_margin, total_screw_size, screw_distance_from_edge, cutout_size) =
    let(max_possible_bridge = side_length-side_thickness-screw_distance_from_edge-total_screw_size*screw_count-cutout_size)
    screw_count > 1
        ? max(max_possible_bridge/screw_count+cutout_size, 0)
        : side_length - screw_distance_from_edge - total_screw_size / 2 - side_thickness - screw_head_margin;





/**********************************
       Unit tests start here
**********************************/

//unit_tests();
module unit_tests() {
    screw_distance_from_edge_tests();
    bridge_size_tests();
}

module screw_distance_from_edge_tests() {
    // basic 30mm side
    assert_with_message(screw_distance_from_edge(30, 5, 1, 5, 10, 0.5, 0, 0), 11.3);
    // basic 40mm side
    assert_with_message(screw_distance_from_edge(40, 5, 1, 5, 10, 0.5, 0, 0), 15.3);
    // thicker sides
    assert_with_message(screw_distance_from_edge(30, 10, 1, 5, 10, 0.5, 0, 0), 10.8);
    // elongated screw holes
    assert_with_message(screw_distance_from_edge(30, 5, 1, 5, 10, 0.5, 15, 0), 12.8);
    // cutout
    assert_with_message(screw_distance_from_edge(40, 5, 1, 5, 10, 0.5, 0, 20), 9.3);

    // basic two screws
    assert_with_message(screw_distance_from_edge(30, 5, 2, 5, 10, 0.5, 0, 0), 7.5);
    // thicker sides
    assert_with_message(screw_distance_from_edge(50, 10, 2, 5, 10, 0.5, 0, 0), 10);
    // two screws with cutout
    assert_with_message(screw_distance_from_edge(50, 5, 2, 5, 10, 0.5, 0, 10), 7.5);
    // two elongated screws
    assert_with_message(screw_distance_from_edge(50, 5, 2, 5, 10, 0.5, 10, 0), 12.5);
}

module bridge_size_tests() {
    // one screw on basic bracket
    assert_with_message(bridge(30, 5, 1, 0.5, 10, 8, 0), 11.5);
    // single screw with cutout
    assert_with_message(bridge(40, 5, 1, 0.5, 10, 8, 20), 21.5);
    // two screws with cutout
    assert_with_message(bridge(50, 5, 2, 0.5, 10, 8, 20), 18.5);
    // three screws on long bracket
    assert_with_message(bridge(80, 8, 3, 0.5, 10, 12, 0), 10);
}

module assert_with_message(actual, expected) {
    allowed_error = 0.0001;
    if (abs(actual-expected) > allowed_error) {
        assert(expected == actual, str("Expected ", expected, " but got ", actual));
    }
}