<?php
global $Lexicon;
$Lexicon = array_merge((array)$Lexicon, array(
  'year'  => ' / ',
  'month' => ' / ',
  'day'   => ' (yyyy/mm/dd) ',
  'ex) 03-1234-5678' => 'eg. 03-1234-5678',
  'ex) 123-4567' => 'eg. 123-4567',
  'ex) http://www.example.com/' => 'eg. http://www.example.com/',
  'ex) foo@example.com' => 'eg. foo@example.com',
  "This form is <a href='http://www.ark-web.jp/movabletype/' target='_blank'>A-Form for Movabletype Trial version</a>" => "This form is <a href='http://www.ark-web.jp/movabletype/' target='_blank'>A-Form  for Movable Type Trial version</a>",
));
