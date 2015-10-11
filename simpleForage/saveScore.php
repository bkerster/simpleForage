<?
$outText = $_POST["outText"];
#COMMENT!
#$myFile = "wfdata/test.txt";
$myFile = $_POST['filename'];
$fh = fopen($myFile, 'w');
#fwrite($fh,date("D M j G:i:s T Y")."\t".rtrim($_POST["outText"])."\n");
#fwrite($fh,"test");
fwrite($fh,$outText);
fclose($fh);

?>
