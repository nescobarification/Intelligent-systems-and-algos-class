(deffacts my-facts
    (etudiant
        (nom Margaret)
        (couleur-cheveux brun)
        (profession comptable)
        (age 20)
        (objet baguettes-a-cheveux)
        (blessure perforation)
        (nbr-consommation 5)
        (genre femme)
    )
    (etudiant
        (nom Christopher)
        (couleur-cheveux gris)
        (profession dessinateur)
        (age 20)
        (objet exacto)
        (nbr-consommation 4)
        (genre homme)
    )
    (etudiant
        (nom Angel)
        (couleur-cheveux noir)
        (profession policier)
        (age 27)
        (objet 007-Walther-PPK)
        (blessure coupures)
        (nbr-consommation 12)
        (genre homme)
    )
    (etudiant
        (nom Adeline)
        (couleur-cheveux noir)
        (profession tatoueuse)
        (age 31)
        (nbr-consommation 5)
        (genre femme)
    )
    (etudiant
        (nom Barney)
        (couleur-cheveux noir)
        (profession trader)
        (age 20)
        (objet couteau)
        (nbr-consommation 7)
        (influencable 1)
        (genre homme)
    )
    (etudiant
        (nom Laurence)
        (couleur-cheveux noir)
        (profession cycliste)
        (age 27)
        (blessure perforation)
        (objet pic-a-glace)
        (nbr-consommation 8)
        (genre homme)
    )

    (place (nom depaneur))
    (place (nom parc) (drogue-spot 1))
    (place (nom parking))
    (place (nom condo))

    (relation Margaret Christopher)
    (relation Christopher Margaret)
    (relation Angel Adeline)
    (relation Adeline Angel)

    (est-mort Margaret perforation noir)
    (emplacement-meurtre parc)

    (est-interesser-par Margaret Barney)
    (est-interesser-par Christopher Barney)
    (est-interesser-par Angel Margaret)
    (est-interesser-par Laurence Angel)

    (emplacement Margaret parc 13 15)
    (emplacement Margaret parking 16 18)
    (emplacement Margaret parc 19 21)
    (emplacement Margaret parc 22 23)

    (emplacement Christopher parking 13 23)

    (emplacement Angel depaneur 13 15)
    (emplacement Angel parking 16 18)
    (emplacement Angel parc 19 21)
    (emplacement Angel condo 22 23)

    (emplacement Barney depaneur 13 15)
    (emplacement Barney parc 16 18)
    (emplacement Barney parc 19 21)
    (emplacement Barney depaneur 22 23)

    (emplacement Adeline condo 13 15)
    (emplacement Adeline depaneur 16 18)
    (emplacement Adeline depaneur 19 21)
    (emplacement Adeline parking 22 23)

    (emplacement Laurence parc 13 15)
    (emplacement Laurence depaneur 16 18)
    (emplacement Laurence parking 19 21)
    (emplacement Laurence condo 22 23)

    (objet baguettes-a-cheveux perforation)
    (objet exacto coupures)
    (objet 007-Walther-PPK perforation)
    (objet couteau coupures)
    (objet pic-a-glace perforation)

    (deplacement-temps condo parking 10)
    (deplacement-temps condo depaneur 30)
    (deplacement-temps condo parc 20)

    (deplacement-temps parking condo 10)
    (deplacement-temps parking depaneur 30)
    (deplacement-temps parking parc 30)

    (deplacement-temps depaneur parking  30)
    (deplacement-temps depaneur condo  30)
    (deplacement-temps depaneur parc  20)

    (deplacement-temps parc condo 20)
    (deplacement-temps parc parking 30)
    (deplacement-temps parc depaneur 20)
)