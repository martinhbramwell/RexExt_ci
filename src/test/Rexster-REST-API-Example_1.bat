@echo off

echo * 
echo -----------------------------------------
echo .     ----[ Evacuate database ]----
echo -----------------------------------------

echo curl -sSX DELETE "http://localhost:8182/emptygraph"
curl -sSX DELETE "http://localhost:8182/emptygraph/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more

echo -----------------------------------------
echo . ----[ Recreate index vertices ]----
echo -----------------------------------------
echo curl -gsX POST "http://localhost:8182/emptygraph/indices/vertices?class=vertex&type=automatic&keys=[ID]"
curl -gsX POST "http://localhost:8182/emptygraph/indices/vertices?class=vertex&type=automatic&keys=[ID]" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more

echo -----------------------------------------
echo .      ----[ List indices ]----
echo -----------------------------------------
echo curl -sX GET "http://localhost:8182/emptygraph/indices"
curl -sX GET "http://localhost:8182/emptygraph/indices" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more

echo -----------------------------------------
echo .      ----[ Create deck ]----
echo -----------------------------------------
echo curl -sd "ID=5&Type=Pack&Name=Deck of Cards" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=5&Type=Pack&Name=Deck of Cards" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more

echo .
echo -
echo --
echo ---
echo .      ----[ Create suits ]----
echo -----------------------------------------
echo curl -sd "ID=101&Type=Suit&Name=Diamond" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=101&Type=Suit&Name=Diamond" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo curl -sd "ID=202&Type=Suit&Name=Heart" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=202&Type=Suit&Name=Heart" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo curl -sd "ID=303&Type=Suit&Name=Spade" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=303&Type=Suit&Name=Spade" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo curl -sd "ID=404&Type=Suit&Name=Club" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=404&Type=Suit&Name=Club" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo -----------------------------------------
echo ---
echo --
echo -
echo .

echo .
echo -
echo --
echo ---
echo .       ----[ Create aces ]----
echo -----------------------------------------
echo curl -sd "ID=1&Type=Card&Name=Ace" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=1&Type=Card&Name=Ace" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo curl -sd "ID=14&Type=Card&Name=Ace" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=14&Type=Card&Name=Ace" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo curl -sd "ID=27&Type=Card&Name=Ace" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=27&Type=Card&Name=Ace" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo curl -sd "ID=40&Type=Card&Name=Ace" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=40&Type=Card&Name=Ace" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo -----------------------------------------
echo ---
echo --
echo -
echo .

echo .
echo -
echo --
echo ---
echo .      ----[ Create kings ]----
echo -----------------------------------------
echo curl -sd "ID=13&Type=Card&Name=King" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=13&Type=Card&Name=King" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo curl -sd "ID=26&Type=Card&Name=King" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=26&Type=Card&Name=King" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo curl -sd "ID=39&Type=Card&Name=King" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=39&Type=Card&Name=King" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo curl -sd "ID=52&Type=Card&Name=King" "http://localhost:8182/emptygraph/vertices/"
curl -sd "ID=52&Type=Card&Name=King" "http://localhost:8182/emptygraph/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
echo -----------------------------------------
echo ---
echo --
echo -
echo .

echo -----------------------------------------
echo .   ----[ Check an Ace vertex ]----
echo -----------------------------------------
echo curl -sX GET "http://localhost:8182/emptygraph/indices/vertices?key=ID&value=40"
curl -sX GET "http://localhost:8182/emptygraph/indices/vertices?key=ID&value=40" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more
rem curl -sX GET "http://localhost:8182/emptygraph/indices/vertices/" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more

echo -----------------------------------------
echo .   ----[ Check a King vertex ]----
echo -----------------------------------------
echo curl -sX GET "http://localhost:8182/emptygraph/indices/vertices?key=ID&value=52"
curl -sX GET "http://localhost:8182/emptygraph/indices/vertices?key=ID&value=52" | groovy -e "println(groovy.json.JsonOutput.prettyPrint(System.in.text))" | more

echo -----------------------------------------
echo * * * *  Some Notes on the Above  * * * *
echo -----------------------------------------
echo * 
echo * This script creates vertices and indices, but 
echo * does not try to create edges (because of the 
echo * need to reuse tuple IDs from previous API calls).
echo *   
echo * Most of the HTTP Response printouts above have a 
echo * field {"results": {"_id": x, ...}.  Creating
echo * edges requires capturing two returned _id fields
echo * from created vertices and POSTing them as the 
echo * _outV and _inV fields of an edge creation command,
echo * a task only a Microsoft zionist would want to 
echo * attempt with MS-DOS batch commands.
echo * 
echo * Instead please see the second example that uses a
echo * Groovy script to do all of the above and more (and, 
echo * it is platform-independant, of course).
echo * 
echo -----------------------------------------
echo * 
echo * Created by Martin "Hasan" Bramwell as a miniscule
echo * contribution to the wonderful Tinkerpop tool set:
echo * http://www.tinkerpop.com/
echo * 
echo * You should find a link to the latest version of  
echo * this script somewhere on this page here:
echo * https://github.com/tinkerpop/rexster/wiki/Basic-REST-API
echo * 
echo -----------------------------------------
echo * EOF

