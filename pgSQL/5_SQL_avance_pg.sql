-- 1 -- Etablissez le nombre d’emprunts par ouvrage et par exemplaire. Utilisez l’opérateur ROLLUP pour effectuer le calcul d’agrégat sur les critères de regroupement plus généraux. Utilisez la fonction DECODE pour présenter le résultat de façon plus lisible.

-- 2 -- Etablissez la liste des exemplaires qui n’ont jamais été empruntés au cours des trois derniers mois. Pour effectuer les calculs sur les trois derniers mois, c’est la date de retour de l’exemplaire qui est prise en compte.
-- ne marche que sur oracle
SELECT titre, numero_exemplaire FROM Ouvrage O, Details D, Emprunt E
WHERE D.isbn = O.isbn and E.numero_emprunt = D.numero_emprunt and E.date_emprunt < SYSDATE - INTERVAL '3' MONTH FROM DUAL;

-- 3 -- Etablissez la liste des ouvrages pour lesquels il n’existe pas d’exemplaires à l’état neuf.
SELECT titre, O.isbn FROM Ouvrage O, Exemplaire E
WHERE E.isbn =  O.isbn and (E.etat = 'Bon' OR E.etat = 'Moyen' OR E.etat = 'Mauvais');

-- 4 -- Extrayez tous les titres qui contiennent le mot « mer » quelque soit sa place dans le titre et la casse avec laquelle il est renseigné.
-- ne marche que sur oracle
SELECT titre FROM Ouvrage
WHERE REGEXP_LIKE (titre, '^*mer*$');

-- 5 --Ecrivez une requête qui permet de connaître tous les auteurs dont le nom possède la particule « de ».
-- ne marche que sur oracle
SELECT auteur FROM Ouvrage
WHERE REGEXP_LIKE (auteur, '^*de*$');

-- 6 -- A partir des genres des livres, affichez le public de chaque ouvrage en vous appuyant sur la table des correspondances ci-dessous. L’objectif est de connaître pour chaque titre le public susceptible de lire l’ouvrage. L’instruction CASE peut s’avérer utile pour aboutir rapidement à un tel résultat.
-- ne marche que sur oracle
SELECT libelle 
	CASE 'Public'
      WHEN libelle = 'Bande Dessinée' THEN 'Jeunesse'
      WHEN libelle = 'Informatique' THEN 'Professionnel'
      WHEN libelle = 'Policier' THEN 'Adulte'
      WHEN libelle = 'Récit' THEN 'Tous'
      WHEN libelle = 'Roman' THEN 'Tous'
      WHEN libelle = 'Théâtre' THEN 'Tous'
    END
FROM Genre;

-- 7 -- Pour l’instant, l’objectif de chaque table semble évident. Mais d’ici quelque temps ce ne sera peut-être plus le cas. Aussi est-il judicieux d’associer un commentaire à chaque table, voire à chaque colonne.
COMMENT ON TABLE Membre IS 'Descriptifs des membres. Possède le synonymes Abonnes';
COMMENT ON TABLE Genre IS 'Descriptifs des genres possibles des ouvrages';
COMMENT ON TABLE Ouvrage IS 'Descriptifs des ouvrages référencés par la bibliothèque';
COMMENT ON TABLE Exemplaire IS 'Définition précise des livres présents dans la bibliothèque';
COMMENT ON TABLE Emprunt IS 'Fiche d''emprunt de livres, toujours associée à un et un seul membre';
COMMENT ON TABLE Details IS 'Chaque ligne correspond à un libre emprunté';
