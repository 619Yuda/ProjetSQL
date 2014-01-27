DROP TABLE IF EXISTS  Details;
DROP TABLE IF EXISTS  Emprunt;
DROP TABLE IF EXISTS  Exemplaire;
DROP TABLE IF EXISTS  Ouvrage;
DROP TABLE IF EXISTS  Membre;
DROP TABLE IF EXISTS  Genre;
DROP SEQUENCE IF EXISTS seq_numero_membre;
DROP SEQUENCE IF EXISTS seq_numero_emprunt;


CREATE SEQUENCE seq_numero_membre START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_numero_membre START WITH 1 INCREMENT BY 1;

-- ***************************************************************************************************

CREATE TABLE Genre(
    code_genre		VARCHAR(5) NOT NULL,
    libelle		VARCHAR(30) NOT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_genre PRIMARY KEY (code_genre));

-- ***************************************************************************************************

CREATE TABLE Ouvrage(
    isbn        	NUMERIC(10,0) NOT NULL,
    titre       	VARCHAR(100) NOT NULL,
    auteur        	VARCHAR(30) DEFAULT NULL,
    editeur        	VARCHAR(30) DEFAULT NULL,
    code_genre    	VARCHAR(5) DEFAULT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_ouvrage PRIMARY KEY (isbn),
    CONSTRAINT fk_ouvrage_genre FOREIGN KEY (code_genre) REFERENCES Genre(code_genre) ON DELETE CASCADE);

-- ***************************************************************************************************

CREATE TABLE Exemplaire(
    isbn        	NUMERIC(10,0) NOT NULL,
    numero_exemplaire	INTEGER NOT NULL,
    etat		VARCHAR(10) CHECK( etat IN ('Neuf', 'Bon', 'Moyen', 'Mauvais')),
-- -------------------------------------------------------------------------
    CONSTRAINT pk_exemplaire PRIMARY KEY (isbn, numero_exemplaire),
    CONSTRAINT fk_exemplaire_ouvrage FOREIGN KEY (isbn) REFERENCES Ouvrage(isbn) ON DELETE CASCADE);

-- ***************************************************************************************************
 
CREATE TABLE Membre(
    numero_membre    	INTEGER NOT NULL DEFAULT nextval('seq_numero_membre'), --  en oracle seq_numero_membre.nextval
    nom        		VARCHAR(10) NOT NULL,
    prenom        	VARCHAR(10) NOT NULL,
    adresse        	VARCHAR(30) NOT NULL,
    telephone    	VARCHAR(10) NOT NULL,
    date_adhere    	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    duree        	INTEGER  CHECK( duree IN (1, 3, 6, 12)) NOT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_membre PRIMARY KEY(numero_membre));

-- ***************************************************************************************************

CREATE SEQUENCE seq_numero_emprunt START WITH 1 INCREMENT BY 1;

CREATE TABLE Emprunt(
    numero_emprunt	INTEGER DEFAULT nextval('seq_numero_emprunt'), --  en oracle seq_numero_membre.nextval
    numero_membre	INTEGER NOT NULL,
    date_emprunt	TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_emprunt PRIMARY KEY (numero_emprunt),
    CONSTRAINT fk_emprunt_membre FOREIGN KEY (numero_membre) REFERENCES Membre(numero_membre) ON DELETE CASCADE);

-- ***************************************************************************************************

CREATE TABLE Details(
    numero_emprunt 	INTEGER NOT NULL,
    numero_detail 	INTEGER NOT NULL,
    isbn 		NUMERIC(10,0) NOT NULL,
    exemplaire 		INTEGER NOT NULL,
    date_de_rendu	DATE DEFAULT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_details PRIMARY KEY (numero_emprunt, numero_detail),
    CONSTRAINT fk_details_emprunt FOREIGN KEY (numero_emprunt) REFERENCES Emprunt(numero_emprunt) ON DELETE CASCADE,
    CONSTRAINT fk_detail_exemplaire FOREIGN KEY (isbn, exemplaire) REFERENCES Exemplaire(isbn, numero_exemplaire) ON DELETE CASCADE);

-- ***************************************************************************************************
 
 
 
 
 
 
 
 
 
 
 
 
 





