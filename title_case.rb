#!/usr/bin/env ruby

#   This filter changes all words to Title Caps, and attempts to be clever
#   about *un*capitalising small words like a/an/the in the input.
#
#   The list of "small words" which are not capped comes from
#   the New York Times Manual of Style, plus 'vs' and 'v'. 
#   
#   Sam Aaron
#   http://sam.aaron.name
#   21st of May, 2008
#
#   This is a Ruby port of the original Perl script written by John Gruber
#   http://daringfireball.net/2008/05/title_case
#
#   License: http://www.opensource.org/licenses/mit-license.php
#

require 'rubygems'
require 'activesupport'
small_words = %w(a an and as at but by en for if in of on or the to v[.]? via vs[.]?)

#define regexps
SMALL_WORDS                              = /\b#{small_words.join('\b|\b')}\b/i
LAST_WORD_IS_A_SMALL_WORD                = /\b(#{small_words.join('|')})([[:punct:]]*)\Z/
FIRST_WORD_IS_A_SMALL_WORD               = /\A([[:punct:]]*)(#{small_words.join('|')})\b/
ENDING_PUNCTUATION_OR_STARTING_QUOTES    = /( [:.;?!][ ] | (?:[ ]|^)["] )/x
WORDS_WHERE_THE_SECOND_CHAR_IS_LOWERCASE = /\b([[:alpha:]][[:lower:].']*)\b/
WORDS_CONTAINING_A_PERIOD                = /[[:alpha:]][.][[:alpha:]]/

while(input_line = gets) do

    capitalised_line = input_line.split(ENDING_PUNCTUATION_OR_STARTING_QUOTES).map do |part|
      part.gsub!(WORDS_WHERE_THE_SECOND_CHAR_IS_LOWERCASE) do
        match = $1          
        if (match !~ WORDS_CONTAINING_A_PERIOD and match =~ WORDS_WHERE_THE_SECOND_CHAR_IS_LOWERCASE)
          match = match.downcase.titleize
        end
        
        if match =~ SMALL_WORDS
          match = match.downcase 
        end
        match
      end
      
      # If the first word in the title is a small word, then capitalise it:
      part.gsub!(FIRST_WORD_IS_A_SMALL_WORD) do
        $1 + $2.titleize
      end
             
      # If the last word in the title is a small word, then capitalise it:
      part.gsub!(LAST_WORD_IS_A_SMALL_WORD) do
        $1.titleize + $2
      end
      part 
    end.join
    
    #Special Cases:
    capitalised_line.gsub!(/V(s?)\. /)       {'v' + $1 + '. '}  # "v." and "vs."
    capitalised_line.gsub!(/(['])S\b/)       {$1 + 's'}         # 'S (otherwise you get "the SEC'S decision")
    capitalised_line.gsub!(/\b(AT&T|Q&A)\b/i){$1.upcase}        # "AT&T" and "Q&A", which get tripped up by
                                                                # self-contained small words "at" and "a"
    puts capitalised_line
    
end