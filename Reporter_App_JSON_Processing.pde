// This is a quick sketch to illustrate the basics of loading a JSON file exported out of Report App (@ReporterApp) into Processing. 
// This sketch shows you how to parse "Yes/No" type questions and count the number of responses for each answer. 
// I've included a small amount of error checking based on the kinds of issues I've run across in using the JSON exported data.
// There is a more fulsome implementation of this code which uses the date time of each answer to create a histogram 
// showing the frequency of times you've answered yes or no to a question during a period of time in the day. The code
// is online here:
// https://github.com/sspboyd/Reporter_App_Histogram
// 
// Stephen Boyd, 2014
// @sspboyd

JSONObject raj;
JSONArray snapshots;

PFont detailF;

String question; // This will be the exact text of the Yes/No question to be parsed.


//Declare Globals
int rSn; // randomSeed number. put into var so can be saved in file name. defaults to 47
final float PHI = 0.618033989;


// Declare Positioning Variables
float margin;
float PLOT_X1, PLOT_X2, PLOT_Y1, PLOT_Y2, PLOT_W, PLOT_H;


/*////////////////////////////////////////
 SETUP
 ////////////////////////////////////////*/

void setup() {
  size(400, 300);

  detailF = createFont("Helvetica", 14);

  margin = width * pow(PHI, 7);
  println("margin: " + margin);
  PLOT_X1 = margin;
  PLOT_X2 = width-margin;
  PLOT_Y1 = margin;
  PLOT_Y2 = height - (margin + margin);
  PLOT_W = PLOT_X2 - PLOT_X1;
  PLOT_H = PLOT_Y2 - PLOT_Y1;

  rSn = 47; // 29, 18;
  randomSeed(rSn);

  // Global Vars to hold the JSON data from Reporter App
  raj = loadJSONObject("reporter-export-20140903.json");
  snapshots = raj.getJSONArray("snapshots");


  noLoop();
  println("setup done: " + nf(millis() / 1000.0, 1, 2));
}


/*////////////////////////////////////////
 DRAW
 ////////////////////////////////////////*/

void draw() {
  background(255);

  // Pick one of your Yes/No questions
  question = "Have you been productive over the last couple of hours?";
  parseYesNoQuestions(question);
  
  question = "Did you eat after 9pm?";
  parseYesNoQuestions(question);

  renderSig();
}


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
      }
      else {
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


void renderSig(){
  fill(100);
  textFont(detailF);
  text("sspboyd", PLOT_X2-textWidth("sspboyd"), PLOT_Y2 + margin);
}

void keyPressed() {
  if (key == 'S') screenCap(".tif");
}

/*////////////////////////////////////////
 UTILITY FUNCTIONS
 ////////////////////////////////////////*/

String generateSaveImgFileName(String fileType) {
  String fileName;
  // save functionality in here
  String outputDir = "out/";
  String sketchName = getSketchName() + "-";
  String randomSeedNum = "rS" + rSn + "-";
  String dateTimeStamp = "" + year() + nf(month(), 2) + nf(day(), 2) + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
  fileName = outputDir + sketchName + dateTimeStamp + randomSeedNum + fileType;
  return fileName;
}

void screenCap(String fileType) {
  String saveName = generateSaveImgFileName(fileType);
  save(saveName);
  println("Screen shot saved to: " + saveName);
}

String getSketchName() {
  String[] path = split(sketchPath, "/");
  return path[path.length-1];
}