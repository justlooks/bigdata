<?php
# define colors
$COLS=array();
$COLS[1]="#000000";
$COLS[2]="#00ff00";
$COLS[3]="#0000ff";
$COLS[4]="#3300ff";
$COLS[5]="#ffff33";
$COLS[6]="#006600";

$opt[1] = ' --title "' . $this->MACRO['DISP_HOSTNAME'] . ' / ' . $this->MACRO['DISP_SERVICEDESC'] . '"';
$ds_name[1] = $this->MACRO['DISP_SERVICEDESC'];
$def[1] = "";
$count=0;
foreach ($this->DS as $KEY=>$VAL) {
$count++;
$def[1] .= rrd::def("var".$count, $VAL['RRDFILE'], $VAL['DS'], "AVERAGE");

$def[1] .= rrd::line1("var".$count, $COLS[$count], "$NAME[$count]");
$def[1] .= rrd::gprint("var".$count, array("LAST", "AVERAGE", "MAX"), "%6.2lf");
}

?>

