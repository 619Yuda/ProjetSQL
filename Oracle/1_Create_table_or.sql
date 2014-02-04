DROP TABLE Details_Emprunt PURGE;
DROP TABLE Details PURGE;
DROP TABLE Emprunt PURGE;
DROP TABLE Exemplaire PURGE;
DROP TABLE Ouvrage PURGE;
DROP TABLE Membre PURGE;
--DROP PUBLIC SYNONYM Abonnes;
DROP TABLE Genre PURGE;
DROP SEQUENCE seq_numero_membre;
DROP SEQUENCE seq_numero_emprunt;

-- ***************************************************************************************************

CREATE TABLE Genre(
    code_genre		VARCHAR2(5) NOT NULL,
    libelle		VARCHAR2(30) NOT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_genre PRIMARY KEY (code_genre));

-- ***************************************************************************************************

CREATE TABLE Ouvrage(
    isbn        	NUMERIC(10,0) NOT NULL,
    titre       	VARCHAR2(100) NOT NULL,
    auteur        	VARCHAR2(30) DEFAULT NULL,
    editeur        	VARCHAR2(30) DEFAULT NULL,
    code_genre    	VARCHAR2(5) DEFAULT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_ouvrage PRIMARY KEY (isbn),
    CONSTRAINT fk_ouvrage_genre FOREIGN KEY (code_genre) REFERENCES Genre(code_genre) ON DELETE SET NULL);

-- ***************************************************************************************************

CREATE TABLE Exemplaire(
    isbn        	NUMERIC(10,0) NOT NULL,
    numero_exemplaire	INTEGER NOT NULL,
    etat		VARCHAR2(10) NOT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_exemplaire PRIMARY KEY (isbn, numero_exemplaire),
    CONSTRAINT fk_exemplaire_ouvrage FOREIGN KEY (isbn) REFERENCES Ouvrage(isbn) ON DELETE SET NULL,
    CONSTRAINT cc_exemplaire_etat CHECK( etat IN ('Neuf', 'Bon', 'Moyen', 'Mauvais')));

-- ***************************************************************************************************

CREATE TABLE Membre(
    numero_membre    	INTEGER NOT NULL,
    nom        		VARCHAR2(10) NOT NULL,
    prenom        	VARCHAR2(10) NOT NULL,
    adresse        	VARCHAR2(30) NOT NULL,
    telephone    	VARCHAR2(10) NOT NULL,
    date_adhere    	DATE NOT NULL,
    duree        	INTEGER NOT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_membre PRIMARY KEY(numero_membre),
    CONSTRAINT cc_membre_duree CHECK( duree IN (1, 3, 6, 12)));

-- ***************************************************************************************************

CREATE TABLE Emprunt(
    numero_emprunt	INTEGER NOT NULL,
    numero_membre	INTEGER NOT NULL,
    date_emprunt	DATE NOT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_emprunt PRIMARY KEY (numero_emprunt),
    CONSTRAINT fk_emprunt_membre FOREIGN KEY (numero_membre) REFERENCES Membre(numero_membre) ON DELETE SET NULL);

-- ***************************************************************************************************

CREATE TABLE Details_Emprunt(
    numero_emprunt 	INTEGER NOT NULL,
    numero_detail 	INTEGER NOT NULL,
    isbn 		NUMERIC(10,0) NOT NULL,
    exemplaire 		INTEGER NOT NULL,
    date_de_rendu	DATE DEFAULT NULL,
-- -------------------------------------------------------------------------
    CONSTRAINT pk_details PRIMARY KEY (numero_emprunt, numero_detail),
    CONSTRAINT fk_details_emprunt FOREIGN KEY (numero_emprunt) REFERENCES Emprunt(numero_emprunt) ON DELETE SET NULL,
    CONSTRAINT fk_details_exemplaire FOREIGN KEY (isbn, exemplaire) REFERENCES Exemplaire(isbn, numero_exemplaire) ON DELETE SET NULL);

-- ***************************************************************************************************

