<?php
/*
 * This script loads a gzipped XML file from another server and serves it as CSV
 * after a transformation based on an XSL-template.
 * David Coppoolse v2 2019-07-25
 */
error_reporting(0);

$scriptName = "catxml2csv2";
$sourceFile = 'https://anet.be/opendata/abraham/abraham_cat.xml.gz';
$tmpDir = './tmp/'; /* use trailing slash! */
$sessionID = rand(1000000000, 9999999999);
$tmpFilePrefix = $tmpDir . $scriptName . '_temp_' . $sessionID;
$gzFile = $tmpFilePrefix . '.xml.gz';
$xmlFile = $tmpFilePrefix . '.xml';
$utf8bom = chr(239) . chr(187) . chr(191);

if (isset($_GET['format'])) {
    $xslFile = './transformations/' . $_GET['format'] . '.xsl';
    $outputFile = 'Export_Abraham_' . ucfirst($_GET['format']) . '_' . date("Ymd") . '.csv';
} else {
    $xslFile = './transformations/default.xsl';
    $outputFile = 'Export_Abraham_' . date("Ymd") . '.csv';
}

header('Content-type: text/csv');
header('Content-Disposition: attachment; filename=' . $outputFile);
header('Pragma: no-cache');
header('Expires: 0');

if (! copy($sourceFile, $gzFile)) {
    exit($scriptName . ': FAILED to download source XML GZIP archive ' . $sourceFile);
}

if (! gzDecompress($gzFile, $xmlFile)) {
    delTempFiles($tmpFilePrefix);
    exit($scriptName . ': FAILED to decompress source XML GZIP archive ' . $gzFile);
}

// Load XML file
$xml = new DOMDocument();
$xml->load($xmlFile);

// Load XSL file
if (file_exists($xslFile)) {
    $xsl = new DOMDocument();
    $xsl->load($xslFile);
}
else {
    exit($scriptName . ': FAILED to open XSL transformation sheet ' . $xslFile);
}

// Configure the transformer
$proc = new XSLTProcessor();

// Attach the xsl rules
$proc->importStyleSheet($xsl);

echo $utf8bom . $proc->transformToXML($xml);

delTempFiles($tmpFilePrefix);

function delTempFiles($tmpFilePrefix)
{
    foreach (glob($tmpFilePrefix . '*.*') as $filename) {
        unlink($filename);
    }
}

function gzDecompress($srcName, $dstName)
{
    $error = false;

    if ($file = gzopen($srcName, 'rb')) { // open gz file

        $out_file = fopen($dstName, 'wb'); // open destination file

        while (($string = gzread($file, 4096)) != '') { // read 4kb at a time
            if (! fwrite($out_file, $string)) { // check if writing was successful
                $error = true;
            }
        }

        // close files
        fclose($out_file);
        gzclose($file);
    } else {
        $error = true;
    }

    if ($error)
        return false;
    else
        return true;
}
