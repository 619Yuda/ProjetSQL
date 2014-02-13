-- 1 Ecrire la fonction FinValidite qui calcule la date de fin de validité de l’adhésion d’un membre dont le numéro est passé en paramètre.

CREATE OR REPLACE FUNCTION FinValidite(v_numero_membre IN INTEGER) RETURN DATE IS  	
	date_fin_validite DATE;
BEGIN  
	SELECT add_months(adhesion, duree) INTO date_fin_validite
	FROM Membre	
	WHERE numero_membre = v_numero_membre
	Return date_fin_validite;  
END; 

-- 2 Ecrire la fonction AdhesionAjour qui retourne une valeur booléenne afin de savoir si un membre peut ou non effectuer des locations.

CREATE OR REPLACE FUNCTION AdhesionAjour(v_numero_membre IN INTEGER) RETURN BOOLEAN IS  
	v_location BOOLEAN;
	v_date_fin_validite SYSDATE := FinValidite(v_numero_membre); 
BEGIN  
	v_location := (v_date_fin_validite >= SYSDATE);
	Return v_location;  
END; 

-- 3 Ecrire la procédure RetourExemplaire qui accepte en paramètres un numéro d’ISBN et un numéro d’exemplaire afin d’enregistrer la restitution de l’exemplaire de l’ouvrage emprunté.

CREATE OR REPLACE PROCEDURE RetourExemplaire(v_isbn IN NUMERIC(10,0), v_exemplaire IN INTEGER) AS	
	numero_emprunt INTEGER :=(SELECT numero_emprunt FROM Emprunt E, Details D WHERE D.isbn = v_isbn and D.numero_exemplaire = v_exemplaire and E.numero_emprunt = D.numero_emprunt);
BEGIN
	UPDATE Emprunt E SET etat = 'RE'
	WHERE E.numero_emprunt = numero_emprunt;
	UPDATE Details D SET date_de_rendu = SYSDATE
	WHERE D.isbn = v_isbn and D.numero_exemplaire = v_exemplaire;
END;

-- 4 Ecrire la procédure PurgeMembres qui permet de supprimer tous les membres dont l’adhésion n’a pas été renouvelée depuis trois ans.

