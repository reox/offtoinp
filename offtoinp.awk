#!/usr/bin/awk -f
# Convert OFF (Object File Format) to INP (ABAQUS Input Deck Format)
#
# We use CPS3 Node type (Three-node plane stress element)
# There is a limitatio in calculix, that not more than 100 elements
# can share the same node. This is a problem, if one exports the OFF files
# for example from OpenSCAD...
#
# Be aware of such limitations!
#
# Sebastian Bachmann <hello@reox.at>, 2017
BEGIN {
    num_rows = -1;
    row = 0;
    erow = 1;

    has_printed = 0;

    print "*HEADING"
    print " Generated INP file"
}

# First line is OFF <noded> <faces> <edges>
(FNR == 1){
    if ($1 != "OFF"){
        print "This does not look like a OFF file..." > "/dev/stderr"
        exit 1;
    }
    num_rows = $2;
    print "*NODE"
    next;
}


(FNR > 1){
    # Parse Node definitions
    if (row < num_rows && has_printed == 0){
        print row + 1 ", " $1 ", " $2 ", " $3

        row++;
        next;
    }
    if (row == num_rows && has_printed == 0){
        print "*ELEMENT, type=CPS3, ELSET=Surface1"
        has_printed = 1;
    }
    if (row == num_rows){
        print erow "," $2 + 1 ", " $3 + 1 ", " $4 + 1
        erow++;
        next;
    }
}
