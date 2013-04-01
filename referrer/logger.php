<?php
  /**
   * Alright, what does this do: it gets the client's IP and the
   * referring URL they communicated. Then it logs those, timestamped,
   * to a gzipped file. That's it. Why would I log anything else...?
   */
  if(isset($_POST)) {
  	// timestamp
  	$time = microtime(true);
  	$stamp = date("Y-m-d H:i:s");
  	// referre URL
  	$ref = $_POST["referrer"];
  	// I know URLs can be really long, but generally, they're not.
  	// Even translate.google.com URLs are typically below this.
  	if(strlen($ref) <= 350) {
	  	// client IP
	  	$ip = $_SERVER["REMOTE_ADDR"];
	    // and collapse to a line of JSON
	    $json_line = '{time: '.$time.', stamp: "'.$stamp.'", referrer: "'.$ref.'", ip: "'.$ip.'"}' . "\n";
	    // write to file. Yes, there's an .htaccess rule for it.
		  $gz = gzopen('referral_log_' . date("Y-m-d") . '.gz','a9');
		  gzwrite($gz, $json_line);
		  gzclose($gz);
	  }
  }
?>
