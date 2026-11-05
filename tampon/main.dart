import 'package:monrdvm/Pages/HomePage.dart';
import 'package:monrdvm/Pages/RendezVous.dart';
import 'package:monrdvm/Pages/Add.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget{
	const MyApp({Key? key}):super(key: key);
	
	     @override
	     State<MyApp> createState() => _MyAppState();
	    }
class _MyAppState extends State<MyApp> {

    int currentIndex = 0 ;
    SetCurrentIndex(int index){
    	setState(() {
    		_currentIndex = index;
    	});
    }

	@override 	   
	     Widget build(BuildContext context){
	         return MaterialApp(
	         home: Scaffold(
	         	appBar: AppBar(
	         		title: [
	         			Text("Acceuil"),
	         			Text("Vous Rencontres"),
	         			Text("Ajouter une rencontre"),
	         		][_currentIndex],
	         		), //AppBar
	         	body:[
	         		HomePage(),
	         		RendezVous(),
	         		Ajout()
	         	][_currentIndex],
	         	buttonNavigationBar:ButtonNavigationBar(
	         	currentIndex: _currentIndex,
	         	onTap: (index) => setCurrentIndex(index),
	         	type:ButtonNavigationBarType.fixed,
	         	selectedItemColor:Colors.green,
	         	unselectedItemColor:Colors.black,
	         	IconSize: 30,
	         		items:const [
	         		ButtonNavigationBarItem(
	         			icon: Icon(Icons.home),
	         			label:'HomePage'
	         		) ,
	         		 ButtonNavigationBarItem(
                         icon: Icon(Icons.calendar_month),
                         label:'RendezVous'
                   ) ,
                    ButtonNavigationBarItem(
                         icon: Icon(Icons.add),
                         label:'Ajouter'
                         ),
	         		],
	         	)//ButtonNavigationBar
	         ),//Scaffold
	         ); //MaterialApp
	   }
}		
