<?php

namespace mik\writers;

use GuzzleHttp\Client;
use mik\exceptions\MikErrorException;
use Monolog\Logger;

class LsuOaipmh extends Oaipmh {

  public function writeMetadataFile($metadata, $path, $overwrite = true) {
    // Add XML decleration
    $doc = new \DomDocument('1.0');
    $doc->loadXML($metadata);
    $doc->formatOutput = true;

    $pid = $doc->getElementsByTagNameNS('http://purl.org/dc/elements/1.1/', 'identifier')->item(0)->textContent;
    $pid_path = htmlspecialchars("http://digitallibrary.tulane.edu/islandora/object/$pid");

    $descEl = $doc->getElementsByTagNameNS('http://purl.org/dc/elements/1.1/', 'description')->item(0);
    $description = sprintf("See full record: %s  %s", $descEl->textContent, $pid_path);

    $newDescEl = $doc->createElementNS('http://purl.org/dc/elements/1.1/', 'dc:description', $description);

    $root = $doc->getElementsByTagNameNS('http://www.openarchives.org/OAI/2.0/oai_dc/', 'dc')->item(0);
    $root->replaceChild($newDescEl, $descEl);
    $metadata = $doc->saveXML();

    if ($path != '') {
      $fileCreationStatus = file_put_contents($path, $metadata);
      if ($fileCreationStatus === false) {
        $this->log->addWarning("There was a problem writing the metadata to a file", array('file' => $path));
      }
    }
  }

}
