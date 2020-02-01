import 'package:flutter/material.dart';
import 'controller.dart';
import 'package:flutter/rendering.dart';
import 'dart:collection';
import 'dart:math';
import 'dfs.dart';
//flutter pub global activate peanut
//flutter pub get
//git push origin --set-upstream gh-pages
void main() => runApp(MyApp());

String searchMethod = "Depth First Search";
List<Color> colorsList; 
String currentSelection = "block";
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    colorsList = new List<Color>();
    var _random  = new Random(); 
    for(int i=0;i<30;i++){
      int a = _random.nextInt(100)+150,b =_random.nextInt(100)+150 ,c=_random.nextInt(100)+150,d=_random.nextInt(10)+150;
    Color currColor = Color.fromARGB(
        //or with fromRGBO with fourth arg as _random.nextDouble(),
        a,b,c,d
      );    
      int cc =1;
    for(Color color in colorsList){
      if(currColor == color){
        cc=0;break;
      }
    }
    if(cc==1 ||  currColor == Color(0xFFFFFFFF)){
      colorsList.add(currColor);
    }else{
      i--;
    }
    }
    return MaterialApp(
      title: 'drone mapping simulator',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomeScreen(),
    );
  }
}
String currentMethod = "clustering";
// ValueController valueController;
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
  
class _HomeScreenState extends State<HomeScreen> {
  static int perRow = 40;
  static int numCells = 800;
  static int fullCharge = 10;
  // static List<int> dronePos  = [20,20,200,740,200,740];
  static ValueController valueController =  ValueController(numCells,perRow,colorsList);
     void clearAll(){
       for(int i=0;i<numCells;i++){
         String curr = valueController.cellController[i].selectedAs.value;
         if(curr == "drone-start" || curr == "drone"){
           valueController.cellController[i].selectedAs.value = "drone";
            continue;
         }
         if(curr == "charge" || curr == "block"){
          continue;
         }
           valueController.cellController[i].selectedAs.value = "normal";
       }
  }
  void startMap(){
      Dfs dfsObj = new Dfs(valueController,fullCharge);  
      dfsObj.startMap(currentMethod);
  }
  void addObject(String object){
    var rng = new Random();
    int newDrone = rng.nextInt(numCells-1);
    while(valueController.cellController[newDrone].selectedAs.value == "drone" || valueController.cellController[newDrone].selectedAs.value == "charge"){
      newDrone = rng.nextInt(numCells-1);
    }
    valueController.cellController[newDrone].selectedAs.value = object;
  }
  void removeObject(String object){
    for(int i=0;i<numCells;i++){
      if(valueController.cellController[i].selectedAs.value == object){
        valueController.cellController[i].selectedAs.value = "normal";
        break;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            title: Text('UAV '),
            actions: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,

                children: <Widget>[
               Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                  // Container(
                  //     child: Text("size of map"),),
                      SliderTheme(
                        data:SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.black,
                          inactiveTrackColor:Colors.grey,
                          thumbColor: Colors.black,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                        ),
                        child: Slider(
                              min: 20.0,
                              max: 100,
                              value: perRow.toDouble(),
                                  onChanged: (newRating){
                                    setState(() {
                                      perRow = newRating.toInt();
                                      numCells = perRow * 30; 
                                      valueController = new ValueController(numCells, perRow,colorsList);
                                    });
                                },
                          ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                  // Container(
                  //     child: Text("capacity of drone"),),
                      SliderTheme(
                        data:SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.black,
                          inactiveTrackColor:Colors.grey,
                          thumbColor: Colors.black,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                        ),

                        child: Slider(
                              min: 10.0,
                              max: 150,
                              value: fullCharge.toDouble(),
                                  onChanged: (newRating){
                                    setState(() {
                                      fullCharge = newRating.toInt();
                                    });
                                },
                          ),
                      ),
                    ],
                  ),
                    SizedBox(width: 10,),
                    SizedBox(width: 10,),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side : BorderSide(color: Colors.white)
                    ),
                    onPressed: ()=>{
                      clearAll(),
                    },
                      child: Text("clear all"),
                  ),
                  SizedBox(width: 10,),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side : BorderSide(color: Colors.white)
                    ),
                    onPressed: ()=>{
                      addObject("drone"),
                    },
                      child: Text("drone +"),
                  ),
                  SizedBox(width: 10,),
          RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side : BorderSide(color: Colors.white)
                    ),
                    onPressed: ()=>{
                      addObject("charge"),
                    },
                      child: Text("charge +"),
                  ),
                  SizedBox(width: 10,),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side : BorderSide(color: Colors.white)
                    ),
                    onPressed: ()=>{
                      removeObject("charge"),
                    },
                      child: Text("charge -"),
                  ),
                  SizedBox(width: 10,),
                   RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      side : BorderSide(color: Colors.white)
                    ),
                    onPressed: ()=>{
                      removeObject("drone"),
                    },
                      child: Text("drone -"),
                  ),
                  SizedBox(width: 10,),
                 DropdownButton<String>(  
                    value: currentMethod,
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 24,
                    iconEnabledColor: Colors.black,
                    elevation: 16,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  isDense: true,
                      onChanged: (String newValue) {
                                setState(() {
                                  currentMethod = newValue;
                                });
                          },
                          items: <String>['clustering' , 'non clustering']
                          .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                          }
                  ).toList(),
                  ),
                  SizedBox(width: 50,),
                ]
              
              )

            ],
          ),
          body: Center(child: Grid(valueController)), 
           floatingActionButton: FloatingActionButton(
             child: Center(child: Text('start map')),
            onPressed: ()=>{  
              startMap(),
            },
          )
    );
  }
}

