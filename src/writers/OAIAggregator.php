<?php
namespace mik\writers;

use GuzzleHttp\Client;
use mik\exceptions\MikErrorException;
use Monolog\Logger;

class OAIAggregator extends Oaipmh
{

    public function __construct($settings) {

        $this->temp_directory = $settings['FILE_GETTER']['temp_directory'];
        parent::__construct($settings);
    }

    public function writePackages($metadata, $pages, $record_id) {
        $this->record_id = $record_id;
        parent::writePackages($metadata, $pages, $record_id);
    }
    
    public function getTempFile($path) {
        $id = explode(DIRECTORY_SEPARATOR, $path);
        return array_pop($id);
    }

    public function parseIdentifierForUrl($temp_file) {
        $contents = file_get_contents($temp_file);
        $xml = new \SimpleXMLElement($contents);
        
        $id = $xml->header->identifier;
        $parts = explode(":", $id);
        $protocol = $parts[1];
        $rawPid = $parts[3];
        $pid = str_replace('_', ':', $rawPid);
        $url = $protocol . ":" . $parts[2] . "islandora/object" . '/' . $pid;
             //oai:http://digitallibrary.tulane.edu/:tulane_70
        return $url;
    }

    public function writeMetadataFile($metadata, $path, $overwrite = true)
    {
        //        var_dump($this->getTempFile($this->record_id)); die();
        //$temp_file = $this->temp_directory . DIRECTORY_SEPARATOR . $this->getTempFile($path);
        $temp_file = $this->temp_directory . DIRECTORY_SEPARATOR . $this->record_id . '.metadata';
        $url = $this->parseIdentifierForUrl($temp_file);
        $mods_ns = 'http://www.loc.gov/mods/v3';
        $doc = new \DomDocument('1.0');
        $doc->loadXML($metadata);
        $doc->formatOutput = true;
        $root = $doc->getElementsByTagNameNS($mods_ns, 'mods')->item(0);

        //grab existing element abstract which has tulane:item
        $oldAbstract = $doc->getElementsByTagNameNS($mods_ns, 'abstract')->item(0);
        $abstractText = sprintf("(Original record: %s)  %s", $url, $oldAbstract->textContent);

        //new path added as element to root then
        $newAbstract = $doc->createElement('abstract', $abstractText);
        $root->replaceChild($newAbstract, $oldAbstract);
        //        $root->appendChild($newAbstract);

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
