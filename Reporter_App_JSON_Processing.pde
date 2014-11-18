/* 
This is a quick sketch to illustrate the basics of loading a JSON file exported out of Report App (@GetReporter) into Processing. 
This sketch shows you how to parse "Yes/No" type questions and count the number of responses for each answer. 
I've included a small amount of error checking based on the kinds of issues I've run across in using the JSON exported data.
There is a more fulsome implementation of this code which uses the date time of each answer to create a histogram 
showing the frequency of times you've answered yes or no to a question during a period of time in the day. The code
is online here:
https://github.com/sspboyd/Reporter_App_Histogram

Stephen Boyd
@sspboyd
sspboyd.ca
*/

//Declare Globals
JSONObject raj; // This is the variable that we load the JSON file into. It's not much use to us after that.
JSONArray snapshots; // This is the variable that holds all the 'snapshots' recorded by Reporter App. We'll use this variable a lot.
String question; // This will be the exact text of the Yes/No questions to be parsed.



/*////////////////////////////////////////
 SETUP
 ////////////////////////////////////////*/

void setup() {
  size(400, 300);

  // initialize global vars to hold the JSON data from Reporter App
  raj = loadJSONObject("reporter-export-20140903.json"); // this file has to be in your /data directory. I've included a small sample file.
  
  // The next line of code is the first of many JSON Arrays and Objects we'll be creating. 
  // This one grabs the 'snapshots' out of the raj JSONObject variable
  snapshots = raj.getJSONArray("snapshots"); 

  noLoop();
  println("setup done: " + nf(millis() / 1000.0, 1, 2));
}



/*////////////////////////////////////////
 DRAW
 ////////////////////////////////////////*/

void draw() {
  background(255);

  // Remember to change the question variable to reflect your questions when you're using your own data.
  question = "Have you been productive over the last couple of hours?";
  parseYesNoQuestions(question);
  
  question = "Did you eat after 9pm?";
  parseYesNoQuestions(question);

  fill(0);
  text("Check the console for the output from this sketch. \n @sspboyd", 15, height/2-20);
}



/*////////////////////////////////////////
 My methods
 ////////////////////////////////////////*/

void parseYesNoQuestions(String _q) {
  String q = _q;
  int yesCount = 0;
  int noCount = 0;
  int missingQuestionPromptCount = 0; // I noticed that some of the responses were missing question prompts so I added a check to the code to test for it.

  // Begin parsing the JSON from Reporter App
  for (int i = 0; i < snapshots.size(); i+=1) { // iterate through every snapshot in the snapshots array...
    JSONObject snap = snapshots.getJSONObject(i); // create a new json object (snap) with the current snapshot

    String sdts = snap.getString("date"); // sdts = snapshot datetime string. This is an example of how to grab variables in the snap json object.

    JSONArray resps = snap.getJSONArray("responses"); // Create a new array to grab the responses from the current snapshot
    for (int j = 0; j < resps.size(); j+=1) {  // iterate through each response
      JSONObject resp = resps.getJSONObject(j); // Create a new json object called resp to grab each of the responses individually
      // println("resp == " + resp);
      String questionPrompt = ""; // declare and initialize this variable before it's used in the if() statement coming next.
      // This next line was hard to figure out but very important in successfully parsing the JSON. 
      // The hasKey() method is not documented in the Processing Reference online but you can find it in the source code documentation here:
      // http://processing.org/reference/javadoc/core/processing/data/JSONObject.html#hasKey(java.lang.String)
      // Super useful to test if the JSONObject has a key that matches the string you supply it. In this case, I'm checking to see if there is a key called "questionPrompt".
      if (resp.hasKey("questionPrompt")) {  // test to make sure there is a question prompt associated with this response. I've found a few times that responses are missing question prompts!
        questionPrompt = resp.getString("questionPrompt");
        // println("resp question: " + question);
      } else {
        missingQuestionPromptCount += 1;
        // println("Possible Missing Question Prompt at " + sdts); // using the date time stamp as a way to help find the error in the JSON. Go go search function!
      }

      if (questionPrompt.equals(q) == true) { // check to see if the questionPrompt string matches the question we're looking for...
        if (resp.hasKey("answeredOptions")) {  // again, check to see if the resp JSONObject has a key called "answeredOptions"
          JSONArray ans = resp.getJSONArray("answeredOptions"); // create another JSONArray of the answers
          if (ans.getString(0).equals("Yes")) {
            yesCount += 1;
          } else { // a bit sloppy here to assume that if the answer isn't Yes then it must be No... but you get the idea.
            noCount +=1;
          }
        }
      }
    }
  }
  // Print out the results!
  println("\n\nQuestion: " + q); // added a couple extra line breaks at the beginning to aid readability
  println("Yes responses: " + yesCount);
  println("No responses: " + noCount);
  println("Responses missing question prompts (result of a bug?): " + missingQuestionPromptCount);
 }