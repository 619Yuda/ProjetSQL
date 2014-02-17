-- 1 -- Etablissez le nombre d’emprunts par ouvrage et par exemplaire. Utilisez l’opérateur ROLLUP pour effectuer le calcul d’agrégat sur les critères de regroupement plus généraux. Utilisez la fonction DECODE pour présenter le résultat de façon plus lisible.

SELECT isbn, numero_exemplaire, count(*) AS "Nombre d'emprunt"
    FROM Details
    GROUP BY ROLLUP(isbn, numero_exemplaire);

-- Le groupe de même isbn est indiqué dans la collone exemplaire par "-", pour ameliorer l'affichage ou peu utiliser la fonction DECODE
-- decode({valeur de test}, {valeur de comparaison}, {valeur retournée en cas de correspondance}, {valeur retournée si aucune correspondance n'est trouvée})
-- Solution non trouvée

-- SELECT isbn, DECODE (numero_exemplaire <=0, numero_exemplaire, 'Tous exemplaires confondus')
--     count(*) AS "Nombre d'emprunt"
--     FROM Details
--     GROUP BY ROLLUP(isbn, numero_exemplaire);


-- 2 -- Etablissez la liste des exemplaires qui n’ont jamais été empruntés au cours des trois derniers mois.
-- Pour effectuer les calculs sur les trois derniers mois, c’est la date de retour de l’exemplaire qui est prise en compte.
-- Utilisation de l'oppérateur MINUS tt les exemplaires moins ceux qui ont été emprunté au moins une fois au cours de 3 derniers mois

SELECT isbn, numero_exemplaire FROM exemplaire
MINUS
SELECT DISTINCT isbn, numero_exemplaire FROM details WHERE date_de_rendu > SYSDATE - INTERVAL '3' MONTH OR date_de_rendu IS NULL;


-- 3 -- Etablissez la liste des ouvrages pour lesquels il n’existe pas d’exemplaires à l’état neuf.
-- utilisation d'une sous requête qui ramméné la liste des exemplaire neufs.

SELECT isbn, titre 
    FROM Exemplaire
    JOIN ouvrage USING (isbn)
    GROUP BY isbn, titre
    HAVING isbn NOT IN (
    SELECT isbn
         FROM Exemplaire
         WHERE etat LIKE 'Neuf');

-- 4 -- Extrayez tous les titres qui contiennent le mot « mer » quelque soit sa place dans le titre et la casse avec laquelle il est renseigné.

SELECT titre
    FROM Ouvrage
    WHERE REGEXP_LIKE (titre, 'mer', 'i'); -- 'i' = ignore la casse

-- 5 --Ecrivez une requête qui permet de connaître tous les auteurs dont le nom possède la particule « de ».
-- ne marche que sur oracle

SELECT auteur
    FROM Ouvrage
    WHERE REGEXP_LIKE (auteur, '.+ de .+', 'i');

-- Marche comme ça mais pas avec la regexp [:space:] ?
-- SELECT auteur
--    FROM Ouvrage
--    WHERE REGEXP_LIKE (auteur, '.+[:space:]de[:space:].+', 'i');


-- 6 -- A partir des genres des livres, affichez le public de chaque ouvrage en vous appuyant sur la table des correspondances ci-dessous. L’objectif est de connaître pour chaque titre le public susceptible de lire l’ouvrage. L’instruction CASE peut s’avérer utile pour aboutir rapidement à un tel résultat.

SELECT Titre, code_genre,
    CASE code_genre
    WHEN 'BD' THEN 'Jeunesse'
    WHEN 'INF' THEN 'Professionnel'
    WHEN 'POL' THEN 'Adulte'
    WHEN 'REC' THEN 'Tous'
    WHEN 'ROM' THEN 'Tous'
    WHEN 'THE' THEN 'Tous'
    END AS "Public cible"
    FROM ouvrage;

-- 7 -- Pour l’instant, l’objectif de chaque table semble évident. Mais d’ici quelque temps ce ne sera peut-être plus le cas.
-- Aussi est-il judicieux d’associer un commentaire à chaque table, voire à chaque colonne.

COMMENT ON TABLE Membre IS 'Descriptifs des membres. Possède le synonymes Abonnes';
COMMENT ON TABLE Genre IS 'Descriptifs des genres possibles des ouvrages';
COMMENT ON TABLE Ouvrage IS 'Descriptifs des ouvrages référencés par la bibliothèque';
COMMENT ON TABLE Exemplaire IS 'Définition précise des livres présents dans la bibliothèque';
COMMENT ON TABLE Emprunt IS 'Fiche d emprunt de livres, toujours associée à un et un seul membre'; -- pas possible de mettre de ' dans le commentaire
COMMENT ON TABLE Details IS 'Chaque ligne correspond à un libre emprunté';

-- 8 -- Interrogez les commentaires associés aux tables présentes dans le schéma de l’utilisateur courant. La table USER_TAB_COMMENTS du dictionnaire doit être mise à contribution.

SELECT * FROM USER_TAB_COMMENTS WHERE comments IS NOT NULL;
 -- is not null est utilisé pour eviter d'afficher les autres tables créés par défaut dans oracle

-- 9 -- Lors de la création d’un nouveau membre, on souhaite enregistrer un emprunt dans la même transaction. Comment rendre possible cette nouvelle contrainte de fonctionnement ?

-- Peut être possible sans trigger ?

-- Ajouter une instruction dans le TRIGGER de la table membre qui propose d'ajouter une ligne dans les tables details en et emprunt avec les informations correspondantes à chaque fois qu'un membre est inséré
-- NE FONCTIONNE PAS mais l'idée est là...

CREATE OR REPLACE TRIGGER AfterInstructionOnMember
    AFTER UPDATE ON MEMBRE
    BEGIN
        INSERT INTO Temp_AFFICHAGE VALUES(
        v_compteur.NEXTVAL,
        ‘AFTER niveau instruction : compteur =’ || TriggerMoment.v_compteur );
        TriggerMoment.v_compteur := TriggerMoment.v_compteur + 1;
        PROMPT 'Ajouter un nouvel emprun ? (Y/N)'
        ACCEPT choix
        IF choix = 'Y'
            INSERT INTO Emprunt (numero_emprunt, numero_membre, date_emprunt, etat) VALUES (seq_numero_emprunt.NEXTVAL, v_compteur, SYSDATE, 'EC');
            PROMPT 'ISBN ?'
            ACCEPT isbn
            PROMPT 'Exemplaire ?'
            ACCEPT exemplaire
            INSERT INTO Details (numero_emprunt, numero_detail, isbn, exemplaire, date_de_rendu) VALUES (seq_numero_emprunt, v_compteur, isbn, exemplaire, NULL);
    END BeforeInstructionOnMember;

-- 10 -- Supprimez la table des détails.
DROP TABLE Details;

-- la table est placé dans la corbeille oracle visible par la commande suivante
SELECT * FROM RECYCLEBIN;

-- 11 -- Annulez cette suppression de table.
-- Marche même si autocommit activé !

FLASHBACK TABLE Details to BEFORE DROP;

-- la table n'est plus dans la poubelle
SELECT * FROM RECYCLEBIN;

-- 12 -- Il n'y a pas de question 12 ??

-- 13 -- Les utilisateurs souhaitent une requête qui permette d’afficher un message en fonction du nombre d’exemplaires de chaque ouvrage.

SELECT isbn, titre, (CASE
    WHEN count(*) = 0 THEN 'Aucun'
    WHEN count(*) BETWEEN 1 AND 2 THEN 'Peu'
    WHEN count(*) BETWEEN 3 AND 5 THEN 'Normal'
    ElSE 'Beaucoup'
    END) AS "Exemplaires disponibles"
FROM Exemplaire JOIN Ouvrage USING (isbn)
GROUP BY (isbn, titre);