class Grid extends StatefulWidget {
  final ValueController valueController;
  Grid(this.valueController);
  @override
  _GridState createState() => _GridState();
}

class _GridState extends State<Grid> {
final Set<int> selectedIndexes = Set<int>();
  final key = GlobalKey();
  final Set<_Foo> _trackTaped = Set<_Foo>();

  _detectTapedItem(PointerEvent event) {
    final RenderBox box = key.currentContext.findRenderObject();
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        /// temporary variable so that the [is] allows access of [index]
        final target = hit.target;
        if (target is _Foo && !_trackTaped.contains(target)) {
          _trackTaped.add(target);
          _selectIndex(target.index);
        }
      }
    }
  }
  int lastStartSelected = 0;
  int prevStartSelected = 0;
  int lastEndSelected = 230;
  int prevEndSelected = 230;
  _selectIndex(int index) {
    setState(() {
      selectedIndexes.add(index);
      // lastStartSelected = index;
      // lastEndSelected = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    // print(selectedIndexes);
    // print(currentSelection);
    for(int index in selectedIndexes){
      if(currentSelection == 'block'){
      widget.valueController.selectIndex(index); 
      }
      if(currentSelection == 'start'){
        if(prevEndSelected == lastStartSelected){
            if(prevEndSelected% widget.valueController.perRow > 0){
              lastStartSelected -=1;
            }else{
              lastStartSelected +=1;
            }
        }
        widget.valueController.cellController[prevStartSelected].selectedAs.value = "normal";
        prevStartSelected = lastStartSelected;
      }
      if(currentSelection == 'end'){
        if(prevStartSelected == lastEndSelected){
            if(prevStartSelected% widget.valueController.perRow > 0){
              lastEndSelected -=1;
            }else{
              lastEndSelected +=1;
            }
        }
        widget.valueController.cellController[prevEndSelected].selectedAs.value = "normal";
        prevEndSelected = lastEndSelected;
      }
    }
    // widget.valueController.cellController[prevStartSelected].selectedAs.value = "start";
    // widget.valueController.cellController[prevEndSelected].selectedAs.value = "end";
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height *0.8,
      child: Listener(
        onPointerDown: _detectTapedItem,
        onPointerMove: _detectTapedItem,
        onPointerUp: _clearSelection,
        child: GridView.builder(
          key: key,
          itemCount: widget.valueController.numCells,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.valueController.perRow, // change this value
            childAspectRatio: 1.0,
            crossAxisSpacing: 1.0,
            mainAxisSpacing: 1.0,
          ),
          itemBuilder: (context, index) {
            return Foo(
              index: index,
              child: Cell(widget.valueController.cellController[index]),
            );
          },
        ),
      ),
    );
  }

  void _clearSelection(PointerUpEvent event) {
    _trackTaped.clear();
    setState(() {
      selectedIndexes.clear();
    });
  }
}

