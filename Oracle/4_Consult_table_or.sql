-- ##############################################################################################

/* 4) Extraction simple d’informations
Consultez le contenu de chaque table à l’aide d’une requête d’extraction simple qui permet de visualiser toutes les lignes et toutes les colonnes de chaque table.*/
    
SELECT * FROM Genre;
SELECT * FROM Ouvrage;
SELECT * FROM Exemplaire;
SELECT * FROM Membre;
SELECT * FROM Emprunt;
SELECT * FROM Details;

-- ##############################################################################################

/* 5) Activation de l’historique des mouvements
Les manipulations de la table des membres sont sensibles. Activez l’historique des mouvements sur cette table. Effectuez la même opération sur la table « DETAILS » -- The row_movement_clause lets you specify whether Oracle can move a table row. It is possible for a row to move, for example, during data segment compression or an update operation on partitioned data.*/
ALTER TABLE Membre ENABLE ROW MOVEMENT;
ALTER TABLE Details ENABLE ROW MOVEMENT;

-- ##############################################################################################

/* 6) Ajout d’une colonne :
Pour faciliter la gestion des emprunts et identifier plus rapidement les fiches pour lesquelles l’ensemble des exemplaires n’est pas restitué, il a été décidé d’ajouter une colonne «ETAT »qui peut prendre les valeurs (EC : en cours) par défaut et (RE : rendue) lorsque l’ensemble des exemplaires est rendu. Ecrivez l’instruction SQL qui permet d’effectuer la modification de structure souhaitée. Mettez à jour l’état de chaque fiche de location en le faisant passer à RE (rendue) si tous les ouvrages empruntés par le membre ont été restitués à la bibliothèque. */

-- Ajout d'une colone nb_emprunt dans la table Exemplaire afin de comptabiliser le nombre d'emprunt de chaque livre
ALTER TABLE Emprunt ADD etat VARCHAR(2) DEFAULT 'EC';
ALTER TABLE Emprunt ADD CONSTRAINT cc_emprunt_etat CHECK(etat IN('RE', 'EC'));

-- Definition de l'état initial
UPDATE emprunt SET etat = 'RE' WHERE numero_emprunt NOT IN (SELECT DISTINCT numero_emprunt FROM details WHERE date_de_rendu IS NULL);

SELECT * FROM Emprunt;

-- ##############################################################################################

/* 7) Mise à jour conditionnelle
On souhaite modifier l’état des exemplaires en fonction de leur nombre de locations afin de faire passer les exemplaires actuellement à l’état Neuf vers l’état Bon et supprimer les exemplaires qui ont été loués plus de 60 fois. En effet, les bibliothécaires considèrent qu’un tel exemplaire doit être retiré de la location car il ne répond pas à la qualité souhaitée par les membres. Les livres sont considérés neufs lorsqu’ils ont été empruntés moins de 11 fois. A partir du 11ème emprunt et jusqu’au 25ème leur état est bon. */

-- Reinitialisation de l'etat de tt les exemplaires

UPDATE exemplaire SET etat = 'Neuf';

-- La sous requête SELECT renvoie la liste des isbn et numero d'exemplaire ayant été comptabilisé plus de n fois dans la table details. 
-- Ces valeurs sont ensuite utilisées pour mettre à jour l'état des exemplaires concernés dans la table Exemplaire
-- POur rendre l'exemple plus interessant le nombre maximal d'emprunt à été abbaissé pour voir des modification de la table

UPDATE exemplaire
SET etat = 'Bon'
WHERE (isbn, numero_exemplaire) IN (
    SELECT  isbn, numero_exemplaire FROM details GROUP BY isbn, numero_exemplaire HAVING COUNT(*) BETWEEN 2 AND 3);

UPDATE exemplaire
SET etat = 'Moyen'
WHERE (isbn, numero_exemplaire) IN (
    SELECT  isbn, numero_exemplaire FROM details GROUP BY isbn, numero_exemplaire HAVING COUNT(*) BETWEEN 4 AND 5);

UPDATE exemplaire
SET etat = 'Mauvais'
WHERE (isbn, numero_exemplaire) IN (
    SELECT  isbn, numero_exemplaire FROM details GROUP BY isbn, numero_exemplaire HAVING COUNT(*) >= 6);

SELECT * FROM exemplaire;

