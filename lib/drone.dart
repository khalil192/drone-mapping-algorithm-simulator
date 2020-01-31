
import 'dart:collection';
import 'dart:ffi';
import 'dart:math';

import 'controller.dart';

class Drone{
  ValueController valueController;
  List<List<int> > grid;
  List<Pair>dronesPos;
  List<Pair> chargePos;
  List<int> droneChargeRem;
  Set<Pair> yetToBeVisited;
  Queue<int> freeDrones;
  int TAKETHIS,DONTTAKETHIS;
  int row,col;
  Drone(this.valueController){
    col = valueController.perRow;
    row = valueController.numCells;
    DONTTAKETHIS = -2;
    TAKETHIS = -1;
  }
  double dist(Pair p1, Pair p2){
    return sqrt((p1.first - p2.first)*(p1.first - p2.first) + (p1.second - p2.second)*(p1.second - p2.second));
  }
  bool eq(Pair p1, Pair p2){
    return p1.first == p2.first && p2.second == p1.second;
  }
  bool safeState(int droneIndex , Pair lastPos){
    Pair nearCharge = Pair(-1,-1);
    double minYet = 1000000; // INF
    for(Pair charge in chargePos){
        double currDist = dist(charge , lastPos);
        if(currDist < minYet ){
            minYet = currDist;
            nearCharge = charge;
        }
    }
    return (droneChargeRem[droneIndex] >= minYet);  }

    int dfs1(int droneIndex){
    int currX = dronesPos[droneIndex].first;
    int currY = dronesPos[droneIndex].second;
    grid[currX][currY] = droneIndex;
    droneChargeRem[droneIndex]--;
    // printGrid();
    int flag = 1;
    for(int i=-1;i<=1;i++){
        for(int j=-1;j<=1;j++){
            if(currX+i <0 || currY+j<0 || currX+ i >=row ||currY+j>=col ){continue;}
                // cout<<"pts :"<<currX+i <<" "<<currY+j<<endl;
                if(grid[currX+i][currY + j] == TAKETHIS && safeState(droneIndex,Pair(currX+i,currY+j))){
                    dronesPos[droneIndex] = Pair(currX+i, currY+j);
                    yetToBeVisited.remove(Pair(currX+i , currY+j));
                    if(dfs1(droneIndex)==1){
                        return 1;
                    }
                    flag = 0;
                }
            }
    }
    if(flag==0){
    Pair nearCharge = Pair(-1,-1);
    double minYet = 1000000; // INF
    for(Pair charge in chargePos){
        double currDist = dist(charge , dronesPos[droneIndex]);
        if(currDist < minYet ){
            minYet = currDist;
            nearCharge = charge;
        }
    } 
    dronesPos[droneIndex] = nearCharge;
        freeDrones.add(droneIndex);
        return  1;
    }
    return 0;
}
void serial(int droneIndex){
    Pair start = Pair(-1,-1);
    double minDistYet = 1000000; // INF
    for(Pair curr in yetToBeVisited){
        double currDist =dist(dronesPos[droneIndex] , curr);
        if( currDist< minDistYet){
            minDistYet = currDist;
            start = curr;
        }
    }
    if(eq(start , Pair(-1,-1))){  return; }
    dronesPos[droneIndex] = start;
    dfs1(droneIndex);
}
}

class Pair{
  int first , second;
  Pair(this.first, this.second);
}