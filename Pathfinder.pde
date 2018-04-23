//An interface ... because why not? If we wanted to try out different algorithms this would be a way to do so. 
//It give the program the nice central method of findPath
interface Pathfinder {
  Path findPath (Node location, Node destination);
}

//The aptly-named KieranPathFinder, the container for the breadth-first-search algorithm that he wrote
class KieranPathFinder implements Pathfinder {
  //doesnt need any class variables just has a nice function
  KieranPathFinder () {
  }

  //The breadth first search for a path
  Path findPath(Node location, Node destination) {

    ArrayList<Path> posPaths = new ArrayList<Path>();  //All of the possible paths we will find
    ArrayList<Node> starter = new ArrayList<Node>();
    starter.add(location);
    posPaths.add(new Path(starter)); //Adding the possible first path - a Path created from our location

    Path bestPath = null;//The to-be-returned chosen one
    float minDist = 9999999; //An aribtirary large number to start

    int index = 0;
    //For all of the possible paths (a list which will grow in size as the loop runs)
    while (index < posPaths.size ()) {
      Path p = posPaths.get(index);
      //See if the end of this path is where we want to go
      if (p.destination().equals(destination)) {
        if (p.pLength < minDist) { //if it's the shortest one so far
          minDist = p.pLength;
          bestPath = p;
          if (bestPath.pLength > 2) //if the only path you have found is very long
            return bestPath; // give up to save time
        }
      } else if (p.pLength < minDist) {  //if the path hasnt gotten there, queue possible paths
        for (Node adj : p.destination ().adjNodes) { // branch off in every direction
          if (!p.contains(adj)) { //but never go in circles
            posPaths.add(new Path(p, adj));
          }
        }
      }
      index++;
    }
    return bestPath;
  }
}
//This is a group of adjacent nodes that form a path for a user to follow
class Path {  

  ArrayList<Node> nodes; //the nodes in the path
  float pLength;         //the path length

    //if you already have a list of nodes, it is easy to create a path
  Path (ArrayList<Node> nodes) {
    this.nodes = new ArrayList<Node>();
    for (Node n : nodes) {
      this.nodes.add(n);
    }
    pLength = calculateLength();
  }
  //if you have a path, you can make a new path that is one node longer
  Path (Path p, Node n) {
    this.nodes = new ArrayList<Node>();
    for (Node node : p.nodes) {
      nodes.add(node);
    }
    nodes.add(n);
    pLength = calculateLength();
  }
  //this is how much to add to the length for going up or down stairs.  stairs are usually bad, so they are weighted as very long
  final static int STAIRWEIGHT = 1;
  //adds all the distances between nodes to determine the path length
  float calculateLength() {
    float l = 0;
    for (int i = 0; i < nodes.size ()-1; i ++) {
      if (nodes.get(i).floor == nodes.get(i + 1).floor)
        l += dist(nodes.get(i).x, nodes.get(i).y, nodes.get(i+1).x, nodes.get(i+1).y);//the length of a path is determined by the distances between nodes on the map
      else
        l += STAIRWEIGHT;
    }
    return l;
  }
  //the first node in a path
  Node beginning () {
    return nodes.get(0);
  }
  //the last node in a path
  Node destination () {
    return nodes.get(nodes.size() - 1);
  }
  //wether the path has a node in it or not
  boolean contains(Node n) {
    return nodes.contains(n);
  }
  //how to write a path (usually for the console) ex. "Path: 1,2,3,5,7,8 | Length: 1.45"
  String toString() {
    String ret = "Path: ";
    for (Node n : nodes) {
      ret+= n.ID;
      if (nodes.indexOf(n) != nodes.size()-1) {
        ret += ",";
      }
    } 
    ret += " | Length: " +  pLength;
    return ret;
  }
}