-- ##############################################################################################

/* 8) Supprimez tous les exemplaires dont l’état est mauvais.*/

-- Il n'y a aucun livre a supprimer dans l'exemple...

DELETE FROM exemplaire WHERE etat LIKE 'Mauvais';


-- ##############################################################################################

/* 9) Etablissez la liste des ouvrages que possède la bibliothèque.*/

SELECT isbn, titre FROM ouvrage;


-- ##############################################################################################

/* 10) Etablissez la liste des membres qui ont emprunté un ouvrage depuis plus de deux semaines en indiquant le nom de l’ouvrage.*/

-- Uniquement pour les membres qui n'ont pas encore rendus depuis plus de 2 semaines
--  La limite a été abaissé à 1 semaine pour voir des valeurs

SELECT numero_membre, nom, prenom, titre, date_emprunt
FROM Membre
    JOIN Emprunt USING (numero_membre)
    JOIN Details USING (numero_emprunt)
    JOIN Ouvrage USING (isbn)
WHERE date_de_rendu IS NULL
    AND trunc(sysdate, 'WW') - trunc (date_emprunt, 'WW') >= 1;

-- ##############################################################################################

/* 11) Etablissez le nombre d’ouvrages dont on dispose par catégorie.*/

-- Pour avoir à la fois le nombre d'exemplaires et le libellé du genre, il faut faire une double jointure des tables genre, ouvrage et exemplaire

SELECT libelle, COUNT (*) AS "Nombre d'ouvrages"
FROM ouvrage
    JOIN genre USING (code_genre)
    JOIN exemplaire USING (isbn)
GROUP BY code_genre, libelle
ORDER BY COUNT (*);

-- ##############################################################################################

/* 12) Etablissez la durée moyenne d’emprunt d’un livre par un membre.*/

-- Pour avoir les nom et prenom des membres ainsi que leur durée moyenne d'emprunt,
-- il est necessaire de faire une jointure entre les tables membre, emprunt et details.
-- AVG ne prend pas en compte la valeur si elle est NULL = pas besoin de filtrer date_de rendu NOT NULL
-- Il faut grouper par numero de membre, mais pour rendre l'affichage de sortie plus agréable, nous avons également ajouté les nom et prénom des membres

SELECT nom, prenom, numero_membre, round(AVG(date_de_rendu - date_emprunt)) AS "Durée Moyenne d'emprunt"
FROM Membre 
    JOIN emprunt USING (numero_membre)
    JOIN details USING (numero_emprunt)
GROUP BY numero_membre, nom, prenom
ORDER BY nom;

-- ##############################################################################################

/* 13) Calculez la durée moyenne de l’emprunt en fonction du genre du livre.*/

-- la requete est assez semblable, mais il faut cette fois grouper par genre.
-- De la même façon que precedement, nous avons souhaité ajouter le libellé pour rendre l'affichage plus agréable
-- Il a été necessaire de faire une jointure supllémentaire avec la table Genre. 

SELECT code_genre, libelle, round(AVG(date_de_rendu - date_emprunt)) AS "Durée Moyenne d'emprunt"
FROM ouvrage 
    JOIN details USING (isbn)
    JOIN emprunt USING (numero_emprunt)
    JOIN genre USING (code_genre)
GROUP BY code_genre, libelle;

-- ##############################################################################################

/* 14) Etablissez la liste des ouvrages loués plus de 10 fois au cours des 12 derniers mois.*/

-- Il est necessaire de faire une jointure entre les tables details, emprunt et ouvrage et limitant les résultats
-- pour lequels la date d'emprunt est daté de moins de 12 mois.
-- Les résultats sous ensuite groupé par isbn (et titre) mais seuls les groupes avec plus de 10 emprunts enregistrés sont renvoyés 

SELECT isbn, titre, COUNT (*)  AS "Nombre d'emprunts"
FROM details
    JOIN emprunt USING (numero_emprunt)
    JOIN ouvrage USING (isbn)
WHERE SYSDATE - INTERVAL '12' MONTH <= date_emprunt
GROUP BY isbn, titre
    HAVING COUNT(*) >= 2
ORDER BY COUNT(*) ASC;
 
---- OU

SELECT isbn, titre, COUNT (*)  AS "Nombre d'emprunts"
FROM details
    JOIN emprunt USING (numero_emprunt)
    JOIN ouvrage USING (isbn)
