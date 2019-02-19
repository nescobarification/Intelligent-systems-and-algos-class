(clear)

/*********************************************
*Global variables
*********************************************/
(defglobal ?*trace* = TRUE)
(defglobal ?*heure-du-meutre* = 0)
(defglobal ?*meurtrier* = Personne)
(defglobal ?*highest* = 0)

/*********************************************
*Templates facts
*********************************************/
(deftemplate etudiant
"Les étudiant en camping"
    (slot nom)
    (slot objet)
    (slot blessure(default intacte))
    (slot age)
    (slot profession)
    (slot couleur-cheveux)
    (slot nbr-consommation)
    (slot genre)
    (slot appeal (default 0))
    (slot influencable(type INTEGER) (default 0)); Seulement 0 ou 1
    (slot homophobe(type INTEGER) (default 0)); Seulement 0 ou 1
)

(deftemplate place
    "Les emplacements"
    (slot nom)
    (slot drogue-spot (type INTEGER) (default 0));Seulement 0 ou 1
)

/*********************************************
*Querys
*********************************************/
(defquery query-motif-etudiant
    "Identifier les motifs des etudiants"
    (declare (variables ?suspect))
    (motif ?suspect ?victime ?motif ?poids)
)
(defquery query-suspect
    "Identifier les motifs des etudiants"
    (declare (variables ?suspect))
    (etudiant (nom ?suspect))
    (not (est-mort ?suspect))
    (est-suspect ?suspect)

)

(defquery query-etudiants-vivants
    "Liste les etudiants vivants"

    (declare (variables ?n))
    (etudiant(nom ?n))
    (not (est-mort ?n))
)

(deffunction calculer-drague (?n ?ap)
    ;Collect Name/Appeal from every Etudiants
    (bind ?appresults (run-query* query-appeal-etudiants))
    ;Loop through results
    (while (?appresults next)
        (bind ?othAp (?appresults getInt appeal))
        (bind ?othN (?appresults get nom))
        ;If name is different and Other Appeal is between Self Appeal and Self Appeal + 3
        (if (<= ?ap ?othAp) then
            (bind ?tempAp (+ ?ap 3))
            (if (>= ?tempAp ?othAp) then
                (if (<> ?othN ?n) then
                    ;Assert that Self "Drague" Other
                    (printout t ?n " drague " ?othN crlf)
                    (assert (drague ?n ?othN))
                )
            )
        )
    )
)
/*********************************************
*Function
*********************************************/
(deffunction process-appeal (?n ?cc ?a ?p ?g)
    (bind ?sa 0)

    ;Bloc Couleur-Cheveux
    (if(eq ?cc rouge) then
        (bind ?sa (+ ?sa 10)))
    (if(eq ?cc bleu) then
        (bind ?sa (+ ?sa 1)))
    (if(eq ?cc noir) then
        (bind ?sa (+ ?sa 5)))
    (if(eq ?cc brun) then
        (bind ?sa (+ ?sa 3)))

    ;Bloc Age
    (if(<= ?a 20) then
        (bind ?sa (+ ?sa 5)))
    (if(>= ?a 21) then
        (bind ?sa (+ ?sa 1)))

    ;Bloc Profession
    (if(eq ?p danseur) then
        (bind ?sa (+ ?sa 10)))
    (if(eq ?p developpeur) then
        (bind ?sa (+ ?sa 5)))
    (if(eq ?p testeur) then
        (bind ?sa (+ ?sa 1)))
    (if(eq ?p chanteur) then
        (bind ?sa (+ ?sa 3)))

    (return ?sa)
)


(deffunction determiner-niveau-bully (?n ?c ?cc ?a ?p ?g)
	(bind ?po 0)
	;(printout t "Dans la fonction determiner-niveau-bully." crlf)
    (if (> ?c 5) then
        (bind ?po (+ ?po 5))
        ;(printout t ?n " => Consommations au-dessus de 5." crlf)
	    (if (or (eq ?cc rouge) (regexp ^.*u.*$ ?cc)) then
	    	(bind ?po (+ ?po 10))
	    	;(printout t ?n " => Couleur de cheveux rouge ou contenant la lettre 'u'." crlf)
        )

	    (if (< ?a 25) then
	    	(bind ?po (+ ?po 5))
	    	;(printout t ?n " => Âgé de 24 ans et moins." crlf)
        )

        (if (regexp ^.*eu.*$ ?p) then
	    	(bind ?po (+ ?po 10))
	    	;(printout t ?n " => Profession contenant les lettres 'eu'." crlf)
        )
	)
	(if (regexp ^.*an.*$ ?p) then
        (bind ?po (+ ?po 10))
        ;(printout t ?n " => Profession contenant les lettres 'an'." crlf)
	    (if (or (eq ?cc brun) (eq ?cc noir)) then
	    	(bind ?po (+ ?po 5))
	    	;(printout t ?n " => Couleur de cheveux rouge ou noir." crlf)
        )
	)
    (return ?po)
)
/*********************************************
* Rule  for Appeal Calculation
*********************************************/
(defrule evaluate-appeal
    (declare (salience 9999))
      ?etu <- (etudiant
            (couleur-cheveux $?cc)
            (age $?a)
            (profession $?p)
            (genre $?g)
            (nom $?n)
            (appeal $?ap)
        )
    =>
    ;Set the newly calculated Appeal value on the facts
    (modify ?etu (appeal (process-appeal ?n ?cc ?a ?p ?g)))
    ;Only print after processing is done
    (if (<> ?ap 0) then
        (printout t ?n " a un sex-appeal de " ?ap crlf)
    )
)