class Foo extends SingleChildRenderObjectWidget {
  final int index;

  Foo({Widget child, this.index, Key key}) : super(child: child, key: key);

  @override
  _Foo createRenderObject(BuildContext context) {
    return _Foo()..index = index;
  }

  @override
  void updateRenderObject(BuildContext context, _Foo renderObject) {
    renderObject..index = index;
  }
}

class _Foo extends RenderProxyBox {
  int index;
}


class Cell extends StatefulWidget {
  CellController cellController;
  Cell(this.cellController);
  @override
  _CellState createState() => _CellState();
}

Color getColor(String selectedAs){
    if(selectedAs == "block"){
      return Colors.blue;
    }
    return Colors.white;
}
int startSelection = -1;
class _CellState extends State<Cell> {
  void cellClicked() async{
    String ans = widget.cellController.selectedAs.value;
    if(widget.cellController.selectedAs.value == "normal"){
  widget.cellController.selectedAs.value = currentSelection;
    }else{
        widget.cellController.selectedAs.value = "normal";
    }
      currentSelection =  ans;
  switch(currentSelection){
    case "normal":{
      currentSelection = "block";
    }
    break;
    case "block":{
      currentSelection = "normal";
    }
    break;
    case "charge":{
      currentSelection = "charge";
    }
    break;
    case "drone":{
      currentSelection = "drone";
    }
    break;
  }  
  }
  void updateCurrSelection(){
  //   String nowSelection =  widget.cellController.selectedAs.value;
  // switch (currentSelection){
  //   case "normal":{
  //     currentSelection = "block";
  //   }
  //   break;
  // }
  // switch(nowSelection){
  //   case "normal":{
  //     currentSelection = "block";
  //   }
  //   break;
  // }  
  }
  void updateStartSelection(){
    // print(widget.cellController.index.toString() + " this is dragged");
    currentSelection =  widget.cellController.selectedAs.value;
  switch(currentSelection){
    case "normal":{
      currentSelection = "block";
    }
    break;
    // case "block":{
    //   currentSelection = "block";
    // }
    // break;
  }  
  }
  void updateStopSelection(){
    switch(currentSelection){
    case "start":{
      currentSelection = "block";
    }
    break;
    case "end":{
      currentSelection = "block";
    }
    break;
  } 
  }
  @override
  Widget build(BuildContext context){
    return ValueListenableBuilder(
      valueListenable: widget.cellController.length,
      builder: (context,cellLength,child){
        return GestureDetector(
          onTap: ()=>{            
            cellClicked(),
          },
          onVerticalDragStart: (details){
            updateStartSelection();
          },
          onVerticalDragUpdate: (details){
            updateCurrSelection();
          },
          onVerticalDragEnd: (details){
            updateStopSelection();
          },
          onHorizontalDragStart: (details){
            updateStartSelection();
          },
          onHorizontalDragUpdate: (details){
            updateCurrSelection();
          },
          onHorizontalDragEnd: (details){
            updateStopSelection();
          },
          child: ValueListenableBuilder(
            valueListenable: widget.cellController.selectedAs,
            builder: (context, selectedAs, child){
                return AnimatedContainer(
                  duration: Duration(milliseconds: 10),
                  width: cellLength,
                  height: cellLength,
                  decoration: BoxDecoration(
                 border: Border.all(color: Colors.blue[200]),
                  color: getColor(widget.cellController.selectedAs.value), 
                   ),
                  child: Center(child: widget.cellController.getWidget()),
                );
            },
          ),
        );
      },
    );
  
  }
}

