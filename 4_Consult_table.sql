/* 4) Extraction simple d’informations
Consultez le contenu de chaque table à l’aide d’une requête d’extraction simple qui permet de visualiser toutes les lignes et toutes les colonnes de chaque table.*/

SELECT * FROM Genre;
SELECT * FROM Ouvrage;
SELECT * FROM Exemplaire;
SELECT * FROM Membre;
SELECT * FROM Emprunt;
SELECT * FROM Details;

/* 5) Activation de l’historique des mouvements
Les manipulations de la table des membres sont sensibles. Activez l’historique des mouvements sur cette table. Effectuez la même opération sur la table « DETAILS » */
/*
CREATE TABLE Temp_Membre(
    id_affichage NUMBER(2),
    affichage VARCHAR2(50));

CREATE TABLE Temp_Details(
    id_affichage NUMBER(2),
    affichage VARCHAR2(50));

CREATE SEQUENCE compteur START WITH 1 INCREMENT BY 1;
*/

CREATE TABLE Temp_Membre(
    id_affichage NUMERIC(2),
    affichage VARCHAR(50));

CREATE TABLE Temp_Details(
    id_affichage NUMERIC(2),
    affichage VARCHAR(50));

CREATE SEQUENCE compteur START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PACKAGE TriggerMoment
    AS v_compteur NUMBER:=0;
END TriggerMoment

CREATE OR REPLACE TRIGGER BeforeInstructionOnMember
    BEFORE UPDATE ON MEMBRE
    BEGIN
        INSERT INTO Temp_AFFICHAGE VALUES(

        compteur.NEXTVAL,
        ‘BEFORE niveau instruction : compteur =’ || TriggerMoment.v_compteur );
        TriggerMoment.v_compteur := TriggerMoment.v_compteur + 1;
    END BeforeInstructionOnMember;

CREATE OR REPLACE TRIGGER AfterInstructionOnMember
    AFTER UPDATE ON MEMBRE
    BEGIN
        INSERT INTO Temp_AFFICHAGE VALUES(

        compteur.NEXTVAL,
        ‘AFTER niveau instruction : compteur =’ || TriggerMoment.v_compteur );
        TriggerMoment.v_compteur := TriggerMoment.v_compteur + 1;
    END BeforeInstructionOnMember;

CREATE OR REPLACE TRIGGER BeforeInstructionOnDetails
    BEFORE UPDATE ON DETAILS
    BEGIN
        INSERT INTO Temp_AFFICHAGE VALUES(

        compteur.NEXTVAL,
        ‘BEFORE niveau instruction : compteur =’ || TriggerMoment.v_compteur );
        TriggerMoment.v_compteur := TriggerMoment.v_compteur + 1;
    END AfterInstructionOnDetails;

CREATE OR REPLACE TRIGGER AfterInstructionOnDetails
    AFTER UPDATE ON DETAILS
    BEGIN
        INSERT INTO Temp_AFFICHAGE VALUES(

        compteur.NEXTVAL,
        ‘AFTER niveau instruction : compteur =’ || TriggerMoment.v_compteur );
        TriggerMoment.v_compteur := TriggerMoment.v_compteur + 1;
    END AfterInstructionOnDetails;

/* 6) Ajout d’une colonne :
Pour faciliter la gestion des emprunts et identifier plus rapidement les fiches pour lesquelles l’ensemble des exemplaires n’est pas restitué, il a été décidé d’ajouter une colonne «ETAT »qui peut prendre les valeurs (EC : en cours) par défaut et (RE : rendue) lorsque l’ensemble des exemplaires est rendu. Ecrivez l’instruction SQL qui permet d’effectuer la modification de structure souhaitée. Mettez à jour l’état de chaque fiche de location en le faisant passer à RE (rendue) si tous les ouvrages empruntés par le membre ont été restitués à la bibliothèque. */

-- Ajout d'une colone nb_emprunt dans la table Exemplaire afin de comptabiliser le nombre d'emprunt de chaque livre

ALTER TABLE Emprunt ADD etat VARCHAR(2) DEFAULT 'EC';
ALTER TABLE Emprunt ADD CONSTRAINT cc_emprunt_etat CHECK(etat IN('RE', 'EC'));

-- Definition de l'état initial.
UPDATE emprunt SET etat = 'EC' WHERE numero_emprunt = (SELECT DISTINCT numero_emprunt FROM emprunt NATURAL JOIN details WHERE date_de_rendu IS NULL);


/*DECLARE
    CURSOR curseur IS SELECT etat FROM Emprunt
    anom emp.ename%TYPE;
    salaire emp.sal%TYPE;
    BEGIN
        OPEN dept_10;
        LOOP
            FETCH dept_10 INTO nom, salaire;
            EXIT WHEN dept_10%NOTFOUND or dept_10%ROWCOUNT >15;
            IF salaire >2500 THEN
                INSERT INTO résultat VALUES (nom,salaire);
            END IF;
        END LOOP;
    CLOSE dept_10;
END;*/

