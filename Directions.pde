/**
 Each connect holds two nodes which are adjacent to each other. Necessary for easily analyzing multiple consecutive nodes to determine whether they create a turn, and if they do which way that turn goes.
 Most methods take in two connects, allowing for easy calculations with 3 nodes. Since connects overlap with one another, two consecutive connects actually contain 3 unique nodes not 4, since the middle overlaps.
 */
class Connect { 
  Node a;
  Node b;
  public Connect (Node a1, Node b1) {//constructor, takes in the two nodes for a connection
    a = a1;
    b = b1;
  }
}
/**
 Calculate the angle between two connections (3 nodes), vital to figure out whether the three nodes create a turn. Uses triangle identities to calculate the angle through cos of angle C.
 */
float calcAngle(Connect one, Connect two) {
  float lengthA; //create a triangle between the three nodes and find the length of each side of the triangle
  float lengthB;
  float lengthC;
  float cosC; //find the cos of the angle representing the turn
  float angle;//use inverse cosine to find the angle
  lengthA = dist (two.a.x, two.a.y, two.b.x, two.b.y);
  lengthB = dist (two.a.x, two.a.y, one.a.x, one.a.y);
  lengthC = dist (one.a.x, one.a.y, two.b.x, two.b.y);
  cosC = ((lengthA * lengthA) + (lengthB * lengthB) - (lengthC * lengthC)) / (2 * lengthA * lengthB); // cosC = (a^2 + b^2 - c^2)/2ab
  if (cosC < -1) //fix and strange rounding errors which would cause math errors and crash program
    cosC = -1;
  if (cosC > 1)
    cosC = 1;
  angle = 57 * (acos (cosC)); //.2958 //convert radians to degrees for easier handling of calculations
  //println ("First: " + one.a.ID + " Second: " + two.a.ID + " Third: " + two.b.ID + " || Angle: " + angle + " Cosine: " + cosC);
  return angle;
}
/**
 Essentially, Directions is just an array of strings to be printed to the user. All other methods are designed to calculate what these strings should say. Directions take in a path and turn it into a string array of turns to take.
 */
class Directions {

  ArrayList <String> directions;//holds all directions to be printed to the user once they are constructed
  ArrayList<Node> curLocation; //list of nodes which the user is at, the nodes between the turn they just passed and the one they are approaching to show what step they are on
  ArrayList <Connect>  connects;//holds all the connections of nodes in the path, (index A)
  boolean [] isTurn; //tells whether each connections is part of a turn, indexed the same way as connects, (index A)
  int index; //index of the directions array which the user is at, used to print the correct directions and determine current location
  ArrayList <Integer> indexOfIntersects;//index in the connects array where turns occur, indexed same as directions, (index B) (not really used in final build)
  Node destination; //destination of the path