/*********************************************
* END Rule for Appeal Calculation END
*********************************************/

/*********************************************
* Rule: determiner-jalousie
*********************************************/
(defrule determiner-jalousie
    "Determiner si un etudiant jaloux de la victime"

    (etudiant (nom ?suspect) )
    (est-interesser-par ?suspect ?p2 )
    (drague ?p1 ?p2 )

    =>
    (assert (motif ?suspect ?p1 jalousie 40))
    (if ?*trace* then
        (printout t ?suspect " est jaloux de " ?p1 crlf))

)

/*********************************************
* END Rule: determiner-jalousie END
*********************************************/

/*********************************************
*  Rule: determiner-suspect-capilaire
*********************************************/
;On suppose que la police n'a pas de budget pour des
;tests d'ADN donc on se base seulement sur les cheveux
(defrule determiner-suspect-capilaire
    (est-mort ?victime ?trace ?trace-chvx-sur-victime)
    (etudiant (couleur-cheveux ?trace-chvx-sur-victime) (nom ?nom)  );potentiel suspect
    (etudiant (couleur-cheveux ?trace-chvx-sur-victime) (nom ?victime) );victime
    (test (neq ?nom ?victime))
    =>
    (assert (suspect-raison-capilaire ?nom))
    (printout t  "Le suspect a les cheveux " ?trace-chvx-sur-victime crlf)
)
/*********************************************
*  END Rule: determiner-suspect-capilaire END
*********************************************/

/*********************************************
*   Rule: determiner-trace-meurtre
*********************************************/
(defrule determiner-trace-meurtre
    (est-mort ?nom ?trace ?c)
    (objet ?obj ?trace)
    =>
    (assert (arme-du-crime ?obj) )
    (printout t  "L'arme du crime est " ?obj crlf)
)
/*********************************************
*  END Rule: determiner-trace-meurtre END
*********************************************/

/*********************************************
*   Rule: determiner-bully
*********************************************/
(defrule determiner-bully
	(etudiant
		(nbr-consommation $?c)
		(couleur-cheveux $?cc)
		(age $?a)
		(profession $?p)
		(genre $?g)
		(nom $?n&:(> (determiner-niveau-bully $?n $?c $?cc $?a $?p $?g) 30)))
=>
(assert (suspect-bully $?n))
(printout t $?n " a le plus de motifs pour harceler les autres personnes." crlf))
/*********************************************
*  END Rule: determiner-bully END
*********************************************/



/*********************************************
*   Rule: determiner-suspect-arme
*********************************************/
(defrule determiner-suspect-arme
    (etudiant
        (nom ?n)
        (objet ?obj))
    (objet ?obj ?trace)
    (est-mort ?nom ?trace ?c)

    =>

    (assert (est-suspect ?n))
    (printout t ?n " est un suspect puisqu'il a le même arme utilisé durant le crime: " ?obj crlf)
)
/*********************************************
*  END Rule: determiner-suspect-arme END
*********************************************/

/*********************************************
*   Rule: determiner-emplacement-meurtre
*********************************************/
(defrule determiner-emplacement-meurtre
	(est-mort ?nom ?trace ?cheveux)
	(etudiant
		(nom ?n&:(eq ?n ?nom)))
    (emplacement-meurtre ?em)
    (emplacement ?n ?em ?heure)
=>
(assert (emplacement-meurtre ?em))
(printout t ?n " est mort. L'emplacement du meutre est " ?em " et il y était à " ?heure " heures." crlf))

/*********************************************
*FIN Rule: determiner-emplacement-meurtre  FIN
*********************************************/


