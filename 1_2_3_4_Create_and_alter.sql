-- ***************************************************************************************************

CREATE TABLE Genre(
    code_genre        VARCHAR2(5) NOT NULL,
    libelle        VARCHAR2(30) NOT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_genre PRIMARY KEY (code_genre));

COMMIT;

-- ***************************************************************************************************

CREATE TABLE Ouvrage(
    isbn            NUMERIC(10,0) NOT NULL,
    titre           VARCHAR2(100) NOT NULL,
    auteur            VARCHAR2(30) DEFAULT NULL,
    editeur            VARCHAR2(30) DEFAULT NULL,
    code_genre        VARCHAR2(5) DEFAULT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_ouvrage PRIMARY KEY (isbn),
    CONSTRAINT fk_ouvrage_genre FOREIGN KEY (code_genre) REFERENCES Genre(code_genre) ON DELETE SET NULL);

COMMIT;

-- ***************************************************************************************************

CREATE TABLE Exemplaire(
    isbn            NUMERIC(10,0) NOT NULL,
    numero_exemplaire    INTEGER NOT NULL,
    etat        VARCHAR2(10) NOT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_exemplaire PRIMARY KEY (isbn, numero_exemplaire),
    CONSTRAINT fk_exemplaire_ouvrage FOREIGN KEY (isbn) REFERENCES Ouvrage(isbn) ON DELETE SET NULL,
    CONSTRAINT cc_exemplaire_etat CHECK( etat IN ('Neuf', 'Bon', 'Moyen', 'Mauvais')));

COMMIT;

-- ***************************************************************************************************

CREATE TABLE Membre(
    numero_membre        INTEGER NOT NULL,
    nom                VARCHAR2(10) NOT NULL,
    prenom            VARCHAR2(10) NOT NULL,
    adresse            VARCHAR2(30) NOT NULL,
    telephone        VARCHAR2(10) NOT NULL,
    date_adhere        DATE NOT NULL,
    duree            INTEGER NOT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_membre PRIMARY KEY(numero_membre),
    CONSTRAINT cc_membre_duree CHECK( duree IN (1, 3, 6, 12)));

COMMIT;

-- ***************************************************************************************************

CREATE TABLE Emprunt(
    numero_emprunt    INTEGER NOT NULL,
    numero_membre    INTEGER NOT NULL,
    date_emprunt    DATE NOT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_emprunt PRIMARY KEY (numero_emprunt),
    CONSTRAINT fk_emprunt_membre FOREIGN KEY (numero_membre) REFERENCES Membre(numero_membre) ON DELETE SET NULL);

COMMIT;

-- ***************************************************************************************************

CREATE TABLE Details_Emprunt(
    numero_emprunt     INTEGER NOT NULL,
    numero_detail     INTEGER NOT NULL,
    isbn         NUMERIC(10,0) NOT NULL,
    numero_exemplaire         INTEGER NOT NULL,
    date_de_rendu    DATE DEFAULT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_details PRIMARY KEY (numero_emprunt, numero_detail),
    CONSTRAINT fk_details_emprunt FOREIGN KEY (numero_emprunt) REFERENCES Emprunt(numero_emprunt) ON DELETE SET NULL,
    CONSTRAINT fk_details_exemplaire FOREIGN KEY (isbn, numero_exemplaire) REFERENCES Exemplaire(isbn, numero_exemplaire) ON DELETE SET NULL);

COMMIT;

-- ***************************************************************************************************

CREATE SEQUENCE seq_numero_membre START WITH 0 INCREMENT BY 1 MINVALUE 0;
CREATE SEQUENCE seq_numero_emprunt START WITH 0 INCREMENT BY 1 MINVALUE 0;

seq_numero_membre.NEXTVAL
seq_numero_emprunt.NEXTVAL

COMMIT;

-- ***************************************************************************************************

ALTER TABLE Membre
    ADD CONSTRAINT membre_unique UNIQUE(numero_membre, nom, prenom, telephone);

COMMIT;

-- ***************************************************************************************************

