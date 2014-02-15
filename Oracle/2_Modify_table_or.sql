/*2)
Définissez une séquence afin de faciliter la mise en place d’un numéro pour chaque membre. La séquence doit commencer avec la valeur 1 et elle possédera un pas d’incrément de 1.*/
-- test oracle ok
CREATE SEQUENCE seq_numero_membre START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_numero_emprunt START WITH 1 INCREMENT BY 1;

 -- en oracle Utilisation de seq_numero_membre.nextval au moment de l'insertion d'une nouvelle colonne

/*3)
Les membres sont très nombreux et si certains sont des lecteurs assidus, d’autres au contraire ne renouvellent pas leur adhésion tous les ans. Pour ces derniers, il n’est pas souhaitable d’avoir des informations en double dans la base. Aussi il ne doit pas être possible d’avoir deux membres qui possèdent même nom, prénom et numéro de téléphone fixe. Définissez une contrainte d’intégrité afin de satisfaire cette nouvelle exigence. La contrainte sera ajoutée sur la table des membres par l’intermédiaire de l’instruction « alter table ».*/
-- test oracle ok
ALTER TABLE Membre
    ADD CONSTRAINT membre_unique UNIQUE(numero_membre, nom, prenom, telephone);

/* 4)
De plus en plus de membres possèdent deux numéros de téléphone : un pour le poste fixe de leur domicile et un pour leur téléphone portable. Malheureusement la base ne nous permet de stocker qu’un seul numéro de téléphone. Apportez les modifications de structure nécessaires pour prendre en compte cette modification.
Comme cette nouvelle colonne va contenir des informations relatives à un numéro de portable, mettez en place une contrainte d’intégrité afin de vous assurez que le numéro de téléphone saisi commence par « 06 ». */
--test oracle ok
ALTER TABLE Membre
    ADD telephone_portable VARCHAR(10) NOT NULL;

	ALTER TABLE Membre
    ADD CONSTRAINT cc_telephone_portable CHECK (REGEXP_LIKE (telephone_portable, '^[0]{1}[6]{1}[0-9]{8}$'));

/* 5)
Parmi les membres inscrits, la très grande majorité est constituée d’étudiants. S’ils ont presque toujours un téléphone portable, il est beaucoup plus rare qu’ils disposent d’un téléphone fixe. Aussi nous ne souhaitons pas conserver cette colonne. Comme la base de donnée fonctionne pendant la journée (8h-20h), il va falloir réaliser ce travail en deux étapes. Tout d’abord, marquez cette colonne comme inutilisable, puis lorsque la charge de travail sera moindre pour le moteur de base de données, alors demandez la suppression de cette colonne.*/
-- test oracle ok
ALTER TABLE Membre
    DROP CONSTRAINT membre_unique;
ALTER TABLE Membre
    SET UNUSED (telephone);
ALTER TABLE Membre
    DROP UNUSED COLUMNS;
ALTER TABLE Membre
    ADD CONSTRAINT pk_membre UNIQUE(numero_membre, nom, prenom, telephone_portable);

/* 6)
Afin d’améliorer les performances d’accès aux données, définissez un index sur toutes les colonnes de type clé étrangère. Ainsi, les opérations de jointure seront plus rapides.*/
-- test oracle ok
CREATE INDEX IDX_OUVRAGE_OUVRAGE_GENRE ON Ouvrage (code_genre);
CREATE INDEX IDX_EXEMPLAIRE_ISBN ON Exemplaire (isbn);
CREATE INDEX IDX_EMPRUNT_NBMEMBRE ON Emprunt (numero_membre);
CREATE INDEX IDX_NUMERO_DETAILS_EMPRUNT ON Details_emprunt(numero_detail);
CREATE INDEX IDX_ISBN_EXEMPLAIRE ON Details_emprunt(isbn, exemplaire);

/* 7)
A l’usage, on se rend compte que lorsque l’on souhaite supprimer une fiche d’emprunt, il faut nécessairement supprimer toutes les lignes précédentes
dans la table « DETAILS EMPRUNTS » qui font référence à la table « EMPRUNTS » que l’on souhaite supprimer. Comment est-il possible de rendre automatique une telle suppression ?*/
-- test oracle ok
ALTER TABLE Details_Emprunt
    DROP CONSTRAINT fk_details_emprunt;

ALTER TABLE Details_Emprunt
    ADD CONSTRAINT fk_details_emprunt FOREIGN KEY (numero_emprunt) REFERENCES Emprunt(numero_emprunt) ON DELETE CASCADE;

/* 8) Modifiez la table des exemplaires afin que la colonne « Etat » prenne par défaut la valeur « Neuf » pour signifier que l’état d’un nouvel exemplaire est par défaut neuf.*/
-- test oracle ok
ALTER TABLE Exemplaire MODIFY (etat DEFAULT 'Neuf');

/* 9)
Le terme de « membre » choque certains de nos interlocuteurs qui les considèrent comme des « abonnés ». Pour d’autres au contraire, ce sont des membres et à ce titre, ils possèdent le privilège de pouvoir emprunter des livres. Afin de résoudre simplement le problème, définissez le synonyme « abonnes » pour la table des membres. Ainsi dans les futuresrequêtes, il sera possible de faire référence à la table des membres ou bien à la table des abonnés.*/
-- test oracle ok
CREATE SYNONYM Abonnes FOR Membre;

/* 10) Après réflexion, la table « DETAILS EMPRUNTS » n’est pas bien nommée. On lui préférera le nom « DETAILS ». Renommez la table afin de prendre en compte cette nouvelle exigence. */
-- test oracle ok
ALTER TABLE Details_Emprunt RENAME TO Details;