WHERE SYSDATE - 365 <= date_emprunt
GROUP BY isbn, titre
    HAVING COUNT(*) >= 10
ORDER BY COUNT(*) ASC;

-- ##############################################################################################

/* 15) Etablissez la liste de tous les ouvrages avec à côté de chacun d’eux les numéros d’exemplaires qui existent dans la base.*/

SELECT titre, COUNT(*) AS "Nombre d'exemplaires"
    FROM Ouvrage LEFT JOIN exemplaire USING (isbn) 
    GROUP BY titre
    ORDER BY COUNT(*) ASC;

-- OUTDATED LEFT JOIN ALTERNATIVE

SELECT titre, COUNT(*) AS "Nombre d'exemplaires"
    FROM Ouvrage, Exemplaire
WHERE  Ouvrage.isbn (+) = Exemplaire.isbn
GROUP BY titre
ORDER BY COUNT(*) ASC;

-- ##############################################################################################

/* 16) Définissez une vue qui permet de connaître pour chaque membre, le nombre d’ouvrages empruntés, et donc non encore rendu.*/

CREATE OR REPLACE VIEW nb_ouvrages_empruntes AS 
    SELECT numero_membre, COUNT (*) AS Nb_emprunt 
    FROM Emprunt E JOIN Details USING (numero_emprunt)
    WHERE E.etat = 'EC'
    GROUP BY numero_membre;

-- OUTDATED JOIN ALTERNATIVE

CREATE OR REPLACE VIEW nb_ouvrages_empruntes AS 
    SELECT numero_membre, COUNT (*) AS Nb_emprunt 
    FROM Emprunt E, Details D
    WHERE E.numero_emprunt = D.numero_emprunt and E.etat = 'EC'
    GROUP BY numero_membre;

SELECT * FROM nb_ouvrages_empruntes;

-- ##############################################################################################

/* 17) Définissez une vue qui permet de connaître le nombre d’emprunts par ouvrage.*/

CREATE OR REPLACE VIEW nb_emprunts_par_ouvrage AS 
    SELECT isbn, COUNT (*) AS Nb_emprunt 
    FROM Details
    GROUP BY isbn;

SELECT * FROM nb_emprunts_par_ouvrage;

-- ##############################################################################################

/* 18) Etablissez la liste des membres triés par ordre alphabétique.*/

SELECT nom, prenom, numero_membre FROM Membre ORDER BY nom;

-- ##############################################################################################

/* 19) On souhaite obtenir le nombre de locations par titre et le nombre de locations de chaque exemplaire.Pour obtenir un tel résultat, il est préférable d’utiliser une table temporaire globale et de la remplir au fur et à mesure. Utilisez la clause ON COMMIT PRESERVE ROWS lors de la création de la table temporaire globale.*/

/*SELECT count(*) FROM Exemplaire E, Details D WHERE D.isbn = E.isbn and D.exemplaire = E.numero_exemplaire GROUP BY E.isbn, E.exemplaire;*/

CREATE GLOBAL TEMPORARY TABLE location_exemplaires_titres (
    isbn NUMERIC(10,0),
    exemplaire INTEGER,
    nombre_emprunt_ouvrage INTEGER,
    nombre_emprunt_exemplaire INTEGER)
ON COMMIT PRESERVE ROWS;

INSERT INTO location_exemplaires_titres(isbn, exemplaire, nombre_emprunt_exemplaire) 
    SELECT isbn, numero_exemplaire, count(*) FROM Details
    GROUP BY isbn, numero_exemplaire;
    
UPDATE location_exemplaires_titres SET nombre_emprunt_ouvrage = (
    SELECT count(*) FROM Details
    WHERE Details.isbn = location_exemplaires_titres.isbn);

COMMIT;

SELECT * FROM location_exemplaires_titres;

-- ##############################################################################################

/* 20) Affichez la liste des genres et pour chaque genre, la liste des ouvrages qui lui appartiennent.*/

SELECT libelle, titre
FROM Genre JOIN Ouvrage USING (code_genre)
ORDER BY libelle;

-- OU

SELECT libelle, titre FROM Genre G, Ouvrage O
WHERE G.code_genre = O.code_genre
ORDER BY libelle, titre;