/*********************************************
* Rule: determiner-etudiant-drogue
*********************************************/
(defrule determiner-etudiant-drogue
    "Determiner si l'etudiant est un drogue"
    (etudiant (nom ?etudiant-nom ) {influencable == 1})
    (place (nom ?place-nom) {drogue-spot == 1})
    (emplacement ?etudiant-nom ?place-nom ?debut ?fin)
    =>
    (assert (est-drogue ?etudiant-nom))
    (if ?*trace* then
        (printout t ?etudiant-nom " s'est drogué " crlf))
)
/*********************************************
* FIN Rule: determiner-etudiant-drogue FIN
*********************************************/

/*********************************************
*  Rule: determiner-joueur-saoul
*********************************************/
; Determine si un etudiant est saoul.
(defrule determiner-joueur-saoul
    (etudiant { nbr-consommation > 8 } (nom ?name))
    =>
    (assert (est-saoul ?name))
    (if ?*trace* then
        (printout t ?name " est saoul" crlf))
)
/*********************************************
*FIN  Rule: determiner-joueur-saoul FIN
*********************************************/


/*********************************************
*  Rule: determiner-motif-homophobie
*********************************************/
(defrule determiner-motif-homophobie
    "Determiner si un etudiant a un motif homophobique pour tuer quelqu<un"
    (etudiant (homophobe ?h) (nom ?nom) )
    (personnes-en-relation-same-sexe ?n1 ?g1)
    (test (neq ?nom ?n1))
    (test (neq ?nom ?g1))
    =>
    (assert(motif ?nom ?n1 homophobie 50))
    (assert(motif ?nom ?g1 homophobie 50))
    (if ?*trace* then
        (printout t ?nom " a un motif homophobique pour tuer " ?n1 crlf)
        (printout t ?nom " a un motif homophobique pour tuer " ?g1 crlf)
    )
)
/*********************************************
*FIN  Rule: determiner-motif-homophobie FIN
*********************************************/

/*********************************************
*  Rule: determiner-heure-meurtre
*********************************************/
(defrule determiner-heure-meurtre
  (est-mort ?n ?t ?c)
  (emplacement ?n ?l ?h)
  =>
  (if (> ?h ?*heure-du-meutre*) then
    (bind ?*heure-du-meutre* ?h)
    (assert (heure-du-meurtre ?h))
    (printout t "L'heure du meurtre est estimé à " ?h crlf)
    )
)
/*********************************************
*FIN  Rule: determiner-heure-meurtre FIN
*********************************************/

/*********************************************
*  Rule: trouver-arme-du-crime
*********************************************/
(defrule trouver-arme-du-crime
    "Identifier l'arme du crime "
    (est-mort ?mort ?t ?c)
    (etudiant (blessure ?blessure) (nom ?nom))
    (arme ?arme ?blessure)
    =>
    (if ?*trace* then
        (printout t "L'arme du crime est un(e) " ?arme crlf))
)
/*********************************************
*FIN  Rule: trouver-arme-du-crime FIN
*********************************************/

/*********************************************
*  Rule: zodiaque-chinois
*********************************************/
(defrule zodiaque-chinois
   "Déterminer le signe zodiaque chinois"
   (etudiant { age > 0 } (age ?age) (nom ?nom))
   =>
   (bind ?animals (list rat boeuf tigre lapin dragon serpent cheval chèvre singe coq chien cochon))
   (bind ?signe (nth$ (+ (mod (- (- 2017 ?age) 5) 12) 1) ?animals))
   (assert (est-du-signe-zodiaque-chinois ?nom ?signe))
   (printout t  ?nom " " ?age " ans (" (- 2017 ?age) ") est du signe du " ?signe  crlf)
)
/*********************************************
*FIN  Rule: zodiaque-chinois FIN
*********************************************/

/*********************************************
*  Rule: les-serpents-attaquent-les-rats
*********************************************/
(defrule les-serpents-attaquent-les-rats
    "Les signes du serpents ont une haine pour les rats."
    (emplacement ?n1 ?lieu ?hd1 ?hf1)
    (emplacement ?n2 ?lieu ?hd1 ?hf2)
    (est-du-signe-zodiaque-chinois ?n1 serpent)
    (est-du-signe-zodiaque-chinois ?n2 rat)
    (not (haine-serpent-rat ?n1 ?n2))
    =>
    (assert (motif ?n1 ?n2 haine 20))
    (assert (haine-serpent-rat ?n1 ?n2))
    (printout t  ?n1 " signe du serpent attaque " ?n2 " parce qu'il est du signe du rat." crlf)
)
/*********************************************
* FIN Rule: les-serpents-attaquent-les-rats FIN
*********************************************/

