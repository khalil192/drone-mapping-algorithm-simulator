
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ValueController{
  List<CellController> cellController;
  int numCells;
  int perRow;
  ValueController(this.numCells,this.perRow){
    cellController = new List<CellController>(numCells);
    for(int i=0;i<numCells;i++){
      cellController[i] = new CellController(i,perRow);
    }
  }
  void selectIndex(int index){
    if(cellController[index].selectedAs.value == "normal"){
      // cellController[index].color.value = Colors.blue;
      cellController[index].selectedAs.value = "block";
    }
  }
  void createRandomMaze()async{
    int start = -1,dest = -1;
    int numOfBlocks = numCells ~/ 5; 
    for(int i=0;i<numCells;i++){
        if(cellController[i].selectedAs.value == "start"){
          start = i;
        }
         if(cellController[i].selectedAs.value == "end"){
          dest = i;
        }
    }
    var rng = new Random();
    for(int i=0;i<numOfBlocks;i++){
        int num = rng.nextInt(numCells);
        if(num == start || num == dest){
            continue; i--;
        }
       await waitMicroseconds(100);
        cellController[num].selectedAs.value = "block";
    }
  }
    void clearPath() async{
        for(int i=0;i<numCells;i++){
          String curr = cellController[i].selectedAs.value;
          if((curr != "start" && curr != "end" && curr != "block")){
            cellController[i].selectedAs.value = "normal";
          }
        }
    }
}

class CellController{
  ValueNotifier<double> length;
  ValueNotifier<Color> color;
  ValueNotifier<String> selectedAs;
  int index,perRow;
  CellController(this.index,this.perRow){
    length = new ValueNotifier(2.0);
    color = new ValueNotifier(Colors.white);
    selectedAs = new ValueNotifier("normal");
  }
  Widget getWidget(){
      if(selectedAs.value == "normal" || selectedAs.value == "notNormal"){
        return Container();
      }
      if(selectedAs.value == "block"){
        return Container(color: Colors.blue);
      }
      if(selectedAs.value == "start"){
        return Container(
          child: Icon(Icons.play_arrow,size : 10.0),
        );
      }
      if(selectedAs.value == "drone"){
        return Container(
          child: Icon(Icons.ac_unit,size : 10.0),
        );
      }
      if(selectedAs.value == "end"){
        return Container(
          child:  Icon(Icons.stop,size : 10.0 ),
        );
      }
      if(selectedAs.value == "currVisted"){
        return Container(color: Colors.black);
      }
      if(selectedAs.value == "visi"){
                // return Container();
        return Container(color: Colors.grey[200]);
      }
      if(selectedAs.value == "charge"){
        return Container(
          child:  Icon(Icons.battery_charging_full,size : 15.0 ),
        );      }
      if(selectedAs.value == "drone0"){
        return Container(color: Colors.yellow[200]);
      }
      if(selectedAs.value == "drone1"){
        return Container(color: Colors.green[200]);
      }  
      if(selectedAs.value == "drone2"){
        return Container(color: Colors.red[200]);
      }  if(selectedAs.value == "drone3"){
        return Container(color: Colors.orange[200]);
      }  if(selectedAs.value == "drone4"){
        return Container(color: Colors.purple[200]);
      }  
     if(selectedAs.value == "drone5"){
        return Container(color: Colors.cyan);
      }  
  }
  
  

}


Future sleepSum(int valueOne, int valueTwo) {
  return Future.delayed(const Duration(seconds: 1), () => valueOne + valueTwo);
}

Future wait() {
  // final milliseconds = lerpDouble(100, 1, speed).toInt();
  // return Future.delayed(Duration(milliseconds: milliseconds));
  return Future.delayed(Duration(milliseconds: 1));
}
Future waitMicroseconds(int microseconds){
  // final milliseconds = lerpDouble(100, 1, speed).toInt();
  // return Future.delayed(Duration(milliseconds: milliseconds));
  return Future.delayed(Duration(microseconds: microseconds));
}
Future waitMilliSeconds(int milliseconds) {
  // final milliseconds = lerpDouble(100, 1, speed).toInt();
  // return Future.delayed(Duration(milliseconds: milliseconds));
  return Future.delayed(Duration(milliseconds: milliseconds));
}