CREATE OR REPLACE PROCEDURE PurgeMembres AS
BEGIN
	DELETE FROM Membre 
	WHERE (trunc(SYSDATE(), 'YYYY') - trunc(add_months(adhesion, duree, 'YYYY')) > 3;
END;

-- 5 Ecrire la fonction MesureActivite qui permet de connaître le numéro du membre qui a emprunté le plus d’ouvrage pendant une période de temps passée en paramètre de la fonction. Cette période est exprimée en mois.

CREATE OR REPLACE FUNCTION MesureActivite(v_duree IN INTEGER) RETURN INTEGER IS
	v_numero_membre INTEGER := (SELECT Top 1 count(*) FROM Emprunt WHERE date_emprunt >= (SYSDATE - INTERVAL v_duree month FROM DUAL) GROUP BY (numero_membre) ORDER BY count(*) DESC;
BEGIN
	Return v_numero_membre;
END;

-- 6 Ecrie la fonction EmpruntMoyen qui accepte en paramètre d’entrée le numéro d’un membre et qui retourne la durée moyenne (en nombre de jours) d’emprunt d’un ouvrage.
-- à revoir, ne marchera pas même sous Oracle, utiliser TRUNC quand même

CREATE OR REPLACE FUNCTION EmpruntMoyen(v_numero_membre IN INTEGER) RETURN INTEGER IS
	v_nombre_d_emprunt INTEGER := (SELECT count(*) FROM Emprunt E WHERE E.numero_membre = numero_membre GROUP BY (E.numero_emprunt));
	v_duree_en_jour INTEGER := (SELECT TRUNC((SELECT TOP 1 date_de_rendu FROM Details D, Emprunt E WHERE D.numero_emprunt = E.numero_emprunt ORDER BY date_rendu DESC) - date_emprunt) FROM Emprunt E WHERE E.numero_membre = numero_membre;
	v_duree_moyenne INTEGER := (v_duree_en_jour / v_nombre_emprunt);
BEGIN
	Return v_duree_moyenne;
END;

/* 7 Ecrire la fonction DureeMoyenne qui accepte en paramètre un numéro d’ISBN et
éventuellement un numéro d’exemplaire et qui retourne, soit la durée moyenne d’emprunt de
l’ouvrage (seul le numéro ISBN est connu), soit la durée moyenne d’emprunt de l’exemplaire
dans le cas où l’on connaît le numéro d’ISBN et le numéro de l’exemplaire. */

CREATE OR REPLACE FUNCTION DureeMoyenne(v_isbn IN NUMERIC(10,0), v_exemplaire IN INTEGER) RETURN INTEGER IS
	v_duree;	
BEGIN
	IF(v_exemplaire is NULL)  THEN
		SELECT AVG(trunc(date_de_rendu, 'DD') - trunc(date_emprunt, 'DD')+1) INTO v_duree
		FROM Emprunt E, Details D
		WHERE E.numero_emprunt = D.numero_emprunt and D.isbn = v.isbn and D.exemplaire = v_exemplaire and date_de_rendu IS NOT NULL;
	ELSE
		SELECT AVG(trunc(date_de_rendu, 'DD') - trunc(date_emprunt, 'DD')+1) INTO v_duree
		FROM Emprunt E, Details D
		WHERE E.numero_emprunt = D.numero_emprunt and D.isbn = v.isbn and D.exemplaire = v_exemplaire and date_de_rendu IS NOT NULL;
	ENDIF;
	Return v_duree
END;

/* 8 Ecrire la procédure MajEtatExemplaire pour mettre à jour l’état des exemplaires et
planifier l’exécution de cette procédure toutes les deux semaines.*/

CREATE OR REPLACE FUNCTION MajEtatExemplaire IS
	v_nombre_emprunt := (SELECT count(*) FROM Detail D, Exemplaire E
	WHERE D.isbn = E.isbn and D.exemplaire = E.numero_exemplaire 
	GROUP BY (E.isbn, E.numero_exemplaire);
BEGIN
	UPDATE Exemplaire SET etat = 'Neuf' WHERE v_nombre_emprunts <= 10;
	UPDATE Exemplaire SET etat = 'Bon' WHERE v_nombre_emprunts BETWEEN 11 AND 25;
	UPDATE Exemplaire SET etat = 'Moyen' WHERE v_nombre_emprunts BETWEEN 26 AND 40;
	UPDATE Exemplaire SET etat = 'Douteux' WHERE v_nombre_emprunts BETWEEN 41 AND 60;
	UPDATE Exemplaire SET etat = 'Mauvais' WHERE v_nombre_emprunts >= 61;
	COMMIT;
END;

BEGIN
	DBMS_SCHEDULER.CREATE_JOB('CalculEtatExemplaire', 'MajEtatExemplaire', systimestamp, 'systimestamp+14');
END;

/* 9 Au cours des questions précédentes, la séquence Seq_Membre a été définie et est utilisée
pour l’ajout d’informations dans la table des membres. Pour faciliter le travail avec cette
séquence, il est judicieux de créer la fonction AjouteMembre, qui accepte en paramètre les
différentes valeurs de chacune des colonnes et qui retourne le numéro de séquence attribué à
la ligne d’information nouvellement ajoutée dans la table. */

CREATE OR REPLACE FUNCTION AjouteMembre (v_nom IN VARCHAR2, v_prenom IN VARCHAR2, v_adresse IN VARCHAR2, v_portable IN VARCHAR2, v_adhesion IN DATE v_duree IN NUMBER) RETURN NUMBER AS
	v_numero_membre NUMBER;
BEGIN
	INSERT INTO Membre (numero_membre, nom, prenom, adresse, portable, date_adhere, duree)
	VALUES (seq_numero_membre.NEXTVAL, v_nom, v_prenom, v_adresse, v_portable, v_adhesion, v_duree)
	RETURNING numero_membre INTO v_numero;
	Return v_numero;
END;

/* 10 Ecrire la procédure SupprimeExemplaire qui accepte en paramètre l’identification
complète d’un exemplaire (ISBN et numéro d’exemplaire) et supprime celui-ci s’il n’est pas
emprunté.*/

CREATE OR REPLACE PROCEDURE SupprimeExemplaire (v_isbn IN NUMERIC(10,0), <+> v_exemplaire IN NUMBER) AS
BEGIN
	DELETE FROM Exemplaire
	WHERE isbn = v_isbn and numero à v_numero;
	IF (SQL%ROWCOUNT = 0) THEN
		RAISE NO_DATA_FOUND;
	ENDIF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20010, 'Exemplaire inconnu');
END;

/* 11 Le plus souvent, les membres n’empruntent qu’un seul ouvrage. Ecrire la procédure
EmpruntExpress qui accepte en paramètre le numéro du membre et l’identification exacte de
l’exemplaire emprunté (ISBN et numéro). La procédure ajoute automatiquement une ligne
dans la table des emprunts et une ligne dans la table des détails.*/

CREATE SEQUENCE seq_emprunt START WITH (SELECT MAX(numero_emprunt) FROM Emprunt);

CREATE OR REPLACE PROCEDURE EmpruntExpress(v_numero_membre IN NUMBER, v_isbn IN NUMBER, v_exemplaire IN NUMBER) AS
	v_emprunt emprunt.numero_emprunt%type;
BEGIN
	INSERT INTO Emprunt (numero_emprunt, numero_membre, date_emprunt)
	VALUES(seq_emprunt.NEXTVAL, v_membre, SYSDATE) RETURNING numero_emprunt INTO v_emprunt;
	iNSERT INTO Details (numero_emprunt, numero_detail, isbn, exemplaire)
	VALUES(v_emprunt, 1, v_isbn, v_exemplaire);
END;

/* Regrouper l’ensemble des procédures et des fonctions définies au sein du package Livre.*/
-- Entete

CREATE OR REPLACE PACKAGE Livre AS
	FUNCTION FinValidite (v_numero_membre IN INTEGER) Return DATE;
	FUNCTION AdhesionAJour (v_numero IN INTEGER) Return boolean;
	PROCEDURE RetourExemplaire (v_isbn IN NUMBER, v_numero IN NUMBER);
	PROCEDURE PurgeMembre; 
	FUNCTION MesureActivite (v_duree IN INTEGER) Return INTEGER;
	FUNCTION EmpruntMoyen (v_membre IN INTEGER) Return INTEGER;
	FUNCTION DureeMoyenne (v_isbn IN NUMERIC(10,0), v_exemplaire IN INTEGER DEFAULT NULL) Return INTEGER;
	PROCEDURE MajEtatExemplaire;	
	FUNCTION AjouteMembre (v_nom IN VARCHAR2, v_prenom IN VARCHAR2, v_portable IN VARCHAR2, v_date_adhere in DATE, v_duree IN NUMBER) Return NUMBER;
	PROCEDURE SupprimeExemplaire (v_isbn IN NUMBER, v_numero IN NUMBER);
	PROCEDURE EmpruntExpress (v_membre IN NUMBER, v_isbn IN NUMBER, v_exemplaire IN NUMBER);
END Livre;

--Corps : copier collé de toutes les fonctions et procedure ci dessus
CREATE OR REPLACE PACKAGE BODY Libre AS
-- [...]
END Livre;