/*********************************************
*  Rule: determiner-relation-same-sexe
*********************************************/
(defrule determiner-relation-same-sexe
    "Identifier si des relations sont toxiques pour le meurtrier"
    (etudiant (nom ?n1) (genre ?g1))
    (etudiant (nom ?n2) (genre ?g2))
    (relation ?n1 ?n2)
    =>
    (if (eq ?g1 ?g2) then
        (if ?*trace* then
            (printout t ?n1 " et " ?n2 " ont une relation de " ?g1 " à " ?g2 crlf)
            (assert (personnes-en-relation-same-sexe ?n1 ?g1))
        )
    )
)
/*********************************************
* FIN Rule: determiner-relation-same-sexe FIN
*********************************************/

/*********************************************
*  Rule: trouver-suspect
*********************************************/
;SSi un etudiant nest pas mort et a plus de 3 motifs
;dont la somme est superieur, il est un potentiel suspect
(defrule trouver-suspect 
    "Identifier tous les suspect"
    (etudiant (nom ?nom))
    (not (est-mort ?nom))
    =>
    (bind ?motifs (run-query* query-motif-etudiant ?nom))
    (bind ?motifs-count (count-query-results query-motif-etudiant ?nom))

            (if (> ?motifs-count 3) then
                (bind ?poids 0)
                (while (?motifs next)
                    (bind ?poids (+ ?poids (?motifs getInt poids)))
                )

                (if (> ?poids 15) then
                    (assert(est-suspect  ?nom))
                    (if ?*trace* then
                        (printout t  ?nom " est un suspect(e)" crlf))
                )
            )
 )
 /*********************************************
 * FIN Rule: trouver-suspect FIN
 *********************************************/

 /*********************************************
 *  Rule: determiner-suspect-de-deplacement
 *********************************************/
(defrule determiner-suspect-de-deplacement
    "Determmminer les suspsect  base sur les deplacements  possible a  un temps et emplacement donnée"
    (emplacement ?suspect ?lieu-initial ?d1 ?f1)
    (deplacement-temps ?lieu-initial ?lieu-meurtre ?temps)
    (etudiant (nom ?suspect))

    (emplacement ?victime ?lieu-meurtre ?d2 ?f2)
    (emplacement-meurtre ?lieu-meurtre)
    =>
    (bind ?heure-parti (/ (- ?f1 ?d1) 2));Estimation
    (bind ?heure-darrive (+ ?heure-parti ?temps));Estimation

    ;(printout t  "YOLO" crlf)

    (if (and (>= ?f2 ?heure-darrive ) ) then
        (assert(suspect-deplacement ?suspect))
        (if ?*trace* then
            (printout t  ?suspect " est un suspect dû au faite qu'il/elle pouvais se deplacer sur le lieu du crime" crlf))

    )

)
/*********************************************
* FIN Rule: determiner-suspect-de-deplacement FIN
*********************************************/

/*********************************************
*  Rule: trouver-meurtrier
*********************************************/
(defrule trouver-meurtrier
    "Identifier le meurtrier"
    (declare (salience -100))

    (etudiant (nom ?meurtrier))
    (not(est-mort ?meurtrier))
    (est-suspect ?meurtrier)
    (or(suspect-deplacement  ?meurtrier)
        (suspect-raison-capilaire ?meurtrier)
        (suspect-bully ?meurtrier))

    =>
    ;Compte des (est-suspect)
    (bind ?chance (count-query-results  query-suspect ?meurtrier))

    (if (> ?chance ?*highest*) then
        (bind ?*highest* ?chance)
        (bind ?*meurtrier* ?meurtrier)
        (assert (est-meurtrier ?meurtrier))
    )

    (if ?*trace* then
        (printout t  "Le meurtrier est " ?*meurtrier* crlf))
 )
 /*********************************************
 * FIN Rule: trouver-meurtrier FIN
 *********************************************/

/*********************************************
* Rule: determiner-drague
*********************************************/
;Wrapper rule to evaluate "Drague" relationships
(defrule determiner-drague
    "Determiner qui chaque etudiant drague"
    (declare (salience 1))
    (etudiant
        (nom $?n)
        (appeal $?ap)
    )
    =>
    (calculer-drague ?n ?ap)
)
/*********************************************
* FIN Rule: determiner-drague FIN
*********************************************/

/*********************************************
* Rule: query-appeal-etudiants
*********************************************/
;Query to obtain Name/Appeal from every student
(defquery query-appeal-etudiants
    "Obtain appeal from all students"
    (etudiant (nom ?nom) (appeal ?appeal))
)
/*********************************************
* FIN Rule: query-appeal-etudiants FIN
*********************************************/
