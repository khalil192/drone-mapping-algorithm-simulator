import 'dart:collection';
import 'dart:math';

import 'controller.dart';


class Dfs{
  List<int> parentList;
  ValueController valueController;
  int numCells , perRow,numRow;
  List<int>visi;
  List<int> dronePos;
  List<int> chargePos;
  List<int> droneChargeRem;
  Set<int> yetToBeVisited;
  Queue<int> freeDrones;
  int TAKETHIS,DONTTAKETHIS;
  int row,col; 
   Dfs(this.valueController){
     print("came here\n");
      numCells = valueController.numCells;
      perRow = valueController.perRow;
      numRow = numCells ~/ perRow;
      dronePos = new List<int>(3);
      dronePos  = [20 , 450,100];
      chargePos = new List<int>(3);
      chargePos  = [20 , 30,100];
      droneChargeRem = new List<int>(3);
      droneChargeRem = [100,100,100];
      visi = new List<int>(numCells);
      for(int i=0;i<numCells;i++){
        visi[i]= 0;
        if(valueController.cellController[i].selectedAs.value == "normal"){
          // yetToBeVisited.add(i);
        }
      }
  }
  double dist(int cell1 , int cell2){
    int i1 = cell1 ~/perRow , j1 = cell1 % perRow;
    int i2 = cell2 ~/perRow , j2 = cell2 % perRow;
    return sqrt((i1-i2)*(i1-i2) + (j1-j2)*(j1-j2));
  }
  bool safeState(int droneIndex , int lastPos){
    double minYet = 1000000; //INF
    int nearCharge;
    for(int charge in chargePos){
        double currDist = dist(charge , lastPos);
      if(currDist < minYet){
        minYet = currDist;
        nearCharge = charge;
      }
    }
    return droneChargeRem[droneIndex] >= minYet;
  }
  Future  markPath(List<int> drone0nodes ,List<int> drone1nodes )async{
      int len  = max(drone0nodes.length, drone1nodes.length);
      for(int i=0;i<len;i++){
        if(i < drone0nodes.length){
          valueController.cellController[drone0nodes[i]].selectedAs.value = "drone0";
        }
        if(i < drone1nodes.length){
          valueController.cellController[drone1nodes[i]].selectedAs.value = "drone1";
        }
        await wait();
      }
  }
  void startMap()async{
  List<int> drone0nodes = new List<int>();
  List<int> drone1nodes =  new List<int>();
  await dfs(0,"drone0",drone0nodes,dronePos[0]);
  await dfs(1,"drone1",drone1nodes,dronePos[1]);
  await markPath(drone0nodes, drone1nodes);
  }
  Future<bool> dfs(int droneIndex,String dronenum,List<int> droneNodes,int curr) async{
      int currX = curr ~/ perRow;
      int currY = curr % perRow;
      // print(curr.toString() + " is curr\n");
      visi[curr] = droneIndex;  //####
      droneNodes.add(curr);
      print('curr is ' + curr.toString() + " "+ dronenum);
      valueController.cellController[curr].selectedAs.value = "visi";
        await wait();
      //   if(yetToBeVisited.isEmpty){ // base case
      //     // return ;
      // }
      droneChargeRem[droneIndex]--;
  
      bool flag = true;
      for(int i = -1;i<2;i++){
        for(int j =-1;j <2;j++){
          int nextPos = (currX+i)*perRow + currY+j;
          if(currX +i <0 || currY + j < 0 || currX+i >= numRow || currY + j >= perRow){
            continue;
          }
          if(valueController.cellController[nextPos].selectedAs.value == "normal"
          && safeState(droneIndex, nextPos)){
            dronePos[droneIndex] = nextPos;
            // yetToBeVisited.remove(curr);
            // if(await
            await dfs(droneIndex,dronenum,droneNodes,nextPos);
            //  ){
                  // return Future.value(true);
            // }
          }
        }
      }
      if(flag){
        int nearCharge = -1;
        double minYet = 100000; //INF
        for(int charge in chargePos){
            double currDist = dist(charge , dronePos[droneIndex]);
            if(currDist < minYet){
              minYet = currDist;
              nearCharge = charge;
            }
        }
        dronePos[droneIndex] = nearCharge;
        //free drones positons
        return Future.value(true); 
      }
        return Future.value(flag); 
  }
}