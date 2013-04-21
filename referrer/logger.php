<?php
  /**
   * Alright, what does this do: it gets the client's IP and the
   * referring URL they communicated. Then it logs those, timestamped,
   * to a gzipped file. That's it. Why would I log anything else...?
   *
   * This lets me see roughly where in the world people are reading
   * the article (which tells me where it might make sense to tell
   * people about its existence), and it lets me see which other pages
   * on the web link to it, so I can check those pages out and maybe
   * find information that lets me improve it (like forum comments
   * about the article that people left in that forum, rather than
   * as a comment on my article).
   *
   * Lastly, it tells me how many people visit the page at all.
   * Github's gh-pages system does not any kind of stats, so the
   * only way to find out how many daily visitors I get is by using
   * a tracking service. I don't know about you, but I'd rather have
   * a website do that itself than rely on google analytics (or
   * another third party 'you have no idea what happens with the
   * data we collect' company).
   *
   * - Pomax
   */
  if(isset($_GET["referrer"])) {
    // Allow the bezier article and legendre-gauss table page to call us.
    header('Access-Control-Allow-Origin: http://pomax.github.io');
    header('Access-Control-Allow-Headers: Content-Type');
    // Form timestamps
    $time = microtime(true);
    $stamp = date("Y-m-d H:i:s");
    // Get the original page. This'll be a string like 'bezier' or 'legendre'.
    $for = $_GET["for"];
    // Get referrer URL.
    $ref = $_GET["referrer"];
    // I know URLs can be really long, but generally they're not.
    // Even translate.google.com URLs are typically below this.
    if(strlen($ref) <= 350) {
      // Get client IP. Any page your browser requests on the
      // internet contains that information so that servers can
      // send data back to you. If you don't want people to know
      // your IP, you'll have to use an anonymizing service.
      $ip = $_SERVER["REMOTE_ADDR"];
      $host = gethostbyaddr($ip);
      if($host==$ip) { $host=""; }
      // Convert the data to a single line of JSON
      $json_line = '{for: "'.$for.'", time: '.$time.', stamp: "'.$stamp.'", referrer: "'.$ref.'", ip: "'.$ip.'", hostname: "'.$host.'"}' . "\n";
      // Finally, write the data to the log file.
      // (there's an .htaccess rule that prevents public access to the log files)
      $gz = gzopen('referral_log_' . date("Y-m-d") . '.gz','a9');
      gzwrite($gz, $json_line);
      gzclose($gz);
      // That's all there is.
    }
  }
  echo "<pre>" . print_r($_POST,true) . "</pre>";
?>
