@Grab("net.sf.json-lib:json-lib:2.4:jdk15")
@Grab(group="org.codehaus.groovy.modules.http-builder",module="http-builder", version="0.5.1" )

import groovyx.net.http.RESTClient
import groovyx.net.http.ParserRegistry

import groovy.json.JsonOutput
import groovy.util.slurpersupport.GPathResult
import static groovyx.net.http.ContentType.JSON
import static groovyx.net.http.ContentType.URLENC

import java.lang.Character;
 
/*
 * This is a Groovy demo for some of the REST calls to the Neo4j Graph Database
 * through reXster.  The full list of calls can be found here:
 *    https://github.com/tinkerpop/rexster/wiki/Basic-REST-API
 * 
 * It stores a crude ontology of playing cards from data taken (manually) from Wikipedia here
 *    http://en.wikipedia.org/wiki/Playing_cards
 *   
 * Decks, Suits and Cards are stored as vertices
 * 
 * Card values are a property of the Edge which relates a Card to a Deck
 * 
 * Each Card is related to one of the Suits by an Edge
 *  
 */

/*
 * Some basic definitions
 */

//  Identification of the host and database proxy interface
def urlGraphDatabase = "http://localhost:8182/emptygraph/"
neo4jsample = new RESTClient( urlGraphDatabase )

// Define Suits 
def uniCodeBaseNumber = 126976
def suits = 
	[
		  [Name:"Spades", Id:100, UCBlack:(("\u2660")), UCWhite:(("\u2664")), UCFrag:160]
		, [Name:"Hearts", Id:200, UCBlack:(("\u2665")), UCWhite:(("\u2661")), UCFrag:176]
		, [Name:"Diamonds", Id:300, UCBlack:(("\u2666")), UCWhite:(("\u2662")), UCFrag:192]
		, [Name:"Clubs", Id:400, UCBlack:(("\u2663")), UCWhite:(("\u2667")), UCFrag:208]
	]
	
// Define two different Decks of Cards
def allCardNames = ["Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Knight", "Queen", "King"]

def westernCardNames = allCardNames.clone()
westernCardNames.remove("Knight")

// We get this back from each REST command
def REST_Response


//  Prettification stuff
def topFrm = "-----------------------------------------\n"
def botFrm = "\n-----------------------------------------"


/*
 * This shows that reXster understands the HEAD command of HTTP
 * Obviously it is far from adequate for any serious system 
 */
println(topFrm + "       ----[ Test connection ]----     " + botFrm)
try {
    REST_Response = neo4jsample.head (path : "indices")
	println "Got request status ${REST_Response.status} from ${urlGraphDatabase}"
} catch( ex ) { 
	println "Got request status ${ex.response} from ${urlGraphDatabase}"
	// The exception is used for flow control but has access to the response as well:
	assert ex.response.status == 404
}


/*
 * This shows that an HTTP DELETE on the database itself, flushes the toilet on everything
 */
println(topFrm + "      ----[ Evacuate database ]----     " + botFrm)
REST_Response = neo4jsample.delete( path : "" )
assert REST_Response.status != "200", "Database evacuation failed ${REST_Response.status}"
println ("Response : " + REST_Response.data)



/*
 * Having flushed everything we need to create an index
 * Shows one use of and HTTP POST on reXster
 */
println(topFrm + "----[ Recreate the index \"vertices\" ]----" + botFrm)
REST_Response = neo4jsample.post( 
	   path : "indices/vertices"
	, query : ["class":"vertex", "type":"automatic", "keys":"[ID]"]
)
println ("Response : " + REST_Response.data.results)



/*
 * This uses an HTTP GET to verify that the index was created correctly
 */
println(topFrm + "        ----[ List indices ]----" + botFrm)
REST_Response = neo4jsample.get( path : "indices")
println ("Response : " + REST_Response.data.results)




/*
 * Using POST again, we loop through the Suits creating a vertex for each one.
 * Note that, since we will need to refer back to them later we MUST record
 * their database unique ID codes, obtained from the response 
 */
println(topFrm + "        ----[ Create suits ]----" + botFrm)
def mapSuits = [:]
def spec = [:]
def pk = -1
suits.each { suit ->
	spec = [ID:suit["Id"], Type:"Suit", Name:suit["Name"], UCBlack:suit["UCBlack"], UCWhite:suit["UCWhite"], UCFrag:suit["UCFrag"]]
	REST_Response = neo4jsample.post(path : "vertices", query : spec)
	pk = REST_Response.data.results._id   //  We extract the unique ID ... 
	mapSuits.put(suit["Name"], [ID:suit["Id"], PK:(pk)])  //  ... and remember it here
	println ("Response : " + REST_Response.data.results)
}

/*
 * Here we POST more vertices, one for each of the two decks we will define.
 */
println(topFrm + "  ----[ Create 56 card deck ]----" + botFrm)
def deckMAT = [Name:"Minor Arcana Tarot", Id:1, Type:"Deck", UCFrag:126976]
REST_Response = neo4jsample.post(path : "vertices", query : (deckMAT))
println ("Response : " + REST_Response.data.results)
def idMAT = REST_Response.data.results._id


println(topFrm + "  ----[ Create 52 card deck ]----" + botFrm)
def deckWest = [Name:"Western", Id:2, Type:"Deck", UCFrag:126976]
REST_Response = neo4jsample.post(path : "vertices", query : (deckWest))
println ("Response : " + REST_Response.data.results)
def idWest = REST_Response.data.results._id


