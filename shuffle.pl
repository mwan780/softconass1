#!/usr/bin/perl -w

@text = <>;
@printed = ();



while(@text) {
    $temp = $text[0];
    $index = rand(@text);
    $text[0] = $text[$index];
    $text[$index] = $temp;
    print $text[0];
    shift @text;
}



