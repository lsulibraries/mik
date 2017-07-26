<?php
namespace mik\writers;

use GuzzleHttp\Client;
use mik\exceptions\MikErrorException;
use Monolog\Logger;

class LsuOaipmh extends Oaipmh
{
    public function writeMetadataFile($metadata, $path, $overwrite = true)
    {
        // Add XML decleration
        $doc = new \DomDocument('1.0');
        $doc->loadXML($metadata);
        $doc->formatOutput = true;
        $root = $doc->getElementsByTagNameNS('http://www.openarchives.org/OAI/2.0/oai_dc/','dc')->item(0);

        //grab existing element identifier which has tulane:item
        $elem_id = $doc->getElementsByTagNameNS('http://purl.org/dc/elements/1.1/','identifier');
        $pid_elem = $elem_id->item(0)->textContent;
        $pid_path = 'http://digitallibrary.tulane.edu/islandora/object/'.$pid_elem;

        //new path added as element to root then
        $link_back = $doc->createElementNS('http://purl.org/dc/elements/1.1/','dc:identifier',$pid_path);
        $root->appendChild($link_back);

        //make new element desc.abs
        $dc_desc_abs = $doc->createElementNS('http://purl.org/dc/elements/1.1/', 'description.abstract', $pid_path);
        $root->appendChild($dc_desc_abs);

        //confirm element added
        $print_check = $doc->getElementsByTagNameNS('http://purl.org/dc/elements/1.1/','description.abstract');
        var_dump($print_check->item(0)->textContent);

        $metadata = $doc->saveXML();

        if ($path !='') {
            $fileCreationStatus = file_put_contents($path, $metadata);
            if ($fileCreationStatus === false) {
                $this->log->addWarning("There was a problem writing the metadata to a file",
                    array('file' => $path));
            }
        }
    }
}