  public Directions (Path path) { //constructor takes in a path to set everything up
    directions = new ArrayList<String> ();
    connects = new ArrayList<Connect>();
    indexOfIntersects = new ArrayList <Integer>();
    index = 0;
    setConnects (path); //take path and make it into connects
    setTurns(); //find all the turns in the path
    createDirections (connects); //construct the actual string array
    curLocation = findCurLocation();//find starting location
  }
  void setConnects (Path path) {//goes through all the nodes in a path and divides them into connects, takes the last node and sets it as destination
    if (path.nodes.size()>1) {
      for (int i = 0; i < path.nodes.size ()-1; i ++) {
        connects.add (new Connect (path.nodes.get(i), path.nodes.get(i+1)));
      }
      destination = connects.get(connects.size()-1).b;
    }
  }
  void setTurns () {//sets isTurn array by going through all connects in array and calling method to determine if they are turns or not
    isTurn = new boolean [connects.size()];
    for (int i = 0; i < connects.size ()-1; i ++) {
      isTurn[i] = decideIfTurn (connects.get(i), connects.get(i+1));
    }
    isTurn [connects.size()-1] = true;//always set last connect (desination node) to turn to print directions properly

    for (int i = 0; i < isTurn.length; i ++) {
      if (isTurn[i])
        indexOfIntersects.add(i);
    }
  }
  int calculateIntersections () {//calculates the number of intersections (turns) in a path by checking boolean array
    int num = 0;
    for (int i = 0; i < isTurn.length; i ++) {
      if (isTurn[i])
        num++;
    }
    return num;
  }
  /**
   Find the current nodes which the user is passing over. Creates an array of nodes which will then display on the map the current direction the user is following, plus an additional node to show their upcoming turn.
   */
  ArrayList<Node> findCurLocation () {

    //If we're at the end of the directions, our location is the destination
    if (index == directions.size()-1) {
      ArrayList<Node> temp = new ArrayList<Node>();
      temp.add(destination);
      return temp;
    }

    int [] intersectIndex = new int [calculateIntersections()];//int array which holds the indexs of turns in the directions array
    int check = 0;//just an index to go through creating the intersectIndex array with no errors, nothing fancy here
    int indexHold = index;//temp variable to store the index of directions the user is currently in, just made the temp variable to minimize any chance of errors by changing global index
    int check2 = 0;//index that will run through starting point of connects array where the user is to the end of the connects array, runs from beginning of previous turn to next turn
    ArrayList <Node> retArray = new ArrayList<Node>(); //array of nodes to be returned after construction
    for (int i = 0; i < isTurn.length; i ++) {//loop to find intersections in main directions array of turns
      if (isTurn[i]) {//if its a turn, store its index
        intersectIndex [check] = i;
        check++;
      }
    }
    if (intersectIndex.length > 1) {//if there are any turns, start to run through the turns
      if (indexHold == 0) {//if loop is checking from the starting turn
        while (check2 != intersectIndex [indexHold+1]) {//as long as check2 hasn't made it all the way to the next turn, keep adding nodes to the list of current location nodes
          retArray.add(connects.get(check2).a);//adding a and b does add duplicates, but this doesn't actually matter in the display method and adding both a and b ensures no nodes are left behind
          retArray.add(connects.get(check2).b);
          check2++;
        }
      }
    }
    if (indexHold < intersectIndex.length-1) {//if the index to check is less than the size of instersectIndex array (this number corresponds to number of turns)
      check2 = intersectIndex [indexHold];//set starting index to index of the first turn
      while (check2 < intersectIndex [indexHold+1]) {//run through all the indexes until the next turn is reached

        retArray.add(connects.get(check2).a);
        retArray.add(connects.get(check2).b);
        check2++;
      }
    }

    //If the current location could not be calculated, return null
    if (retArray.size() == 0) {
      return null;
    }

    return retArray;
  }

