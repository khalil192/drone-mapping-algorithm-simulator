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
  List<List<int> > droneNodes;
  int row,col; 
   Dfs(this.valueController){
     print("came here\n");
      numCells = valueController.numCells;
      perRow = valueController.perRow;
      numRow = numCells ~/ perRow;
      dronePos = new List<int>(6);
      dronePos  = [0,29,870,899,820,280];
      chargePos = new List<int>(3);
      chargePos  = [20 , 30,100];
      droneChargeRem = new List<int>(dronePos.length);
      for(int i=0;i<dronePos.length;i++){
        droneChargeRem[i] = 60;
      }
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
  Future  markPath()async{
      int len = 0;
      int numDrones = droneNodes.length;
      for(int i=0;i<numDrones;i++){
        len = max(len , droneNodes[i].length);
      }
      for(int j=0;j<len;j++){
        for(int i=0;i<numDrones;i++){
          if(droneNodes[i].length > j){
          valueController.cellController[droneNodes[i][j]].selectedAs.value = "drone"+i.toString();
          await wait();
          }
        }
      }
  }
  void startMap()async{
  droneNodes = new List<List<int> >();
  for(int i=0;i<dronePos.length;i++){
    droneNodes.add(List<int>());
  }
  for(int i=0;i<dronePos.length;i++){
    await dfs(i,"drone"+ i.toString() , dronePos[i]);
  }
  await markPath();
  }
  Future<bool> dfs(int droneIndex,String dronenum,int curr) async{
      int currX = curr ~/ perRow;
      int currY = curr % perRow;
      print(curr.toString() + " is curr\n");
      visi[curr] = droneIndex;  //####
      droneNodes[droneIndex].add(curr);
      print('curr is ' + curr.toString() + " "+ dronenum);
      valueController.cellController[curr].selectedAs.value = "visi";
        // await wait();
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
            await dfs(droneIndex,dronenum,nextPos);
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