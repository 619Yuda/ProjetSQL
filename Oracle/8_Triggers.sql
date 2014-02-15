/* 1 Mettre à jour un déclencheur de base de données afin de vous assurer que lors de la
suppression du dernier exemplaire d’un ouvrage, les informations relatives à l’ouvrage sont
également supprimées. */

CREATE OR REPLACE TRIGGER suppression_si_aucun_exemplaire
	AFTER DELETE ON Exemplaire
	FOR EACH ROW
DECLARE
	v_nombre_exemplaire INTEGER;
BEGIN
	SELECT count(*) INTO v_nombre_exemplaire FROM Exemplaire WHERE isbn = :old.isbn;
	IF (v_nombre_exemplaire = 1) THEN
		DELETE FROM Ouvrages WHERE isbn = :old.isbn;
	ENDIF;
END;

/* 2 Définir un déclencheur de base de données permettant de garantir que les emprunts sont
réalisés uniquement par des membres à jour de leur cotisation.*/

CREATE OR REPLACE TRIGGER emprunt_autorisé
	BEFORE INSERT ON Emprunt
	FOR EACH ROW
DECLARE
	emprunt_bool BOOLEAN;
BEGIN
	emprunt_bool := AdhesionAJour(:old.numero_membre)
	IF(!emprunt_bool)
		RAISE_APPLICATION_ERROR(-20200,'Adhesion non valide');
	ENDIF;
END;

/* 3 Définir un déclencheur qui interdit le changement de membre pour une fiche de location
déjà enregistrée.*/

CREATE OR REPLACE TRIGGER changements_membre_sur_emprunt_interdits
	BEFORE UPDATE OF numero_membre ON Emprunt
	FOR EACH ROW
BEGIN
	IF(:new.numero_membre != :old.numero_membre)
		RAISE_APPLICATION_ERROR(-20200,'Opération interdite');
	ENDIF;
END;

/* 4 Définir un déclencheur qui interdit de modifier la référence d’un ouvrage emprunté, il faut
le rendre puis effectuer une nouvelle location */ 
-- C'est quoi la référence ?!

CREATE OR REPLACE TRIGGER changements_details_emprunt_interdits
	BEFORE UPDATE OF isbn ON Details
	FOR EACH ROW
BEGIN
	IF(:new.isbn != :old.isbn)
		RAISE_APPLICATION_ERROR(-20200,'Opération interdite');
	ENDIF;
END;

/* 5 Définir un déclencheur qui met automatiquement à jour l’état d’un exemplaire en fonction
de la valeur enregistrée dans NombreEmprunts. Par exemple, lors de la mise à jour de
valeurs représentant le nombre d’emprunts pour un exemplaire, l’état est mis à jour de façon
automatique. */

CREATE OR REPLACE TRIGGER maj_etat_exemplaire_automatique
	AFTER INSERT OR UPDATE OF nombreEmprunts ON Exemplaire
	FOR EACH ROW
BEGIN
	IF(:new.nombreEmprunts <= 10) THEN
		:new.etat := 'NE';
	ENDIF;
	IF(:new.nombreEmprunts BETWEEN 11 AND 25) THEN
		:new.etat := 'BO';
	ENDIF;
	IF(:new.nombreEmprunts BETWEEN 26 AND 40) THEN
		:new.etat := 'MO';
	ENDIF;
	IF(:new.nombreEmprunts BETWEEN 41 AND 60) THEN
		:new.etat := 'DO';
	ENDIF;
	IF(:new.nombreEmprunts >= 61) THEN
		:new.etat := 'MA';
	ENDIF;
END;

/* 6 Lors de la suppression d’un détail, assurer que l’emprunt a bien été pris en compte au
niveau de l’exemplaire. */

CREATE OR REPLACE TRIGGER maj_nombre_emprunt_exemplaire
	BEFORE DELETE ON Details
	FOR EACH ROW
DECLARE
	v_isbn := old.isbn;
	v_exemplaire := old.exemplaire;
BEGIN
	UPDATE Exemplaire SET nombreEmprunt = ((SELECT nombreEmprunt FROM Exemplaire WHERE Exemplaire.isbn = v_isbn and Exemplaire.numero_exemplaire = v_exemplaire)+1) 
	WHERE Exemplaire.isbn = v_isbn and Exemplaire.numero_exemplaire = v_exemplaire;
END;

/* 7 Afin d’améliorer le service rendu aux membres, il est souhaitable de savoir quand
l’emprunt d’un ouvrage a été enregistré et quel employé a effectué l’opération. Le même
genre d’informations doit être disponible pour le retour des exemplaires.
Définir le code nécessaire pour prendre en compte cette nouvelle exigence. Apporter des
modifications de structures si nécessaire. */

DROP TABLE Employe PURGE;
DROP SEQUENCE seq_numero_employe;

CREATE SEQUENCE seq_numero_employe START WITH 1 INCREMENT BY 1;

CREATE TABLE Employe (
	nom VARCHAR2(10) NOT NULL;
	prenom VARCHAR2(10) NOT NULL;
	numero_employe INTEGER NOT NULL;
-----------------------------------------------
	CONSTRAINT pk_employé PRIMARY KEY (numero_employe);
);

ALTER TABLE Emprunt ADD numero_employe INTEGER NOT NULL;
ALTER TABLE Details_Emprunt
    ADD CONSTRAINT fk_numero_employe FOREIGN KEY (numero_employe) REFERENCES Employe(numero_employe);

ALTER TABLE Details ADD numero_employe INTEGER NOT NULL;
ALTER TABLE Details_Emprunt
    ADD CONSTRAINT fk_numero_employe FOREIGN KEY (numero_employe) REFERENCES Employe(numero_employe);
    
/* 8   Ecrire la fonction AnalyseActivite qui accepte en paramètres le nom d’un utilisateur
Oracle et une date et calcule le nombre d’opérations (emprunts et détails) réalisées par
l’utilisateur, ou bien sur la journée, ou bien pour l’utilisateur sur la journée. La valeur de cette
fonction est toujours un nombre entier.*/


/* 9 Si tous les exemplaires référencés sur une fiche ont été rendus, alors interdire tout nouvel
ajout de détails.*/

