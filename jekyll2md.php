<?php
$file_path = $argv[1];
$file_content = file_get_contents($file_path);
// die($file_content);

function transfer_code_block($code_block)
{
	$retval = preg_replace("/^```.*\n/Usm", "\n", $code_block);
	$retval = preg_replace("/\n/s", "\n\t", $retval);
	$retval = preg_replace("/\t```/", "\n", $retval);
	return $retval;
}

function replace_code_block($string)
{
	$pattern = "/^```.*```/Usm";
	while(preg_match($pattern, $string, $matches)) 
	{
		$code_block = $matches[0];
		$transferred_code_block = transfer_code_block($code_block);
		$string = str_replace($code_block, $transferred_code_block, $string);
	}
	return $string;
}

file_put_contents("temp.md", replace_code_block($file_content));
?>