//Everything required to create new nodes lives here

//When this is set to false, we cannot trigger any part of the data tool
boolean mapCreatorMode = false;

//The state of the program, required to make the typing input work
final int TYPING = 0, JCHILLIN = 1;
int state = JCHILLIN;

//The string which will keep track of input, and the valid characters to be inputted
String input;
String validInputChars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz, ";

//To automate the ID's of new nodes
int nextID;

void mouseClicked() {

  if (mapCreatorMode) {

    //We've got a blank canvas that we're about to paint with greatness
    input = "";

    //Declare appropriate variables for creating a new node with every click
    String name = "";
    ArrayList <Node> adjNodes = new ArrayList<Node> ();
    float  x, y;
    x = (float)mouseX/width;
    y = (float)mouseY/height;

    //Where the magic happens (see keypressed TYPING state) - the input string is built up
    state = TYPING; //Go to typing state
    println("Input Node information in the format of: <name>,<adj ID 1>,<adj ID 2>,<adj ID 3>,etc");
    while (state == TYPING) {
      noLoop(); //Essentially pause the program while the user types - this is what causes keyPressed to register so well for character input
    }

    //Disecting the input string to set the variables
    String[] nodeIsh = split(input, ",");
    name = nodeIsh[0];
    for (int i = 1; i < nodeIsh.length; i++) {
      adjNodes.add(getNodeFromListWithID(ahsMap.nodes, parseInt(nodeIsh[i])));
    }

    //Constructing the new Node
    Node newBadLarry = new Node(name, ahsMap.curFloor, x, y);
    for (Node adjNode : adjNodes) {
      newBadLarry.addAdjNode(adjNode);
    }

    //Adding it to the map's node list
    ahsMap.nodes.add(newBadLarry);

    //Wiping our canvas clean
    input = "";

    //We can have this here because the subordinate user will never access any of this . . . muahahahahah
    println ("Adding Node: " + newBadLarry);
  }
  
}

void keyPressed () {

  if (mapCreatorMode) {

    switch (state) {

      //In the case that you're typing
    case TYPING:
      if (keyCode == ENTER) {
        state = JCHILLIN;//Return to the normal state of the program
        println();
        loop();//Start the program's loop back up
      } else if (keyCode == BACKSPACE) {
        if (input.length() > 0) {//If there's a character to take off
          input = input.substring (0, input.length()-1); //Take a character off
          print("\b");
        }
      } else if (validInputChars.indexOf(key) != -1) { //If it's a valid input character
        input += key;//Add the character to the string
        print(key);
      }

      break;

      //While you're just chillin, key input does other things
    case JCHILLIN:
      if (keyCode == ENTER) {
        updateCSV();//Saving nodes to the CSV
      } else if (keyCode == BACKSPACE) {
        if (ahsMap.nodes.size() > 0) {
          Node deletedNode = ahsMap.nodes.remove(ahsMap.nodes.size()-1); //if alteast one node in the list, delete the last node in the list
          println("Deleting Node: " + deletedNode);
          nextID--; //Update the next ID in accordance with our lost bretheren
        }
      }
      
      //Chaning the floor with the arrow keys
      if (keyCode == UP) {
        if (ahsMap.curFloor < 5) {
          ahsMap.curFloor++;
        }
      }
      if (keyCode == DOWN) {
        if (ahsMap.curFloor > 2) {
          ahsMap.curFloor--;
        }
      }
      break;
    }
  }
}

void updateCSV() {

  //Setting an array of strings to CSV lines of all the nodes
  String [] nodeCSVLines = new String [ahsMap.nodes.size()];
  for (int i = 0; i < ahsMap.nodes.size (); i ++) {
    nodeCSVLines[i] = ahsMap.nodes.get(i).toCSVLine();
  }

  //Saving CSV file to this aaray
  saveStrings("data/nodes.csv", nodeCSVLines);

  //Reloading the map's nodes based on this updated file
  ahsMap.nodes = getNodesFromCSV("nodes.csv");

  println("Saving all Nodes to nodes.csv");
}