/*
* The final job is to record all 56 playing cards and relate them by integer value to our
* two decks
*/
println(topFrm + "        ----[ Create cards ]----" + botFrm)
def cardsMAT = [:]
def cardsWestern = [:]
def fk = -1
def numCard = numUC = 0
def valMAT = valWest = 1
suits.each { suit ->
	fk = mapSuits[suit["Name"]]["PK"]
	fragUC = suit["UCFrag"]
	allCardNames.each { card ->
		numCard = valMAT + suit["Id"]
		numUC = uniCodeBaseNumber + fragUC + valMAT
		
		REST_Response = neo4jsample.post(
			   path : "vertices"
			, query : [   ID:(numCard), Type:"Card", Name:card, UCCode:(numUC)  ]
		)
		pk = REST_Response.data.results._id
		
		//  Relate the card to its Suit
		REST_Response = neo4jsample.post(
			   path : "edges"
			, query : [  _outV:(pk), _label:"ofSuit", _inV:(fk)  ]
		)
		
		//  Stuff the card into a local map in case we want to reuse its properties later.
//		spec = [ID:(numCard), Type:"Card", Name:(card), PK:(pk), UCCode:(numUC), SuitFK:(fk)] 
//		cardsMAT.put("${card} of ${suit["Name"]}",spec)

		
		println ("The ${card} of ${suit["Name"]} has value :")
		

		//  Relate the card to 56 card deck
		REST_Response = neo4jsample.post(
			  path : "edges"
			, query : [  _outV:(pk), _label:"ofDeck", _inV:(idMAT), Val:valMAT  ]
		)
		println (" -- ${valMAT} in the Major Arcana Tarot deck and ")
		

		//  Relate the card to 52 card deck
		if (!card.equals("Knight")) {
			
			REST_Response = neo4jsample.post(
				   path : "edges"
				, query : [  _outV:(pk), _label:"ofDeck", _inV:(idWest), Val:valWest  ]
			)
			println (" -- ${valWest} in the Western deck.")
			valWest++
	    }
		
		valMAT++
	}
	valMAT = 1
	valWest = 1
}

println(topFrm + "        ----[ Finished ]----" + botFrm + botFrm)
println("Now running the following eight commands on Gremlin ")
println("should obtain the results indicated below:")
println("")
println("- - - - - - - ")
println("")
println("g.V{it.Name==\"Western\"}")
println("western = g.v(${idWest})  //  Be sure to use the same ID as returned by the preceding command.")
println("western.Type")
println("cardNames = []")
println("cardValues = []")
println("western.inE{it.label==\"ofDeck\"}.outV.outE{it.label==\"ofSuit\"}.inV{it.Name==\"Hearts\"}.back(4).Name >> cardNames")
println("western.inE{it.label==\"ofDeck\"}.outV.outE{it.label==\"ofSuit\"}.inV{it.Name==\"Hearts\"}.back(6).Val >> cardValues")
println("itrCards = cardNames.iterator();ii = 0;while(itrCards.hasNext()){println \"The \" + itrCards.next() + \" of Spades has value \" + cardValues.get(ii++) }")
println("")
println("- - - - - - - ")
println("")
println("/*")
println(" *")
println("Gremlin 1.1-SNAPSHOT")
println("         \\,,,/")
println("         (o o)")
println("-----oOOo-(_)-oOOo-----")
println("gremlin>  g.V{it.Name==\"Western\"}")
println("==>v[${idWest}]")
println("")
println("gremlin>  western = g.v(${idWest})")
println("==>v[${idWest}]")
println("")
println("gremlin>  western.Type")
println("==>Deck")
println("")
println("gremlin>  cardNames = []")
println("==>")
println("")
println("gremlin>  cardValues = []")
println("==>")
println("")
println("gremlin>  western.inE{it.label==\"ofDeck\"}.outV.outE{it.label==\"ofSuit\"}.inV{it.Name==\"Hearts\"}.back(4).Name >> cardNames")
println("==>King")
println("==>Queen")
println("==>Jack")
println("==>Ten")
println("==>Nine")
println("==>Eight")
println("==>Seven")
println("==>Six")
println("==>Five")
println("==>Four")
println("==>Three")
println("==>Two")
println("==>Ace")
println("")
println("gremlin>  western.inE{it.label==\"ofDeck\"}.outV.outE{it.label==\"ofSuit\"}.inV{it.Name==\"Hearts\"}.back(6).Val >> cardValues")
println("==>13")
println("==>12")
println("==>11")
println("==>10")
println("==>9")
println("==>8")
println("==>7")
println("==>6")
println("==>5")
println("==>4")
println("==>3")
println("==>2")
println("==>1")
println("")
println("gremlin>  itrCards = cardNames.iterator();ii = 0;while(itrCards.hasNext()){println \"The \" + itrCards.next() + \" of Spades has value \" + cardValues.get(ii++) }")
println("==>The King of Spades has value 13")
println("==>The Queen of Spades has value 12")
println("==>The Jack of Spades has value 11")
println("==>The Ten of Spades has value 10")
println("==>The Nine of Spades has value 9")
println("==>The Eight of Spades has value 8")
println("==>The Seven of Spades has value 7")
println("==>The Six of Spades has value 6")
println("==>The Five of Spades has value 5")
println("==>The Four of Spades has value 4")
println("==>The Three of Spades has value 3")
println("==>The Two of Spades has value 2")
println("==>The Ace of Spades has value 1")
println("gremlin>")

		 
println("*")
println("*/")


