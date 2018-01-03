<?php

/**
 * @file
 * Shutdown hook script for MIK.
 * 
 * Required config values:
 *
 * $config['XSLT']['working_dir']
 * Saxon working directory; will contain a sub-directory for the output of each
 * stylesheet when $config['XSLT']['step_thru'] is set and TRUE.
 *
 * $config['XSLT']['stylesheets']
 * Array of paths to .xsl that will be applied in order using saxon.
 *
 * $config['XSLT']['step_thru']
 * Whether to keep the contents of the $config['XSLT']['working_dir'] around.
 * Potentially useful for troubleshooting XSLT chains.
 */
require 'vendor/autoload.php';

use Monolog\Logger;
use Monolog\Handler\StreamHandler;

$ds = DIRECTORY_SEPARATOR;
$config_path = trim($argv[1]);
$config = parse_ini_file($config_path, TRUE);
$config_output_dir = $config['WRITER']['output_directory'];

// Set up logging.
$log_path = explode($ds, $config['LOGGING']['path_to_log']);
array_pop($log_path);
$log_path = implode($ds, $log_path) . $ds . 'saxon.log';

$info_log = new Logger('saxon_info');
$info_log_handler = new StreamHandler($log_path, Logger::INFO);
$info_log->pushHandler($info_log_handler);

$error_log = new Logger('saxon_err');
$error_log_handler = new StreamHandler($log_path, Logger::ERROR);
$error_log->pushHandler($error_log_handler);

if (!file_exists('saxon9he.jar')) {
  $error_log->addError("MIK is configured to run xslt transformations using saxon, but the "
      . "saxon jar was not found. Either remove 'apply_xslt_with_saxon.php' "
      . "from your config section [WRITER][postwritebatchhooks], or download and "
      . "extract saxon9he.jar to the top level directory next to the mik executable."
  );
  exit(1);
}


$Directory = new RecursiveDirectoryIterator($config_output_dir);
$Iterator = new RecursiveIteratorIterator($Directory);
$paths = new RegexIterator($Iterator, '/.+\.xml$/i', RecursiveRegexIterator::GET_MATCH);

// lazily borrowed from http://www.wordinn.com/solution/108/php-getting-part-string-after-and-given-sub-string-or-character
function strafter($string, $substring) {
  $pos = strpos($string, $substring);
  if ($pos === false) {
    return $string;
  }
  else {
    return (substr($string, $pos + strlen($substring)));
  }
}

function strbefore($string, $substring) {
  $pos = strpos($string, $substring);
  if ($pos === false)
    return $string;
  else
    return(substr($string, 0, $pos));
}


//var_dump($dir_structure, $mods_paths);
//$copydir = function($src, $dest, $filter = NULL) {
//  if (!is_dir($dest)) {
//    mkdir($dest);
//  }
//  $files = scandir($src);
//  foreach ($files as $file) {
//    if ($filter) {
//      if ($filter($file)) {
//        continue;
//      }
//    }
//    if (!is_dir($file)) {
//      copy($src . DIRECTORY_SEPARATOR . $file, $dest . DIRECTORY_SEPARATOR . $file);
//    }
//  }
//};


$xsl_working_dir = $config['XSLT']['working_dir'];
$transforms = $config['XSLT']['stylesheets'];
file_exists($xsl_working_dir) ? NULL : mkdir($xsl_working_dir);

$xslt_start = $xsl_working_dir . $ds . 'xslt-0';

$dir_structure = array();
$mods_paths = array();
foreach ($paths as $path) {
  $path = $path[0];
  $mods_path = strafter($path, $config_output_dir);
  $mods_paths[] = $mods_path;

  $base_dir = strbefore($mods_path, 'MODS.xml');
  $dir_structure[] = $base_dir;

  $subdir = $xslt_start . $base_dir;
  if (!is_dir($subdir)) {
    mkdir($subdir, '0777', TRUE);
  }
  copy($path, $xslt_start . $mods_path);
}

$xslt_input = $xslt_start;
end($transforms);
$last = key($transforms);
reset($transforms);

foreach ($transforms as $i => $transform) {
  $transform_key = explode('.', array_pop(explode($ds, $transform)))[0];
  $xslt_output = sprintf('%s%sxslt-%d-%s%s', $xsl_working_dir, $ds, $i + 1, $transform_key, $ds);
  if (!is_dir($xslt_output)) {
    mkdir($xslt_output);
  }
  foreach ($dir_structure as $dir) {
    $subdir = $xslt_output . $dir;
    if (!is_dir($subdir)) {
      mkdir($subdir, '0777', TRUE);
    }
  }

  $info_log->addInfo("Applying stylesheet " . $transform);
  foreach ($mods_paths as $mods) {
    $src = $xslt_input.$mods;
    $out = $xslt_output.$mods;
    $command = "java -jar saxon9he.jar -s:$src -xsl:$transform  -o:$out";
    $info_log->addInfo("Saxon command line: $command");
    exec($command, $ret);
    if (!empty($ret)) {
      $error_log->addError(sprintf("Output from saxon: %s", implode(",", $e)));
    }
    if ($i == $last) {
      copy($out, $config_output_dir . $mods);
    }
  }

  $xslt_input = $xslt_output;
}

// Now move the results into the output dir.


if (isset($config['XSLT']['step_thru']) && !$config['XSLT']['step_thru']) {
  $files = glob($xsl_working_dir . '/*');
  echo "removing file $path\n";
  foreach ($files as $file) {
    is_dir($file) ? removeDirectory($file) : unlink($file);
  }
  rmdir($xsl_working_dir);
}
