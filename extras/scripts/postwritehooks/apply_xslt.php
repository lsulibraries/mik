<?php

/**
 * Post-write hook script for MIK that validates MODS XML files.
 * Works for single-file CONTENTdm and CSV import packages as well as
 * newspaper issue packages, and can be extended to handle the MODS.xml
 * files created by other MIK toolchains.
 */

require 'vendor/autoload.php';

use Monolog\Logger;
use Monolog\Handler\StreamHandler;
use GuzzleHttp\Client;

$record_key = trim($argv[1]);
$children_record_keys = explode(',', $argv[2]);
$config_path = trim($argv[3]);
$config = parse_ini_file($config_path, true);

//$mods_filename = 'MODS.xml';
// The CONTENTdm 'nick' for the field that contains the data used
// to create the issue-level output directories.
//$item_info_field_for_issues = 'date';

$path_to_success_log = $config['WRITER']['output_directory'] . DIRECTORY_SEPARATOR .
    'postwritehook_apply_xslt_success.log';
$path_to_error_log = $config['WRITER']['output_directory'] . DIRECTORY_SEPARATOR .
    'postwritehook_apply_xslt_error.log';

// Set up logging.
$info_log = new Logger('postwritehooks/apply_xslt.php');
$info_handler = new StreamHandler($path_to_success_log, Logger::INFO);
$info_log->pushHandler($info_handler);

$error_log = new Logger('postwritehooks/apply_xslt.php');
$error_handler = new StreamHandler($path_to_error_log, Logger::WARNING);
$error_log->pushHandler($error_handler);

$path_to_mods = $config['WRITER']['output_directory'] . DIRECTORY_SEPARATOR . $record_key . '.xml';
$info_log->addInfo("working on file $path_to_mods");

$xslts = $config['XSLT']['stylesheets'];

transform($path_to_mods, $xslts, $info_log, $error_log);


function transform($path_to_mods, $xslts, $info_log, $error_log){
    $out = $path_to_mods.".transformed";
    $info_log->addInfo("Beginning xslt transformations for ".$path_to_mods);
    foreach($xslts as $xslt){
        $info_log->addInfo("Applying stylesheet ". $xslt);
        $info_log->addInfo("Saxon command line: java -jar saxon9he.jar -s:$path_to_mods -xsl:$xslt  -o:$out");
        exec("java -jar saxon9he.jar -s:$path_to_mods -xsl:$xslt  -o:$out", $ret);
        $info_log->addInfo(sprintf("Output from saxon: %s", implode("\n", $ret)));
    }
}