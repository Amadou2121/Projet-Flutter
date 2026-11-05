import 'package:flutter/material.dart';

class Ajout extends StatefulWidget{
	const Ajout({Key? key}) : super(key : key);
	
    @override
    State<Ajout> createState() => _State();
    	
    }
class _Ajout extends State<Ajout> {
    final _formKey= GlobalKey<FormState>();
    
    final controleDuNomDeLaConference=TextEditingController();
    
    final controleDuNomDuConferencier=TextEditingController();
    
	@override
	WidgetBuild (BuildContext context){
		return Container(
		margin:EdgeInsets.all(15),
			child:Form(
			key: _formKey,
			child:Column(
				children : [
					TextFormField(
						decoration:ImputDecoration(
							labelText: "Intitule de la rencontre",
							hinText:"Entrer le nom de la conference",
							border:OutlineImputBorder()
						),
						validator:(value){
							if(value==null || value.isEmpty){
								return "Vous devez donner le Nom de la conference";		
							}
							return null;
						}
					),
					SizedBox(height:10),
					SizedBox(
						width: double.infinity,
						height: 50,
						child:ElevatedButton(
							onPressed:() {
								if(_formKey.currentState!.validate()){
									ScaffoldMessenger.of(context).showSnackBar(
										const SnackBar(content: Text("Envoi en cours..."))
									);
									FocusScope.of(context).requestFocus(FocusMode());
								}
							},
							child: Text("Envoyer")
						)
					)
				]
			)
		);
	 )
	}
}    
