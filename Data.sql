-- File created by CsvToSql.sh samedi 25 janvier 2014, 15:21:15 (UTC+0100)
-- Conversion from Oracle to psql


INSERT INTO Genre (code_genre,libelle) VALUES
('REC','Récit'),
('POL','Policier'),
('BD','Bande Dessinée'),
('INF','Informatique'),
('THE','Théatre'),
('ROM','Roman');

INSERT INTO Ouvrage (isbn,titre,auteur,code_genre,editeur) VALUES
('2203314168','LEFRANC-L ultimatum','Martin Carin ','BD','Casterman'),
('2746021285','HTML entraînez-vous pour maîtriser le code source','Luc Van Lancker ','INF','ENI'),
('2746026090','Oracle 10g SQL PL/SQL SQL*Plus','J. Gabillaud ','INF','ENI'),
('2266085816','Pantagruel','F. Robert ','ROM','Pocket'),
('2266091611','Voyage au centre de la terre','Jules VERNE ','ROM','Pocket'),
('2253010219','Le crime de l’Orient Express','Agatha Christie ','POL','Livre de Poche'),
('2070400816','Le Bourgois gentilhomme','Molière ','THE','Gallimard'),
('2070367177','Le curé de Tours','Honoré de Balzac ','ROM','Gallimard'),
('2080720872','Boule de suif','G. de Maupassant ','REC','Flammarion'),
('2877065073','La gloire de mon père','Marcel Pagnol ','ROM','Fallois'),
('2020549522','L’aventure des manuscrits de la mer morte',NULL,'REC','Seuil'),
('2253006327','Vingt mille lieues sous les mers','Jules Verne ','ROM','LGF'),
('2038704015','De la terre à la lune','Jules Verne ','ROM','Larousse');

INSERT INTO Exemplaire (isbn,numero_exemplaire,etat) VALUES
('2020549522',1,'Bon'),
('2020549522',2,'Moyen'),
('2038704015',1,'Bon'),
('2038704015',2,'Moyen'),
('2070367177',1,'Bon'),
('2070367177',2,'Moyen'),
('2070400816',1,'Bon'),
('2070400816',2,'Moyen'),
('2080720872',1,'Bon'),
('2080720872',2,'Moyen'),
('2203314168',1,'Moyen'),
('2203314168',2,'Bon'),
('2203314168',3,'Neuf'),
('2253006327',1,'Bon'),
('2253006327',2,'Moyen'),
('2253010219',1,'Bon'),
('2253010219',2,'Moyen'),
('2266085816',1,'Bon'),
('2266085816',2,'Moyen'),
('2266091611',1,'Bon'),
('2266091611',2,'Moyen'),
('2746021285',1,'Bon'),
('2746026090',1,'Bon'),
('2746026090',2,'Moyen'),
('2877065073',1,'Bon'),
('2877065073',2,'Moyen');

INSERT INTO Membre (nom,prenom,adresse,telephone,date_adhere,duree) VALUES
('Albert','Anne','13 rue des alpes','0601020304',CURRENT_TIMESTAMP - INTERVAL '60 days',1),
('Bernaud','Barnabé','6 rue des bécasses','0602030105',CURRENT_TIMESTAMP - INTERVAL '10 days',3),
('Cuvard','Camille','53 rue des cerisiers','0602010509',CURRENT_TIMESTAMP - INTERVAL '100 days',6),
('Dupond','Daniel','11 rue des daims','0610236515',CURRENT_TIMESTAMP - INTERVAL '250 days',12),
('Evroux','Eglantine','34 rue des elfes','0658963125',CURRENT_TIMESTAMP - INTERVAL '150 days',6),
('Fregeon','Fernand','11 rue des Francs','0602036987',CURRENT_TIMESTAMP - INTERVAL '400 days',6),
('Gorit','Gaston','96 rue de la glacerie','0684235781',CURRENT_TIMESTAMP - INTERVAL '150 days',1),
('Hevard','Hector','12 rue haute','0608546578',CURRENT_TIMESTAMP - INTERVAL '250 days',12),
('Ingrand','Irène','54 rue de iris','0605020409',CURRENT_TIMESTAMP - INTERVAL '50 days',12),
('Juste','Julien','5 place des Jacobins','0603069876',CURRENT_TIMESTAMP - INTERVAL '100 days',6);