/*
CURSOR curseur IS
    SELECT etat,
    FROM Emprunt
    FOR UPDATE OF etat
    v_emprunt c_emprunt%ROWTYPE;
    v_details c_details%ROWTYPE;
    BEGIN
        OPEN c_emprunt;
        OPEN c_details;
        FETCH c_emprunt INTO v_emprunt;
        UPDATE Emprunt SET etat = 'EC'
        WHERE c_details.numero_emprunt = c_emprunt.numero_emprunt AND (c_details.date_de_rendu IS NULL);
        UPDATE Emprunt SET etat = 'RE'
        WHERE c_details.numero_emprunt = c_emprunt.numero_emprunt AND (c_details.date_de_rendu IS NOT NULL);
        COMMIT
        CLOSE_ v_emprunt;
    END;
*/


/* 7) Mise à jour conditionnelle
On souhaite modifier l’état des exemplaires en fonction de leur nombre de locations afin de faire passer les exemplaires actuellement à l’état Neuf vers l’état Bon et supprimer les exemplaires qui ont été loués plus de 60 fois. En effet, les bibliothécaires considèrent qu’un tel exemplaire doit être retiré de la location car il ne répond pas à la qualité souhaitée par les membres. Les livres sont considérés neufs lorsqu’ils ont été empruntés moins de 11 fois. A partir du 11ème emprunt et jusqu’au 25ème leur état est bon. */

-- Ajout d'une colone nb_emprunt dans la table Exemplaire afin de comptabiliser le nombre d'emprunt de chaque livre

ALTER TABLE Exemplaire ADD COLUMN nb_emprunt INTEGER DEFAULT 0;


-- Definition de l'état initial du nombre d'emprunt en se basant sur l'état des livres
-- Neuf = 0 fois / Bon = 11 fois / Moyen = 25 fois / Mauvais = 60 fois

UPDATE Exemplaire SET nb_emprunt = 11 WHERE etat ~* 'bon';
UPDATE Exemplaire SET nb_emprunt = 25 WHERE etat ~* 'moyen';
UPDATE Exemplaire SET nb_emprunt = 60 WHERE etat ~* 'mauvais';


/*LA EST A FAIRE DIRECTEMENT EN ORACLE

DECLARE
CURSOR c_exemplaire IS
    SELECT nb_emprunt, etat
    FROM Exemplaire
    FOR UPDATE OF nb_emprunt ;

v_exemplaire  c_exemplaire%ROWTYPE;

BEGIN
    OPEN c_exemplaire;
    FETCH c_exemplaire INTO v_exemplaire;
        CASE
        UPDATE EMPLOYES SET SALAIRE = V_employe.SALAIRE + V_employe.salaire * 0.1
        WHERE NOM = V_employe.NOM ;
    COMMIT;
    CLOSE c_employe ;
END;
*/

/* 8) Supprimez tous les exemplaires dont l’état est mauvais.*/

DELETE FROM exemplaire WHERE etat ~* 'Mauvais';


/* 9) Etablissez la liste des ouvrages que possède la bibliothèque.*/

SELECT titre FROM exemplaire;


/* 10) Etablissez la liste des membres qui ont emprunté un ouvrage depuis plus de deux semaines en indiquant le nom de l’ouvrage.*/


/* 11) Etablissez le nombre d’ouvrages dont on dispose par catégorie.*/


/* 12) Etablissez la durée moyenne d’emprunt d’un livre par un membre.*/


/* 13) Calculez la durée moyenne de l’emprunt en fonction du genre du livre.*/


/* 14) Etablissez la liste des ouvrages loués plus de 10 fois au cours des 12 derniers mois.*/


/* 15) Etablissez la liste de tous les ouvrages avec à côté de chacun d’eux les numéros d’exemplaires qui existent dans la base.*/


/* 16) Définissez une vue qui permet de connaître pour chaque membre, le nombre d’ouvrages empruntés, et donc non encore rendu.*/


/* 17) Définissez une vue qui permet de connaître le nombre d’emprunts par ouvrage.*/


/* 18) Etablissez la liste des membres triés par ordre alphabétique.*/


/* 19) On souhaite obtenir le nombre de locations par titre et le nombre de locations de chaque exemplaire. Pour obtenir un tel résultat, il est préférable d’utiliser une table temporaire globale et de la remplir au fur et à mesure. Utilisez la clause ON COMMIT PRESERVE ROWS lors de la création de la table temporaire globale.*/


/* 20) Affichez la liste des genres et pour chaque genre, la liste des ouvrages qui lui appartiennent.*/