  boolean decideIfTurn (Connect one, Connect two) {//calculates angle, and as long as the angle isn't nearly a straight line returns true for a turn
    if (calcAngle (one, two) < 140) {
      return true;
    }
    if (one.b.name.equals ("STAIRS"))//all stairs create text, so all stairs are turns
        return true;
    return false;
  }
  /**
   Figures out if a turn is a left turn or a right turn, returns string left or right since it is immediately added to a string of directions.
   Tried a variety of different approaches, the other notable method was using the angle measurement to see if it was going left or right, but small differences could lead to incorrect responses.
   Since this relies on big differences in Xs and Ys, (since it constucts a triangle), a small misallignment of nodes would not create a wrong output.
   Builds a triangle and finds where the midpoint of the hypotenuse is, and through this is can find if it is a left or right turn.
   */
  String leftRight (Connect one, Connect two) {
    PVector midpoint = new PVector();//holds x and y of the midpoint of the hypotenuse of the triangle.
    midpoint.x = (one.a.x + two.b.x)/2; //just basic midpoint math
    midpoint.y = (one.a.y + two.b.y)/2;
    if (midpoint.y > two.a.y) {//these overarching if statements based on y determine is the user is coming "up" or "down" the map, setting the relativity needed to determine right or left
      if (two.b.x > one.a.x)//xs, with the knowledge of if the player is coming up or down the map, are now all that is needed to determine if the user must go left or right
        return "right";
      if (one.a.x > two.b.x)
        return "left";
    }
    if (midpoint.y < two.a.y) {
      if (two.b.x < one.a.x)
        return "right";
      if (two.b.x > one.a.x)
        return "left";
    }
    return "ERROR";
  }
  /**
   Takes all the information about turns to find the actual line of text that must be printed for the user to follow.
   */
  String outputLineDirect (Connect one, Connect two, boolean isTurn, int index) {

    String output = "ERROR: Directions for this step could not be printed, please follow the path displayed on the map.";
    if (!isTurn) {//if there is no turn, just end the process, this string will never be used anywhere
      return "X";
    } else if (two.b.equals(destination)) {//if user is approaching destination, display this text
      output = "You are now approaching your desination.";
    } else if (one.b.name.equals("STAIRS")) {//handle stairs properly
      output = "Follow the stairs until you reach floor " + two.b.floor + ".";
    } else {
      String leftRightString;//string to determine whether text should say left or right
      leftRightString = leftRight (one, two);
      String oneBName = one.b.name;//these strings allow for renaming the nodes to display user friendly text, rather than just node names
      boolean oneBNamed = false;
      String oneAName = one.a.name;
      boolean oneANamed = false;
      String twoBName = two.b.name;
      boolean twoBNamed = false;

      if (oneBName.equals ("STAIRS")) {
        oneBName = "the stairs";
        oneBNamed = true;
      }
      
      if (oneAName.equals ("STAIRS")) {
        oneAName = "the stairs";
        oneANamed = true;
      }
      
      if (twoBName.equals ("STAIRS")) {
        twoBName = "the stairs";
        twoBNamed = true;
      }
      
      if (oneBName.equals ("CORNER")) {
        oneBName = "the corner";
        oneBNamed = true;
      }
      
      if (oneAName.equals ("CORNER")) {
        oneAName = "the corner";
        oneANamed = true;
      }
      
      if (twoBName.equals ("CORNER")) {
        twoBName = "the corner";
        twoBNamed = true;
      }

      if (gotLetters (oneBName) && !oneBNamed) {//if there is letters, then alter name appropriately
        oneBName = "the " + oneBName;
        oneBNamed = true;
      }
      if (!oneBNamed)//no letter? then add a Room in front of the number
        oneBName = "Room " + oneBName;

      if (gotLetters (oneAName) && !oneANamed) {
        oneAName = "the " + oneAName;
        oneANamed = true;
      }
      if (!oneANamed)
        oneAName = "Room " + oneAName;

      if (gotLetters (twoBName) && !twoBNamed) {
        twoBName = "the " + twoBName;
        twoBNamed = true;
      }
      if (!twoBNamed)
        twoBName = "Room " + twoBName;

      //very ugly way of determining what should be printed for the user
      //varies greatly depending on whether the user is passing through corners, since the text cannot say "Walk through a CORNER", all possible combinations must have a set return string present
      if (one.a.name.toUpperCase().equals ("CORNER") && two.b.name.toUpperCase().equals ("CORNER") && !one.b.name.toUpperCase().equals ("CORNER")) 
        return firstDirection () + oneBName + "," + " turn " + leftRightString + " and continue forward.";
      if (two.b.name.toUpperCase().equals ("CORNER") && !one.b.name.toUpperCase().equals ("CORNER") && !one.a.name.toUpperCase().equals ("CORNER"))
        return firstDirection () + oneBName + "," + " turn " + leftRightString + " and continue forward.";
      if (one.a.name.toUpperCase().equals ("CORNER") && (two.b.name.toUpperCase().equals ("CORNER")) && (two.a.name.toUpperCase().equals ("CORNER")))
        return absurdlyAnnoyingCornDirection() + " turn " + leftRightString +  " and continue forward.";
      if (!two.b.name.toUpperCase().equals ("CORNER") && !one.a.name.toUpperCase().equals ("CORNER"))
        return firstDirection () + oneBName + "," + " turn " + leftRightString + " and continue to " + twoBName;
      if (one.b.name.toUpperCase().equals ("CORNER") && two.b.name.toUpperCase().equals ("CORNER"))
        return firstDirection () + oneAName + "," + " turn " + leftRightString + " and continue to follow the hallway forward.";
      if (one.b.name.toUpperCase().equals ("CORNER") && (one.a.name.toUpperCase().equals ("CORNER")) && !two.b.name.toUpperCase().equals ("CORNER"))
        return annoyingCornDirection ()+ twoBName + " by turning " + leftRightString + ".";
      if (one.a.name.toUpperCase().equals ("CORNER") && !(two.b.name.toUpperCase().equals ("CORNER")) && !(two.a.name.toUpperCase().equals ("CORNER")))
        return firstDirection () + oneAName + "," + " turn " + leftRightString +  " and continue forward.";
    }

    return output;
  }

