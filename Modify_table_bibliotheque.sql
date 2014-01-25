-- 2 Defini directement dans les tables car dependant des SGBD

-- 3
ALTER TABLE Membre
    ADD CONSTRAINT membre_unique UNIQUE(numero_membre, nom, prenom, telephone);

-- 4
ALTER TABLE Membre
    ADD telephone_portable VARCHAR(10) NOT NULL;
ALTER TABLE Membre
    ADD CONSTRAINT numero_portablechek CHECK (telephone_portable ~ '^[0]{1}[6]{1}[0-9]{8}$'::text);

-- 5
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
 
