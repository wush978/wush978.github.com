<?php
$file_path = $argv[1];
$file_content = file_get_contents($file_path);
// die(preg_quote(">"));
$table_of_content = "";
$file_content = explode("\n", $file_content);
foreach ($file_content as $string)
{
	preg_match("/\<h(\d)\sid=\"(.*)\".*\>(.*)\<\/h(\d)\>$/U", $string, $matches);
	if (count($matches) > 0) {
		if ($matches[1] !== $matches[4]) {
			die("error: $string \n");
		}
		
		$table_of_content .= str_repeat("\t", (int)$matches[1] - 1) . "*\t[" . $matches[3] . "](#" . $matches[2] . ")\n";
	}
}
file_put_contents("table_of_content.md", $table_of_content);
?>