  void createDirections (ArrayList <Connect> connects) {//go through all outputs from connects and as long as they are returning real directions, add them to the directions array
    for (int i = 0; i < connects.size ()-1; i ++) {
      if (!(outputLineDirect(connects.get(i), connects.get(i+1), isTurn [i], index).equals("X"))) {
        directions.add(outputLineDirect(connects.get(i), connects.get(i+1), isTurn [i], index));
      }
    }
    if (directions.size() == 0) {//if there are no turns in the path, output this
      directions.add(0, "Follow the path straight towards your desitination.");
    }
    directions.add ("You have arrived.");//final direction, you made it
  }
  void increaseIndex () {//increase index of directions to be displayed, used by outside classes
    if (index < directions.size ()-1) {
      index++;
      curLocation = findCurLocation();
    }
  }
  void decreaseIndex() {//same as above, just down instead of up
    if (index > 0) {
      index--;
      curLocation = findCurLocation();
    }
  }
  String getCurrentDirection () {//return the direction that should be printed
    return directions.get(index);
  }
  void testOutDirections () {//testing method only
    for (int i = 0; i < directions.size (); i ++) {
      //println (directions.get(i));
    }
  }

  boolean gotLetters (String str) {//goes through a string to see whether is has any letters, needed to find if a node is a room or a location (rm 409 vs old hall)
    String letters = "QWERTYUIOPASDFGHJKLZXCVBNM";
    for (int i = 0; i < str.length (); i ++) {
      if (letters.indexOf (str.substring (i, i + 1)) != -1)
        return true;
    }
    return false;
  }

  String firstDirection () {//here to add variation to the directions, chooses a random string from a set of strings with identical meanings
    String [] randoDirect = new String [5];
    randoDirect [0] = "After passing ";
    randoDirect [1] = "Once you have passed ";
    randoDirect [2] = "Just after ";
    randoDirect [3] = "After reaching ";
    randoDirect [4] = "Just past ";
    return randoDirect [int ((random (0, 5)))];
  }
  String annoyingCornDirection () {//same as above, just occuring in a different and more annoying case
    String [] randoDirect = new String [3];
    randoDirect [0] = "Continue towards ";
    randoDirect [1] = "Walk towards ";
    randoDirect [2] = "Head to ";
    return randoDirect [int ((random (0, 3)))];
  }
  String absurdlyAnnoyingCornDirection () {//same idea, just most annoying case
    String [] randoDirect = new String [3];
    randoDirect [0] = "Upon reaching the next intersection, ";
    randoDirect [1] = "Once you reach the next intersection, ";
    randoDirect [2] = "At the next intersection, ";
    return randoDirect [int ((random (0, 3)))];
  }
}

