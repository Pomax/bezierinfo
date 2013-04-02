<?php
  /**
   * Alright, what does this do: it gets the client's IP and the
   * referring URL they communicated. Then it logs those, timestamped,
   * to a gzipped file. That's it. Why would I log anything else...?
   */
  if(isset($_GET["referrer"])) {
    // Allow the bezier article to call us.
    header('Access-Control-Allow-Origin: http://pomax.github.com');
    header('Access-Control-Allow-Headers: Content-Type');
  	// Form timestamps
  	$time = microtime(true);
  	$stamp = date("Y-m-d H:i:s");
  	// Get referrer URL.
  	$ref = $_GET["referrer"];
  	// I know URLs can be really long, but generally, they're not.
  	// Even translate.google.com URLs are typically below this.
  	if(strlen($ref) <= 350) {
	  	// Get client IP. You did not send this as POST data,
      // it's simply part of the HTTP request you send.
	  	$ip = $_SERVER["REMOTE_ADDR"];
	  	$host = gethostbyaddr($ip);
	    // Convert the data to a single line of JSON
	    $json_line = '{time: '.$time.', stamp: "'.$stamp.'", referrer: "'.$ref.'", ip: "'.$ip.'", hostname: "'.$host.'"}' . "\n";
	    // Finally, write the data to the log file.
      // Yes, there's an .htaccess rule that prevents downloading this.
		  $gz = gzopen('referral_log_' . date("Y-m-d") . '.gz','a9');
		  gzwrite($gz, $json_line);
		  gzclose($gz);
      // That's all there.
	  }
  }
  echo "<pre>" . print_r($_POST,true) . "</pre>";
?>
