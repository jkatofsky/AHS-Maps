/*

 Don't think we'd forget the header!
 
 AHS Maps
 By Josh Katofsky, Kieran O'Day, and George Barker
 Created in May-June of 2017
 Mr. Sheldon C Block - AP Computer Science A
 
 This Processing sketch contains the guts that power the storing, processing, and displaying of our AHS Maps project.
 Using the concepts of graph theory, the breadth-first search algorithm, trigonometry, and much more, we have created a program which will
 provide the user with paths through most of Arlington High School along with written directions.
 
 The sketch is designed to be used in tandem with HTML elements and pure JavaScript which modify its state and recieve data it outputs.
 Run this project in the browser to experience it correctly.
 Also, take a gander at the HTML file for the code which Josh spent much of his time writing.
 */

//The instance of our Map class that runs the entire program
Map ahsMap;

void setup() {

  //A good size for retaining detail in the images yet not exceeding the pixels-per-inch of most devices
  size(2000, 1000);
  background (0);
  //Gotta slow down the frame rate when we're dealing with high resolution photos
  frameRate(5);

  //loading the images
  ArrayList<PImage> loadedImages = new ArrayList<PImage>();
  loadedImages.add(null); //This one is so we can 1-index the array
  loadedImages.add(null); //The first floor
  loadedImages.add(loadImage("floor2.png"));
  loadedImages.add(loadImage("floor3.png"));
  loadedImages.add(loadImage("floor4.png"));
  loadedImages.add(loadImage("floor5.png"));
  loadedImages.add(null); //The sixth floor

  //constructing the map
  ahsMap = new Map(loadedImages, getNodesFromCSV("nodes.csv"));

  //setting the next available node ID for any nodes we create while the program's running
  if (mapCreatorMode) {
    try {
      nextID = ahsMap.nodes.get(ahsMap.nodes.size()-1).ID + 1;
    } 
    catch (Exception e) {//essentially, if there's nothing in map's node list, set the nextID to one
      nextID = 1;
    }
  }
}

ArrayList<Node> getNodesFromCSV(String csvName) {

  //An array of string arrays which holds the seperated information of individual nodes
  String [][] nodesToLoad;
  //An arraylist of node objects to build up
  ArrayList<Node> loadedNodes = new ArrayList<Node>();

  try {
    //getting all of the lines from the file
    String [] nodeLines = loadStrings(csvName);
    
    //setting the two-dimensional array based on the file
    nodesToLoad = new String [nodeLines.length][];
    for (int i = 0; i < nodesToLoad.length; i ++) {
      nodesToLoad[i] = split(nodeLines[i], ",");
    }

    //constructing the nodes with information from this two-dimentional array of info
    for (String [] nodeIsh : nodesToLoad) {
      int ID = parseInt(nodeIsh[0]);
      String name = nodeIsh[1];
      int floor = parseInt(nodeIsh[2]);
      float  x = parseFloat(nodeIsh[3]);
      float  y = parseFloat(nodeIsh[4]);
      Node loadedBadLarry = new Node (ID, name, floor, x, y);
      loadedNodes.add(loadedBadLarry);
    }

    //adding the proper adjacent nodes (found in the original string 2D-array) to every node after they're constructed
    for (int i = 0; i < nodesToLoad.length; i ++) {
      String [] nodeIsh = nodesToLoad[i];
      for (int j = 5; j < nodeIsh.length; j++) {
        Node adjBadLarry = getNodeFromListWithID(loadedNodes, parseInt(nodeIsh[j]));
        if (adjBadLarry != null) {
          loadedNodes.get(i).addAdjNode(adjBadLarry);
        }
      }
    }

    return loadedNodes;
  }
  catch(Exception e) {
    return null;
  }
}

void draw() {
  ahsMap.updateDisplay();
}
