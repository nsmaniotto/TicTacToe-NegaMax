	/*
	Ce programme met en oeuvre l'algorithme Minmax (avec convention
	negamax) et l'illustre sur le jeu du TicTacToe (morpion 3x3)
	*/
	
:- [tictactoe].


	/****************************************************
  	ALGORITHME MINMAX avec convention NEGAMAX : negamax/5
  	*****************************************************/

	/*
	negamax(+J, +Etat, +P, +Pmax, [?Coup, ?Val])

	SPECIFICATIONS :

	retourne pour un joueur J donne, devant jouer dans
	une situation donnee Etat, de profondeur donnee P,
	le meilleur couple [Coup, Valeur] apres une analyse
	pouvant aller jusqu'a la profondeur Pmax.

	Il y a 3 cas a decrire (donc 3 clauses pour negamax/5)
	
	1/ la profondeur maximale est atteinte : on ne peut pas
	developper cet Etat ; 
	il n'y a donc pas de coup possible a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique.

	2/ la profondeur maximale n'est pas  atteinte mais J ne
	peut pas jouer ; au TicTacToe un joueur ne peut pas jouer
	quand le tableau est complet (totalement instancie) ;
	il n'y a pas de coup a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique.

	3/ la profondeur maxi n'est pas atteinte et J peut encore
	jouer. Il faut evaluer le sous-arbre complet issu de Etat ; 

	- on determine d'abord la liste de tous les couples
	[Coup_possible, Situation_suivante] via le predicat
	 successeurs/3 (deja fourni, voir plus bas).

	- cette liste est passee a un predicat intermediaire :
	loop_negamax/5, charge d'appliquer negamax sur chaque
	Situation_suivante ; loop_negamax/5 retourne une liste de
	couples [Coup_possible, Valeur]

	- parmi cette liste, on garde le meilleur couple, c-a-d celui
	qui a la plus petite valeur (cf. predicat meilleur/2);
	soit [C1,V1] ce couple optimal. Le predicat meilleur/2
	effectue cette selection.

	- finalement le couple retourne par negamax est [Coup, V2]
	avec : V2 is -V1 (cf. convention negamax vue en cours).

A FAIRE : ECRIRE ici les clauses de negamax/5
.....................................
	*/

	negamax(J, Etat, Pmax, Pmax, [rien, Val]) :-	% cas 1
		
		heuristique(J, Etat, Val),!.

	negamax(J, Etat, _, _, [rien, Val]) :-	% cas 2
		
		ground(Etat), 	% Le tableau est complet (totalement instanci�)
		heuristique(J, Etat, Val),!.

	negamax(J, Etat, P, Pmax, [MC1,MV]) :-	% cas 3
		
		% CP: Coup_possible
		% SS: Situation_suivante
		% LCP: Liste_coups_possibles
		
		successeurs(J, Etat, LCP),
		

		% LC: Liste_de_couples
		loop_negamax(J, P, Pmax, LCP, LC),
		

		% MC: Meilleur_Couple
		meilleur(LC, [MC1, MV1]),
		MV is -MV1.
		

	test_negamax() :-
		joueur_initial(J),

		% Cas 1
		situation_initiale(Etat1),
		negamax(J, Etat1, 0, 0, [rien, _]),

		% Cas 2
		Etat2 = [[x,o,x], [o,x,o], [o,x,o]],
		negamax(J, Etat2, 0, 1, [rien, _]),

		% Cas 3
		situation_initiale(Etat3),
		negamax(J, Etat3, 0, 1, [Coup, _]),
		Coup \= rien.


	/*******************************************
	 DEVELOPPEMENT D'UNE SITUATION NON TERMINALE
	 successeurs/3 
	 *******************************************/

	 /*
   	 successeurs(+J,+Etat, ?Succ)

   	 retourne la liste des couples [Coup, Etat_Suivant]
 	 pour un joueur donne dans une situation donnee 
	 */

successeurs(J,Etat,Succ) :-
	
	copy_term(Etat, Etat_Suiv),
	
	findall([Coup,Etat_Suiv],
		    successeur(J,Etat_Suiv,Coup),
		    Succ).
	

	/*************************************
         Boucle permettant d'appliquer negamax 
         a chaque situation suivante :
	*************************************/

	/*
	loop_negamax(+J,+P,+Pmax,+Successeurs,?Liste_Couples)
	retourne la liste des couples [Coup, Valeur_Situation_Suivante]
	a partir de la liste des couples [Coup, Situation_Suivante]
	*/


loop_negamax(_,_, _  ,[],                []). 
loop_negamax(J,P,Pmax,[[Coup,Suiv]|Succ],[[Coup,Vsuiv]|Reste_Couples]) :-
	
	loop_negamax(J,P,Pmax,Succ,Reste_Couples), % permet de récupérer la liste (Reste_Couples) des coups avec leur valeur associée
	adversaire(J,A), % on passe à l'adversaire
	Pnew is P+1, % on augmente le compteur de profondeur
	negamax(A,Suiv,Pnew,Pmax, [_,Vsuiv]). % on exécute l'algorithme negamax du point de vue de l'adversaire ; permet de récupérer la valeur du coup courant

	/*

A FAIRE : commenter chaque litteral de la 2eme clause de loop_negamax/5,
	en particulier la forme du terme [_,Vsuiv] dans le dernier
	litteral ?
	*/

	/*********************************
	 Selection du couple qui a la plus
	 petite valeur V 
	 *********************************/

	/*
	meilleur(+Liste_de_Couples, ?Meilleur_Couple)

	SPECIFICATIONS :
	On suppose que chaque element de la liste est du type [C,V]
	- le meilleur dans une liste a un seul element est cet element
	- le meilleur dans une liste [X|L] avec L \= [], est obtenu en comparant
	  X et Y,le meilleur couple de L 
	  Entre X et Y on garde celui qui a la petite valeur de V.

A FAIRE : ECRIRE ici les clauses de meilleur/2
	*/

	meilleur([Couple], Couple). % Le meilleur dans une liste � 1 �l�ment est ce �l�ment
	
	meilleur([[C, V] | Couple_suivant], Meilleur_Couple) :- 
		meilleur(Couple_suivant, [MC1, MV1]),

		(MV1 < V) -> 
			Meilleur_Couple = [MC1, MV1]
			;
			Meilleur_Couple = [C, V].		

	test_meilleur() :-
		meilleur([[[2,2], 4]], Couple1),
		Couple1 = [[2,2], 4],

		Liste_Couples = [[_, 4] | [[_, 3]]],
		meilleur(Liste_Couples, Meilleur_Couple),
		Meilleur_Couple = [_, 3].

	/******************
  	PROGRAMME PRINCIPAL
  	*******************/

main(B,V, Pmax) :-
	joueur_initial(J),
	situation_initiale(I),
	negamax(J, I, 0, Pmax, [B, V]).


	/*
A FAIRE :
	Compl�ter puis tester le programme principal pour plusieurs valeurs de la profondeur maximale.
	Pmax = 1, 2, 3, 4 ...
	Commentez les r�sultats obtenus.
	*/