INSERT INTO Emprunt (numero_membre,date_emprunt) VALUES
(1,CURRENT_TIMESTAMP - INTERVAL '200 days'),
(3,CURRENT_TIMESTAMP - INTERVAL '190 days'),
(4,CURRENT_TIMESTAMP - INTERVAL '180 days'),
(1,CURRENT_TIMESTAMP - INTERVAL '170 days'),
(5,CURRENT_TIMESTAMP - INTERVAL '160 days'),
(2,CURRENT_TIMESTAMP - INTERVAL '150 days'),
(4,CURRENT_TIMESTAMP - INTERVAL '140 days'),
(1,CURRENT_TIMESTAMP - INTERVAL '130 days'),
(9,CURRENT_TIMESTAMP - INTERVAL '120 days'),
(6,CURRENT_TIMESTAMP - INTERVAL '110 days'),
(1,CURRENT_TIMESTAMP - INTERVAL '100 days'),
(6,CURRENT_TIMESTAMP - INTERVAL '90 days'),
(2,CURRENT_TIMESTAMP - INTERVAL '80 days'),
(4,CURRENT_TIMESTAMP - INTERVAL '70 days'),
(1,CURRENT_TIMESTAMP - INTERVAL '60 days'),
(3,CURRENT_TIMESTAMP - INTERVAL '50 days'),
(1,CURRENT_TIMESTAMP - INTERVAL '40 days'),
(5,CURRENT_TIMESTAMP - INTERVAL '30 days'),
(4,CURRENT_TIMESTAMP - INTERVAL '20 days'),
(1,CURRENT_TIMESTAMP - INTERVAL '10 days');

INSERT INTO Details (numero_emprunt,numero_detail,isbn,exemplaire,date_de_rendu) VALUES
(1,1,'2038704015',1,CURRENT_TIMESTAMP - INTERVAL '195 days'),
(1,2,'2070367177',2,CURRENT_TIMESTAMP - INTERVAL '190 days'),
(2,1,'2080720872',1,CURRENT_TIMESTAMP - INTERVAL '180 days'),
(2,2,'2203314168',1,CURRENT_TIMESTAMP - INTERVAL '179 days'),
(3,1,'2038704015',1,CURRENT_TIMESTAMP - INTERVAL '170 days'),
(4,1,'2203314168',2,CURRENT_TIMESTAMP - INTERVAL '155 days'),
(4,2,'2080720872',1,CURRENT_TIMESTAMP - INTERVAL '155 days'),
(4,3,'2266085816',1,CURRENT_TIMESTAMP - INTERVAL '159 days'),
(5,1,'2038704015',2,CURRENT_TIMESTAMP - INTERVAL '140 days'),
(6,1,'2266085816',2,CURRENT_TIMESTAMP - INTERVAL '141 days'),
(6,2,'2080720872',2,CURRENT_TIMESTAMP - INTERVAL '130 days'),
(6,3,'2746021285',2,CURRENT_TIMESTAMP - INTERVAL '133 days'),
(7,1,'2070367177',2,CURRENT_TIMESTAMP - INTERVAL '100 days'),
(8,1,'2080720872',1,CURRENT_TIMESTAMP - INTERVAL '116 days'),
(9,1,'2038704015',1,CURRENT_TIMESTAMP - INTERVAL '100 days'),
(10,1,'2080720872',2,CURRENT_TIMESTAMP - INTERVAL '107 days'),
(10,2,'2746026090',1,CURRENT_TIMESTAMP - INTERVAL '78 days'),
(11,1,'2746021285',1,CURRENT_TIMESTAMP - INTERVAL '81 days'),
(12,1,'2203314168',1,CURRENT_TIMESTAMP - INTERVAL '86 days'),
(12,2,'2038704015',1,CURRENT_TIMESTAMP - INTERVAL '60 days'),
(13,1,'2070367177',1,CURRENT_TIMESTAMP - INTERVAL '65 days'),
(14,1,'2266091611',1,CURRENT_TIMESTAMP - INTERVAL '66 days'),
(15,1,'2266085816',1,CURRENT_TIMESTAMP - INTERVAL '50 days'),
(16,1,'2253010219',2,CURRENT_TIMESTAMP - INTERVAL '41 days'),
(16,2,'2070367177',2,CURRENT_TIMESTAMP - INTERVAL '41 days'),
(17,1,'2877065073',2,CURRENT_TIMESTAMP - INTERVAL '36 days'),
(18,1,'2070367177',1,CURRENT_TIMESTAMP - INTERVAL '14 days'),
(19,1,'2746026090',1,CURRENT_TIMESTAMP - INTERVAL '12 days'),
(20,1,'2266091611',1,NULL),
(20,2,'2253010219',1,NULL);
