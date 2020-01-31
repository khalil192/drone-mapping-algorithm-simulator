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
  List<int> cluster;
  Queue<int> freeDrones;
  int TAKETHIS,DONTTAKETHIS;
  List<List<int> > droneNodes;
  int row,col; 
   Dfs(this.valueController,this.fullCharge,this.dronePos){
      numCells = valueController.numCells;
      perRow = valueController.perRow;
      numRow = numCells ~/ perRow;
      
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
  int dist(int cell1 , int cell2){
    int i1 = cell1 ~/perRow , j1 = cell1 % perRow;
    int i2 = cell2 ~/perRow , j2 = cell2 % perRow;
    return sqrt((i1-i2)*(i1-i2) + (j1-j2)*(j1-j2)).toInt();
  }
  Future<bool> safeState(int droneIndex , int lastPos){
    double minYet = 1000000; //INF
    int nearCharge;
    for(int charge in chargePos){
        double currDist = dist(charge , lastPos).toDouble();
      if(currDist < minYet){
        minYet = currDist;
        nearCharge = charge;
      }
    }
    return Future.value(droneChargeRem[droneIndex] >= minYet);
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
   await markPath();
// await clusterMap();
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
        await wait();
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
          && await safeState(droneIndex, nextPos)){
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
            double currDist = dist(charge , dronePos[droneIndex]).toDouble();
            if(currDist < minYet){
              minYet = currDist;
              nearCharge = charge;
            }
        }
        droneChargeRem[droneIndex] = fullCharge;
        dronePos[droneIndex] = nearCharge;
        freeDrones.add(droneIndex);
          // valueController.cellController[nearCharge].selectedAs.value = "drone" + droneIndex.toString();
          // await wait();
          // valueController.cellController[nearCharge].selectedAs.value = "charge";
        //free drones positons
        return Future.value(true); 
      }
        return Future.value(flag); 
  }
  bool safeStateCluster(int droneIndex , int nextPos){
    int currDist = dist(dronePos[droneIndex] , nextPos).toInt();
    return (currDist <= droneChargeRem[droneIndex]);
  }
  Future<bool> clusterDfs(int droneIndex,String dronenum,int curr) async{
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
          if(currX +i <0 || currY + j < 0 || currX+i >= numRow || currY + j >= perRow || cluster[nextPos] != cluster[curr] ){
            continue;
          }
          if((valueController.cellController[nextPos].selectedAs.value == "normal" || valueController.cellController[nextPos].selectedAs.value == "charge") 
          && safeStateCluster(droneIndex , nextPos)){
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
        int nearCharge = chargePos[cluster[curr]];
        // double minYet = 100000; //INF
        // for(int charge in chargePos){
        //     double currDist = dist(charge , dronePos[droneIndex]).toDouble();
        //     if(currDist < minYet){
        //       minYet = currDist;
        //       nearCharge = charge;
        //     }
        // }
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
  Future clustering() async{
    cluster  = new List<int>(numCells);
    for(int i=0;i<numCells;i++){
      double minYet = 1000000;//inf
      int nearCharge = -1;
      for(int charge= 0;charge<chargePos.length;charge++){
          double currDist = dist(chargePos[charge], i).toDouble();
          if(currDist < minYet){
            minYet = currDist;
            nearCharge = charge;
          }
      }
      cluster[i] = nearCharge;
    }
  }
  Future clusterMap() async{
  await clustering();
  // for(int i=0;i<numCells;i++){
  //   if(cluster[i]==-1){
  //     continue;
  //   }
  //   if(cluster[i]== 0){
  //     valueController.cellController[i].selectedAs.value = "drone0";
  //   }
  //   if(cluster[i]== 1){
  //     valueController.cellController[i].selectedAs.value = "drone1";
  //   }if(cluster[i]== 2){
  //     valueController.cellController[i].selectedAs.value = "drone2";
  //   }
  // }
   int pastNum = yetToBeVisited.length,cnt = 0;
    while(freeDrones.isNotEmpty && yetToBeVisited.isNotEmpty){
      int currDrone = freeDrones.removeFirst();
      // print(currDrone.toString() + " curr drone");
      int nextPos = -1,minYet = 1000000;//INF
      for(int pos in yetToBeVisited){
        // print('came alright');
        if(valueController.cellController[pos].selectedAs.value == "normal"){
          
        int currDist = dist(dronePos[currDrone],pos).toInt();     
        // print(currDist.toString() + ' cur÷rDist');
        if(currDist < minYet){
          minYet = currDist;
          nextPos = pos;
        } 
        } 
      }
        // print(nextPos.toString() + " next pos "+ currDrone.toString());
      if(nextPos != -1 && minYet  < fullCharge && safeStateCluster(currDrone, nextPos)) {
      droneChargeRem[currDrone] -= minYet.toInt(); 
      await  clusterDfs(currDrone, "drone"+ currDrone.toString() , nextPos);
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

  Future allocateDrones() async{
    int pastNum = yetToBeVisited.length,cnt = 0;
    while(freeDrones.isNotEmpty &&  yetToBeVisited.isNotEmpty){
      int currDrone = freeDrones.removeFirst();
      // print(currDrone.toString() + " curr drone");
      int nextPos = -1,minYet = 1000000;//INF
      for(int pos in yetToBeVisited){
        // print('came alright');
        if(valueController.cellController[pos].selectedAs.value == "normal"){
        int currDist = dist(dronePos[currDrone],pos).toInt();     
        // print(currDist.toString() + ' cur÷rDist');
        if(currDist < minYet){
          minYet = currDist;
          nextPos = pos;
        } 
        } 
      }
        // print(nextPos.toString() + " next pos "+ currDrone.toString());
      if(nextPos != -1){
      droneChargeRem[currDrone] -= minYet.toInt(); 
      if( await safeState(currDrone, nextPos)){
      await dfs(currDrone, "drone"+ currDrone.toString() , nextPos);
      }
      }
    if(pastNum == yetToBeVisited.length){
      cnt++; 
    }
    else{pastNum = yetToBeVisited.length;cnt = 0;}
    // if(cnt > dronePos.length+5){
    //   break;
    // }
    }
    print(yetToBeVisited.length.toString()+ "yet to");
    print(freeDrones.length.toString()+ "freeDrones");
    await markPath();
  }

}
