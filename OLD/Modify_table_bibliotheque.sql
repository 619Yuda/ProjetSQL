-- 2 Defini directement dans les tables car dependant des SGBD

-- 3

ALTER TABLE Membre
    ADD CONSTRAINT membre_unique UNIQUE(numero_membre, nom, prenom, telephone);

-- 4

ALTER TABLE Membre
    ADD telephone_portable VARCHAR(10) NOT NULL;
ALTER TABLE Membre
    ADD CONSTRAINT numero_portablechek CHECK (telephone_portable ~ '^[0]{1}[6]{1}[0-9]{8}$'::text);

-- 5 -- Ne marche pas sous postgresql

--ALTER TABLE Membre
--    SET UNUSED (telephone);
--ALTER TABLE Membre
--    DROP CONSTRAINT membre_unique;
--ALTER TABLE Membre
--    DROP UNUSED COLUMNS;
--ALTER TABLE Membre
--    ADD CONSTRAINT constraint_name UNIQUE(numero_membre, nom, prenom, telephone_portable);

-- 6

CREATE INDEX IDX_OUVRAGE_OUVRAGE_GENRE ON Ouvrage (code_genre);
CREATE INDEX IDX_EXEMPLAIRE_ISBN ON Exemplaire (isbn);
CREATE INDEX IDX_EMPRUNT_NBMEMBRE ON Emprunt (numero_membre);
CREATE INDEX IDX_NUMERO_DETAILS_EMPRUNT ON Details_emprunt(numero_details_emprunt);
CREATE INDEX IDX_ISBN_EXEMPLAIRE ON Details_emprunt(isbn, exemplaire);

-- 7
 
ALTER TABLE Details_emprunt
    MODIFY CONSTRAINT fk_numero_details_emprunt FOREIGN KEY (numero_details_emprunt) REFERENCES Emprunt(numero_emprunt) ON DELETE CASCADE;


-- 8

ALTER TABLE Exemplaire ALTER etat SET DEFAULT 'Neuf';

-- 9 -- Ne marche pas sous postgresql

-- CREATE SYNONYM Abonnes FOR bibliotheque.Membre;

-- 10

--RENAME TABLE Details_emprunt TO Details;
--OU
ALTER TABLE Details_emprunt RENAME TO Details; --Marche mieux

---------------------------------------------------------------------------------
-- Partie II 
---------------------------------------------------------------------------------

-- 5

CREATE TABLE Temp_Membre(
	id_affichage NUMBER(2),
	affichage VARCHAR2(50));

CREATE TABLE Temp_Details(
	id_affichage NUMBER(2),
	affichage VARCHAR2(50));
CREATE SEQUENCE compteur START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PACKAGE TriggerMoment AS v_compteur NUMBER:=0;
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

-- 6

ALTER TABLE Emprunt ADD etat VARCHAR(2) CHECK(etat IN('RE', 'EC')) DEFAULT 'EC'; 
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


