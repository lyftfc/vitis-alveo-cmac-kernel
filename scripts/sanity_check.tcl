# Check if the supplied parameters for board and/or port are supported
if {$board == "au50"} {
    if {$qsfp_port != 0} {
        puts "ERROR: Alveo U50 only supports port 0."
    } else {puts "INFO: Generating for board $board port $qsfp_port." }
} elseif {$board == "au200"} {
    if {$qsfp_port != 0 && $qsfp_port != 1} {
        puts "ERROR: Alveo U200 only supports ports 0 or 1."
    } else {puts "INFO: Generating for board $board port $qsfp_port." }
} elseif {$board == "au250"} {
    if {$qsfp_port != 0 && $qsfp_port != 1} {
        puts "ERROR: Alveo U250 only supports ports 0 or 1."
    } else {puts "INFO: Generating for board $board port $qsfp_port." }
} elseif {$board == "au280"} {
    if {$qsfp_port != 0 && $qsfp_port != 1} {
        puts "ERROR: Alveo U280 only supports ports 0 or 1."
    } else {puts "INFO: Generating for board $board port $qsfp_port." }
} else {
    puts "ERROR: Unsupported board $board. Only Alveo U50/200/250/280 are supported."
}