class Map {

  ArrayList <PImage> images; //the map images

    ArrayList<Node> nodes; //all of the nodes for the program - this is why the magic happens

    int curFloor; //the floor currently being displayed
  Path curPath; //the currently active path
  Directions curDirections; //the currently active set of directions

    Pathfinder pathfinder;

  Map (ArrayList<PImage> images, ArrayList<Node> nodes) {

    //The variables which are loaded in setup from seperate files
    this.images = images;
    this.nodes = nodes;

    //It's the floor of the front entrance
    curFloor = 3;
    //These don't exist yet
    curPath = null;
    curDirections = null;

    //Ay Kieran you made it!
    pathfinder = new KieranPathFinder();
  }

  void updateDisplay () {

    //Drawing the image corresponding to the current floor, to fit the display
    pushMatrix();
    scale((float) width / images.get(curFloor).width, (float) height / images.get(curFloor).height);
    image(images.get(curFloor), 0, 0);
    popMatrix();

    //A whole heck of a lot of conditionals that deal with drawing the path
    if (curPath != null) {

      for (int i = 0; i < curPath.nodes.size (); i ++) {

        Node n = curPath.nodes.get(i);

        if (n.floor == curFloor) {

          stroke(#0000FF);
          if (i < curPath.nodes.size ()-1) {
            if (n.adjNodes.contains(curPath.nodes.get(i+1))) {
              if (curPath.nodes.get(i+1).floor == n.floor) {
                strokeWeight(15);
                line(n.x*width, n.y*height, curPath.nodes.get(i+1).x*width, curPath.nodes.get(i+1).y*height);
              }
            }
          }

          noStroke();

          if (n.equals(curPath.beginning())) {
            fill(#0000FF);
            ellipse(n.x*width, n.y*height, 30, 30);
          } else if (n.equals(curPath.destination())) {
            fill(#2DE52D);
            ellipse(n.x*width, n.y*height, 30, 30);
          } else {
            fill(#0000FF);
            ellipse(n.x*width, n.y*height, 15, 15);
          }
        }
      }
    }

    //A whole heck of a lot of conditionals that deal with drawing the current location in the path
    if (curDirections != null && curDirections.curLocation != null) {

      for (int i = 0; i < curDirections.curLocation.size (); i ++) {

        Node n = curDirections.curLocation.get(i);

        if (n.floor == curFloor) {

          //for example in the path 506 -> 438, this is drawing extra connections
          if (i < curDirections.curLocation.size()-1) {
            if (n.adjNodes.contains(curDirections.curLocation.get(i+1))) {
              if (curDirections.curLocation.get(i+1).floor == n.floor) {
                strokeWeight(20);
                stroke(#FF00FF);
                line(n.x*width, n.y*height, curDirections.curLocation.get(i+1).x*width, curDirections.curLocation.get(i+1).y*height);
              }
            }
          }

          if (n.equals(curPath.beginning())) {
            strokeWeight(8);
            stroke(#FF00FF);
            fill(#0000FF);
            ellipse(n.x*width, n.y*height, 30, 30);
          } else if (n.equals(curPath.destination())) {
            strokeWeight(8);
            stroke(#FF00FF);
            fill(#2DE52D);
            ellipse(n.x*width, n.y*height, 30, 30);
          } else {
            noStroke();
            fill(#FF00FF);
            ellipse(n.x*width, n.y*height, 20, 20);
          }
        }
      }
    }

    //Development graphics which display all of the nodes with their ID's and adjacencies
    if (mapCreatorMode) {
      for (Node n : nodes) {
        if (n.floor == curFloor) {
          fill(#00FF00);//#00FF00
          noStroke();
          ellipse(n.x*width, n.y*height, 3, 3);
          textAlign(CENTER, CENTER);
          textSize(15);
          text(n.ID, n.x*width, n.y*height + -7);
          for (Node adjNode : n.adjNodes) {
            if (adjNode.floor == n.floor) {
              stroke (#00FF00, 100);
              strokeWeight(1);
              line(n.x*width, n.y*height, adjNode.x*width, adjNode.y*height);
            }
          }
        }
      }
    }
  }


  void updatePath(Node location, Node destination) {

    //If anything doesn't exist, clear everything and get the heck out of this method
    if (location == null || destination == null) {
      curPath = null;
      curDirections = null;
      return;
    }

    //Updating the class variables based on the location and destination
    curFloor = location.floor;
    curPath = pathfinder.findPath(location, destination);

    //If we got the path correctly, now construct directions from that path
    if (curPath != null) {
      curDirections = new Directions(curPath);
    }
  }
}

