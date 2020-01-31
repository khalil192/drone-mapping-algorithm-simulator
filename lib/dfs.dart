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
  int fullCharge;
  Queue<int> freeDrones;
  int TAKETHIS,DONTTAKETHIS;
  List<List<int> > droneNodes;
  int row,col; 
   Dfs(this.valueController,this.fullCharge){
      fullCharge =20;
      numCells = valueController.numCells;
      perRow = valueController.perRow;
      numRow = numCells ~/ perRow;
      dronePos = new List<int>(6);
      dronePos  = [0,29,870,899,820,280];
      chargePos = new List<int>(3);
      chargePos  = [20 , 200,740];
      droneChargeRem = new List<int>(dronePos.length);
      visi = new List<int>(numCells);
      yetToBeVisited = new Set<int>();
      for(int i=0;i<numCells;i++){
        visi[i]= 0;
        if(valueController.cellController[i].selectedAs.value == "normal"){
          yetToBeVisited.add(i);
        }
      }
      freeDrones = new Queue<int>();
      for(int i=0;i<dronePos.length;i++){
        droneChargeRem[i] = fullCharge;
        freeDrones.add(i); 
      }
      for(int charge in chargePos){
          valueController.cellController[charge].selectedAs.value = "charge";
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
          }
        }          
        await wait();
      }
  }
  void startMap()async{
  droneNodes = new List<List<int> >();
  for(int i=0;i<dronePos.length;i++){
    droneNodes.add(List<int>());
  }
 await allocateDrones();
  // for(int i=0;i<dronePos.length;i++){
  //   await dfs(i,"drone"+ i.toString() , dronePos[i]);
  // }
  // await markPath();
  }
  Future<bool> dfs(int droneIndex,String dronenum,int curr) async{
      int currX = curr ~/ perRow;
      int currY = curr % perRow;
      bool flag = true;
      if(droneChargeRem[droneIndex] >0){
      visi[curr] = droneIndex;  //####
      if(valueController.cellController[curr].selectedAs.value == "normal"){
          droneNodes[droneIndex].add(curr);
      valueController.cellController[curr].selectedAs.value = "visi";
        }
      droneChargeRem[droneIndex]--;
        // await wait();
        if(yetToBeVisited.isEmpty){ // base case
          return Future.value(true);
      }
      for(int i = -1;i<2;i++){
        for(int j =-1;j <2;j++){
          int nextPos = (currX+i)*perRow + currY+j;
          if(currX +i <0 || currY + j < 0 || currX+i >= numRow || currY + j >= perRow){
            continue;
          }
          if((valueController.cellController[nextPos].selectedAs.value == "normal" || valueController.cellController[nextPos].selectedAs.value == "charge") 
          && safeState(droneIndex, nextPos)){
            dronePos[droneIndex] = nextPos;
            yetToBeVisited.remove(curr);
            flag = false;
            if(
            await dfs(droneIndex,dronenum,nextPos)
             ){    return Future.value(true); }
          }
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
        droneChargeRem[droneIndex] = fullCharge;
        dronePos[droneIndex] = nearCharge;
        freeDrones.add(droneIndex);
          valueController.cellController[nearCharge].selectedAs.value = "drone" + droneIndex.toString();
          await wait();
          valueController.cellController[nearCharge].selectedAs.value = "charge";
        //free drones positons
        return Future.value(true); 
      }
        return Future.value(flag); 
  }
  Future<bool> bfs(int droneIndex,String dronenum,int curr) async{
      
      Queue<int> queue  = new Queue<int>();
      queue.add(curr);
      while(queue.isNotEmpty){
        curr = queue.removeFirst(); //curr is position

      }
      int currX = curr ~/ perRow;
      int currY = curr % perRow;
      visi[curr] = droneIndex;  //####
      if(valueController.cellController[curr].selectedAs.value == "normal"){
          droneNodes[droneIndex].add(curr);
      valueController.cellController[curr].selectedAs.value = "visi";
        }
        await wait();
        if(yetToBeVisited.isEmpty){ // base case
          return Future.value(true);
      }
      
  }
  Future allocateDrones() async{
    int c = 17;
    int pastNum = yetToBeVisited.length,cnt = 0;
    while(freeDrones.isNotEmpty && yetToBeVisited.isNotEmpty){
      c--;
      int currDrone = freeDrones.removeFirst();
      print(currDrone.toString() + " curr drone");
      int nextPos = -1,minYet = 1000000;//INF
      for(int pos in yetToBeVisited){
        // print('came alright');
        if(valueController.cellController[pos].selectedAs.value == "normal"){
          
        int currDist = dist(dronePos[currDrone],pos).toInt();     
        print(currDist.toString() + ' cur÷rDist');
        if(currDist < minYet){
          minYet = currDist;
          nextPos = pos;
        } 
        } 
      }
        print(nextPos.toString() + " next pos "+ currDrone.toString());
      if(nextPos != -1){
      droneChargeRem[currDrone] -= minYet.toInt(); 
      await  dfs(currDrone, "drone"+ currDrone.toString() , nextPos);
    }
    if(pastNum == yetToBeVisited.length){
      cnt++; 
    }
    else{pastNum = yetToBeVisited.length;cnt = 0;}
    if(cnt > dronePos.length){
      break;
    }
    }
    await markPath();
  }

}