//Everything here was created specifically to talk to the website
//These methods had to be of global scope with primitive parameters/return types,
//as JavaScript had issues referencing Java objects.

//Called when the get directions button is pressed - looks up nodes based on the strings and then refers those to the map
void updateMapPath (String locationName, String destinationName) {

  Node location = getNodeFromListWithName(ahsMap.nodes, locationName);
  Node destination = getNodeFromListWithName(ahsMap.nodes, destinationName);

  ahsMap.updatePath(location, destination);
}

//Returns the string for the directions at the current step - used to set HTML text after the directions index changes
String getCurrentDirection () {
  if (ahsMap.curDirections != null) {

    return ahsMap.curDirections.getCurrentDirection();
  }
  return null;
}

//Called when the next direction button is pressed
void advanceDirections() {
  if (ahsMap.curDirections != null) {

    ahsMap.curDirections.increaseIndex();   //Increasing the current directions index

      if (ahsMap.curDirections.curLocation != null) {

      //Updating the floor based on the location, with some quality of life conditionals that make the floor change with stairs correctly
      if (ahsMap.curDirections.curLocation.size()>1 &&
        ahsMap.curDirections.curLocation.get(0).floor != ahsMap.curDirections.curLocation.get(1).floor) {
        ahsMap.curFloor = ahsMap.curDirections.curLocation.get(1).floor;
      } else {
        ahsMap.curFloor = ahsMap.curDirections.curLocation.get(0).floor;
      }
    }
  }
}


//Called when the previous direction button is pressed
void backtrackDirections() {
  if (ahsMap.curDirections != null) {

    ahsMap.curDirections.decreaseIndex(); //Decreasing the current directions index

      if (ahsMap.curDirections.curLocation != null) {

      //Updating the floor based on the location, with some quality of life conditionals that make the floor change with stairs correctly
      if (ahsMap.curDirections.curLocation.size()>1 && 
        ahsMap.curDirections.curLocation.get(0).floor != ahsMap.curDirections.curLocation.get(1).floor) {
        ahsMap.curFloor = ahsMap.curDirections.curLocation.get(1).floor;
      } else {
        ahsMap.curFloor = ahsMap.curDirections.curLocation.get(0).floor;
      }
    }
  }
}

//To change the floors of the map independent from other processes - called when the up/down floor buttons are pressed
void upFloor() {
  if (ahsMap.images.get(ahsMap.curFloor+1) != null) {
    ahsMap.curFloor++;
  }
}
void downFloor() {
  if (ahsMap.images.get(ahsMap.curFloor-1) != null) {
    ahsMap.curFloor--;
  }
}

