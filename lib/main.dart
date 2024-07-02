
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main(){
  runApp(const MaterialApp (
    debugShowCheckedModeBanner: false,
    home: MainScreen(),
  ));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller=TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }
   
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child:Scaffold(
        appBar: AppBar(
          title:const Text('Calculator learning by using bloc'),
          backgroundColor: Colors.blue,
        ),
        body: BlocConsumer<CounterBloc,CounterState>(
          listener: (context,state){
            _controller.clear();
          },
          builder: (context,state){
            final invalidValue=
            (state is CounterStateInvalidNumber)? state.invalidValue:"";
            return Column(
                children: [
                  Text("current value = >${state.value}"), 
                  Visibility(
                    visible:state is CounterStateInvalidNumber,
                    child: Text('Invalid input :$invalidValue'),
                  ),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                       hintText: "Enter a number",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      TextButton(onPressed: (){
                        context.read<CounterBloc>().add(DecrementEvent(_controller.text));
                      }, child: const Text('-')),
                      TextButton(onPressed: (){
                        context.read<CounterBloc>().add(IncrementEvent(_controller.text));
                      }, child:const Text('+')),
                    ],
                  )
                ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState{
  final int value;

  const CounterState(this.value);
}

class CounterStateValid extends CounterState{
  const CounterStateValid(super.value);

}

class CounterStateInvalidNumber extends CounterState{
  final String invalidValue;
  const CounterStateInvalidNumber({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue );
}

abstract class CounterEvent{
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent{
    const IncrementEvent(super.value); 
}

class DecrementEvent extends CounterEvent{
    const DecrementEvent (super.value); 
}

class CounterBloc extends Bloc<CounterEvent,CounterState>{
  CounterBloc():super(const CounterStateValid(0)){
     on<IncrementEvent>((event, emit) {
       final integer=int .tryParse(event.value);
       if(integer==null){
        emit(
          CounterStateInvalidNumber(invalidValue: event.value, previousValue:state.value),
        );
       }else{
        emit(
          CounterStateValid(state.value + integer),
        );
       }
     },);
     on<DecrementEvent>((event, emit) {
       final integer=int.tryParse(event.value);
       if(integer==null){
          emit(
            CounterStateInvalidNumber(invalidValue: event.value,  previousValue:state.value)
          );
       }else{
        emit(
          CounterStateValid(state.value-integer),
        );
       }
     },);
  }
}