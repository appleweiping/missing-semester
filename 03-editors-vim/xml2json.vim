" xml2json.vim — editors lecture, exercise 8 (Vim macros: XML -> JSON).
"
" Run headlessly to prove the transformation:
"   vim -Nes -u NONE -c 'source xml2json.vim' people.xml
" (writes the converted buffer to people.json)
"
" The macro strategy, per person block:
"   <person>            -> {
"   <name>X</name>      ->   "name": "X",
"   <age>Y</age>        ->   "age": Y
"   </person>           -> },
"
" We express it with :substitute over the whole buffer, which is exactly what a
" recorded keyboard macro automates line-by-line. The equivalent interactive
" recording is documented in solutions.md.

" name line: <name>Bill Gates</name>  ->    "name": "Bill Gates",
%s#\s*<name>\(.*\)</name>#  "name": "\1",#

" age line:  <age>72</age>            ->    "age": 72
%s#\s*<age>\(.*\)</age>#  "age": \1#

" opening tag <person> -> {
%s#^\s*<person>#{#

" closing tag </person> -> },
%s#^\s*</person>#},#

" wrap the whole thing in a JSON array and fix the trailing comma:
" prepend '[' , append ']' , and turn the final '},' into '}'.
call append(0, '[')
$s#},#}#
call append(line('$'), ']')

" Save as people.json alongside the source.
write! people.json
quit!