ALTER TABLE Membre
    ADD telephone_portable VARCHAR(10) NOT NULL;

ALTER TABLE Membre
    ADD CONSTRAINT cc_telephone_portable CHECK (REGEXP_LIKE (telephone_portable, '^[0]{1}[6]{1}[0-9]{8}$'));

COMMIT;

-- ***************************************************************************************************

ALTER TABLE Membre
    DROP CONSTRAINT membre_unique;
ALTER TABLE Membre
    SET UNUSED (telephone);
ALTER TABLE Membre
    DROP UNUSED COLUMNS;
ALTER TABLE Membre
    ADD CONSTRAINT constraint_name UNIQUE(numero_membre, nom, prenom, telephone_portable);

COMMIT;

-- ***************************************************************************************************

CREATE INDEX IDX_OUVRAGE_OUVRAGE_GENRE ON Ouvrage (code_genre);
CREATE INDEX IDX_EXEMPLAIRE_ISBN ON Exemplaire (isbn);
CREATE INDEX IDX_EMPRUNT_NBMEMBRE ON Emprunt (numero_membre);
CREATE INDEX IDX_NUMERO_DETAILS_EMPRUNT ON Details_emprunt(numero_detail);
CREATE INDEX IDX_ISBN_EXEMPLAIRE ON Details_emprunt(isbn, numero_exemplaire);

COMMIT;

-- ***************************************************************************************************

ALTER TABLE Details_Emprunt
    DROP CONSTRAINT fk_details_emprunt;

ALTER TABLE Details_Emprunt
    ADD CONSTRAINT fk_details_emprunt FOREIGN KEY (numero_emprunt) REFERENCES Emprunt(numero_emprunt) ON DELETE CASCADE;

COMMIT;

-- ***************************************************************************************************

ALTER TABLE Exemplaire MODIFY (etat DEFAULT 'Neuf');
COMMIT;

-- ***************************************************************************************************

CREATE SYNONYM Abonnes FOR Membre;
COMMIT;

-- ***************************************************************************************************

ALTER TABLE Details_Emprunt RENAME TO Details;
COMMIT;


INSERT INTO Genre (code_genre,libelle) VALUES ('REC','Récit');
INSERT INTO Genre (code_genre,libelle) VALUES ('POL','Policier');
INSERT INTO Genre (code_genre,libelle) VALUES ('BD','Bande Dessinée');
INSERT INTO Genre (code_genre,libelle) VALUES ('INF','Informatique');
INSERT INTO Genre (code_genre,libelle) VALUES ('THE','Théatre');
INSERT INTO Genre (code_genre,libelle) VALUES ('ROM','Roman');

-- ***************************************************************************************************

INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2203314168','LEFRANC-L ultimatum','Martin Carin ','BD','Casterman');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2746021285','HTML entraînez-vous pour maîtriser le code source','Luc Van Lancker ','INF','ENI');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2746026090','Oracle 10g SQL PL/SQL SQL*Plus','J. Gabillaud ','INF','ENI');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2266085816','Pantagruel','F. Robert ','ROM','Pocket');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2266091611','Voyage au centre de la terre','Jules VERNE ','ROM','Pocket');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2253010219','Le crime de l’Orient Express','Agatha Christie ','POL','Livre de Poche');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2070400816','Le Bourgois gentilhomme','Molière ','THE','Gallimard');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2070367177','Le curé de Tours','Honoré de Balzac ','ROM','Gallimard');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2080720872','Boule de suif','G. de Maupassant ','REC','Flammarion');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2877065073','La gloire de mon père','Marcel Pagnol ','ROM','Fallois');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2020549522','L’aventure des manuscrits de la mer morte',NULL,'REC','Seuil');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2253006327','Vingt mille lieues sous les mers','Jules Verne ','ROM','LGF');
INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES ('2038704015','De la terre à la lune','Jules Verne ','ROM','Larousse');

-- ***************************************************************************************************

INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2020549522',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2020549522',2,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2038704015',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2038704015',2,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2070367177',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2070367177',2,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2070400816',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2070400816',2,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2080720872',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2080720872',2,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2203314168',1,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2203314168',2,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2203314168',3,'Neuf');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2253006327',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2253006327',2,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2253010219',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2253010219',2,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2266085816',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2266085816',2,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2266091611',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2266091611',2,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2746021285',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2746021285',2,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2746026090',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2746026090',2,'Moyen');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2877065073',1,'Bon');
INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES ('2877065073',2,'Moyen');

-- ***************************************************************************************************

INSERT INTO Membre (numero_membre,nom,prenom,adresse,telephone_portable,date_adhere,duree) VALUES (seq_numero_membre.NEXTVAL,'Albert','Anne','13 rue des alpes','0601020304',Sysdate-60,1);
INSERT INTO Membre (numero_membre,nom,prenom,adresse,telephone_portable,date_adhere,duree) VALUES (seq_numero_membre.NEXTVAL,'Bernaud','Barnabé','6 rue des bécasses','0602030105',Sysdate-10,3);
INSERT INTO Membre (numero_membre,nom,prenom,adresse,telephone_portable,date_adhere,duree) VALUES (seq_numero_membre.NEXTVAL,'Cuvard','Camille','53 rue des cerisiers','0602010509',Sysdate-100,6);
INSERT INTO Membre (numero_membre,nom,prenom,adresse,telephone_portable,date_adhere,duree) VALUES (seq_numero_membre.NEXTVAL,'Dupond','Daniel','11 rue des daims','0610236515',Sysdate-250,12);
INSERT INTO Membre (numero_membre,nom,prenom,adresse,telephone_portable,date_adhere,duree) VALUES (seq_numero_membre.NEXTVAL,'Evroux','Eglantine','34 rue des elfes','0658963125',Sysdate-150,6);
INSERT INTO Membre (numero_membre,nom,prenom,adresse,telephone_portable,date_adhere,duree) VALUES (seq_numero_membre.NEXTVAL,'Fregeon','Fernand','11 rue des Francs','0602036987',Sysdate-400,6);
INSERT INTO Membre (numero_membre,nom,prenom,adresse,telephone_portable,date_adhere,duree) VALUES (seq_numero_membre.NEXTVAL,'Gorit','Gaston','96 rue de la glacerie','0684235781',Sysdate-150,1);
INSERT INTO Membre (numero_membre,nom,prenom,adresse,telephone_portable,date_adhere,duree) VALUES (seq_numero_membre.NEXTVAL,'Hevard','Hector','12 rue haute','0608546578',Sysdate-250,12);
INSERT INTO Membre (numero_membre,nom,prenom,adresse,telephone_portable,date_adhere,duree) VALUES (seq_numero_membre.NEXTVAL,'Ingrand','Irène','54 rue de iris','0605020409',Sysdate-50,12);
INSERT INTO Membre (numero_membre,nom,prenom,adresse,telephone_portable,date_adhere,duree) VALUES (seq_numero_membre.NEXTVAL,'Juste','Julien','5 place des Jacobins','0603069876',Sysdate-100,6);

-- ***************************************************************************************************

INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,1,Sysdate-200);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,3,Sysdate-190);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,4,Sysdate-180);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,1,Sysdate-170);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,5,Sysdate-160);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,2,Sysdate-150);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,4,Sysdate-140);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,1,Sysdate-130);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,9,Sysdate-120);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,6,Sysdate-110);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,1,Sysdate-100);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,6,Sysdate-90);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,2,Sysdate-80);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,4,Sysdate-70);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,1,Sysdate-60);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,3,Sysdate-50);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,1,Sysdate-40);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,5,Sysdate-30);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,4,Sysdate-20);
INSERT INTO Emprunt (numero_emprunt,numero_membre,date_emprunt) VALUES (seq_numero_emprunt.NEXTVAL,1,Sysdate-10);

-- ***************************************************************************************************

INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (1,1,'2038704015',1,Sysdate-195);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (1,2,'2070367177',2,Sysdate-190);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (2,1,'2080720872',1,Sysdate-180);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (2,2,'2203314168',1,Sysdate-179);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (3,1,'2038704015',1,Sysdate-170);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (4,1,'2203314168',2,Sysdate-155);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (4,2,'2080720872',1,Sysdate-155);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (4,3,'2266085816',1,Sysdate-159);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (5,1,'2038704015',2,Sysdate-140);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (6,1,'2266085816',2,Sysdate-141);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (6,2,'2080720872',2,Sysdate-130);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (6,3,'2746021285',2,Sysdate-133);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (7,1,'2070367177',2,Sysdate-100);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (8,1,'2080720872',1,Sysdate-116);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (9,1,'2038704015',1,Sysdate-100);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (10,1,'2080720872',2,Sysdate-107);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (10,2,'2746026090',1,Sysdate-78);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (11,1,'2746021285',1,Sysdate-81);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (12,1,'2203314168',1,Sysdate-86);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (12,2,'2038704015',1,Sysdate-60);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (13,1,'2070367177',1,Sysdate-65);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (14,1,'2266091611',1,Sysdate-66);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (15,1,'2266085816',1,Sysdate-50);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (16,1,'2253010219',2,Sysdate-41);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (16,2,'2070367177',2,Sysdate-41);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (17,1,'2877065073',2,Sysdate-36);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (18,1,'2070367177',1,Sysdate-14);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (19,1,'2746026090',1,Sysdate-12);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (20,1,'2266091611',1,NULL);
INSERT INTO Details (numero_emprunt,numero_detail,isbn,numero_exemplaire,date_de_rendu) VALUES (20,2,'2253010219',1,NULL);

-- ***************************************************************************************************

COMMIT;

ALTER TABLE Membre ENABLE ROW MOVEMENT;
ALTER TABLE Details ENABLE ROW MOVEMENT;

COMMIT;

-- ***************************************************************************************************

ALTER TABLE Emprunt ADD etat VARCHAR(2) DEFAULT 'EC';
ALTER TABLE Emprunt ADD CONSTRAINT cc_emprunt_etat CHECK(etat IN('RE', 'EC'));

UPDATE emprunt SET etat = 'RE' WHERE numero_emprunt NOT IN (SELECT DISTINCT numero_emprunt FROM details WHERE date_de_rendu IS NULL);

COMMIT;

-- ***************************************************************************************************

UPDATE exemplaire SET etat = 'Neuf';
COMMIT;

UPDATE exemplaire
SET etat = 'Bon'
WHERE (isbn, numero_exemplaire) IN (
    SELECT  isbn, numero_exemplaire FROM details GROUP BY isbn, numero_exemplaire HAVING COUNT(*) BETWEEN 2 AND 3);

COMMIT;

UPDATE exemplaire
SET etat = 'Moyen'
WHERE (isbn, numero_exemplaire) IN (
    SELECT  isbn, numero_exemplaire FROM details GROUP BY isbn, numero_exemplaire HAVING COUNT(*) BETWEEN 4 AND 5);

COMMIT;

UPDATE exemplaire
SET etat = 'Mauvais'
WHERE (isbn, numero_exemplaire) IN (
    SELECT  isbn, numero_exemplaire FROM details GROUP BY isbn, numero_exemplaire HAVING COUNT(*) >= 6);

COMMIT;

SELECT * FROM exemplaire;

-- ***************************************************************************************************

DELETE FROM exemplaire WHERE etat LIKE 'Mauvais';

COMMIT;

-- ***************************************************************************************************

CREATE OR REPLACE VIEW nb_ouvrages_empruntes AS
    SELECT numero_membre, COUNT (*) AS Nb_emprunt
    FROM Emprunt E JOIN Details USING (numero_emprunt)
    WHERE E.etat = 'EC'
    GROUP BY numero_membre;
COMMIT;

-- ***************************************************************************************************

CREATE OR REPLACE VIEW nb_emprunts_par_ouvrage AS
    SELECT isbn, COUNT (*) AS Nb_emprunt
    FROM Details
    GROUP BY isbn;
COMMIT;


-- ***************************************************************************************************
