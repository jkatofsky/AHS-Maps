class Node {

  int ID; //the unique identifier of the node
  String name; //the name of the node
  int floor; //the floor that the node is on
  float  x, y; //the relative x and y locations of the node
  ArrayList <Node> adjNodes; //the nodes which are adjacent to this node

  Node (int ID, String name, int floor, float x, float y) {
    //Setting everything based on parameters
    this.ID = ID;
    this.name = name;
    this.floor = floor;
    this.x = x;
    this.y = y;

    //This is set to an empty list, as it needs to be populated through a method
    adjNodes = new ArrayList<Node>();
  }

  //This constructor is for the map creator mode as opposed to reading in from the file,
  //where the Node's ID's are automatically set given a global variable
  Node (String name, int floor, float x, float y) {
    ID = nextID;
    nextID ++;
    this.name = name;
    this.floor = floor;
    this.x = x;
    this.y = y;

    adjNodes = new ArrayList<Node>();
  }

  //Adding an adjacent node with one parameter - this is the one that's called
  void addAdjNode(Node other) {
    addAdjNode(other, true);
  }
  //An override that makes it so Nodes will add back adjacencies, but stops it from looping infinitely by including a boolean parameter
  void addAdjNode(Node other, boolean addBack) {
    if (!adjNodes.contains(other))
      adjNodes.add(other);
    if (addBack) {
      other.addAdjNode(this, false);
    }
  }

  //For easy writing to the CSV file
  public String toCSVLine() {
    String line = null;

    line = ID + "," + name + "," + floor + "," + x + "," + y;
    for (int i = 0; i < adjNodes.size (); i ++) {
      line+= ",";
      line += adjNodes.get(i).ID;
    }
    return line;
  }

  //To make pretty println's for map creator mode
  public String toString () {
    String string = null;

    string =
      "ID: " + ID +
      " | Name: " + name  +
      " | Floor: " + floor +
      " | Coordinates: (" + x + "," + y + ")" +
      " | Adjacent Nodes: ";

    for (int i = 0; i < adjNodes.size (); i ++) {
      string += "" + adjNodes.get(i).ID;
      if (i != adjNodes.size()-1) {
        string += ",";
      }
    }

    return string;
  }

  //Given that every node has a unique ID, they are equal if they have the same ID
  public boolean equals (Object other) {

    if (!(other instanceof Node)) {
      return false;
    }
    Node n = (Node) other;
    if (n.ID == ID)
      return true;
    else 
    return false;
  }
}

Node getNodeFromListWithID(ArrayList<Node> nodeList, int ID) {
  for (Node givenNode : nodeList) {
    if (givenNode.ID == ID) {
      return givenNode;
    }
  }
  return null;
}

Node getNodeFromListWithName(ArrayList<Node> nodeList, String name) {

  name = name.toLowerCase();
  name = name.replaceAll(" ", "");

  if (name.equals("stairs") || name.equals("corner")) {
    return null;
  }

  if (name.startsWith("room")) {
    name = name.substring(4);
  }

  if (name.startsWith("the")) {
    name = name.substring(3);
  }

  for (Node givenNode : nodeList) {

    String nameComparator = givenNode.name;
    nameComparator = nameComparator.toLowerCase();
    nameComparator = nameComparator.replaceAll(" ", "");

    if (nameComparator.equals(name)) {
      return givenNode;
    }
  }

  return null;
}
