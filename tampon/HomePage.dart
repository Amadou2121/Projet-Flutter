import 'package:monrdvm/Pages/RendezVous.dart';
import 'package:flutter/material.dart';
class HomePage extends StatelessWidget{
	const HomePage({Key? key}):super(key: key);

	@override
	Widget build(BuildContext context){
		return 	 Center(
			          child:Column (
			          mainAxisAlignment:MainAxisAlignment.center,
                          children: [
                          Image.asset("assets/images/rdv.jpg"),
                      const   Text("Bienvenus dans votre App de Rendez-vous mensuel",
                          style: TextStyle(
                          	fontSize: 45,
                          ),//TextStyle
	        	),//Text
	        const	Text("Votre assistant de Rendez-Vous mensuel",
	        	style:TextStyle(
	        		fontSize: 25,
	        	),//TextStyle
	        	textAlign:TextAlign.center,
		),//Text
		Padding(padding: EdgeInsets.only(top:10)),
		ElevatedButton.icon(
		    style: ButtonStyle(		 
		        padding: MaterialStatePropertyAll(EdgeInsets.all(10)),
		    	backgroundColor: MaterialStatePropertyAll(Colors.green)
		    ),
			onPressed: () {
				Navigator.push(
					context,
					PageRouteBuilder(
						pageBuilder:(_, __, ___) => RendezVous()
					)
				);
			},
			label: Text("Planing",
		    	style: TextStyle(
			    	fontSize:15,
			),
			),
			icon:Icon(Icons.calendar_month),
		)
		],
		) //Column
		) //Center
	); //Scafold
	}
}
