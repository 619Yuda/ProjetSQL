-- 1 -- Mise à jour conditionnelle : tous les exemplaires ont été enregistrés avec l’état neuf, mais au fur et à mesure des emprunts, leur état s’est dégradé. Il s’agit maintenant de mettre à jour l’état de chacun en fonction du nombre de fois que l’exemplaire a été emprunté. En effet, le nombre d’emprunteurs a plus d’incidence sur l’état général de l’exemplaire que la durée effective des emprunts.
-- TRIGGER en commentaire
--CREATE OR REPLACE TRIGGER ApresAjoutEmprunt
--AFTER UPDATE ON Details
BEGIN
	UPDATE Exemplaire SET etat = 'Neuf'
	WHERE (SELECT count(*) FROM Exemplaire E, Details D
			WHERE D.isbn = E.isbn and D.exemplaire = E.numero_exemplaire GROUP BY (D.isbn, D.exemplaire)) < 10;
UPDATE Exemplaire SET etat = 'Bon'
	WHERE (SELECT count(*) FROM Exemplaire E, Details D
			WHERE D.isbn = E.isbn and D.exemplaire = E.numero_exemplaire GROUP BY (D.isbn, D.exemplaire)) <= 11;
UPDATE Exemplaire SET etat = 'Moyen'
	WHERE (SELECT count(*) FROM Exemplaire E, Details D
			WHERE D.isbn = E.isbn and D.exemplaire = E.numero_exemplaire GROUP BY (D.isbn, D.exemplaire)) <= 26;
UPDATE Exemplaire SET etat = 'Mauvais'
	WHERE (SELECT count(*) FROM Exemplaire E, Details D
			WHERE D.isbn = E.isbn and D.exemplaire = E.numero_exemplaire GROUP BY (D.isbn, D.exemplaire)) < 41;
END --ApresAjoutEmprunt;

/* 2 Ecrivez un bloc PL/SQL qui permet de supprimer les membres dont l’adhésion a expiré
depuis plus de 2 ans.
Si des fiches d’emprunts existent et si les exemplaires empruntés ont été rendus, alors mettre à
NULL la valeur présente dans la colonne MEMBRE.
S’il reste des livres empruntés et non rendus, alors ne pas supprimer le membre.*/
-- à tester sur Oracle
BEGIN
	UPDATE Emprunt SET numero_membre = NULL
	WHERE Emprunt.numero_membre = Membre.numero_membre and Emprunt.etat = 'EC' and (SYSDATE - date_adhere + INTERVAL Membre.duree MONTH FROM DUAL) = INTERVAL '2' YEAR FROM DUAL;
	DELETE FROM Membre
	WHERE Emprunt.numero_membre = Membre.numero_membre and Emprunt.etat = 'RE' and(SYSDATE - date_adhere + INTERVAL Membre.duree MONTH FROM DUAL) = INTERVAL '2' YEAR FROM DUAL;
END

/* 3 Ecrire un bloc PL/SQL qui permet d’éditer la liste des trois membres qui ont emprunté le
plus d’ouvrages au cours des dix derniers mois et établissez également la liste des trois
membres qui ont emprunté moins.*/
-- SELECT TOP X XXX ne marche que sur Oracle
BEGIN
	SELECT TOP 3 M.numero_membre, count(*) FROM Membre M, Emprunt E
	WHERE E.numero_membre = M.numero_membre 
	GROUP BY (M.numero_membre)
	ORDER BY count(*) DESC;
	
	SELECT TOP 3 M.numero_membre, count(*) FROM Membre M, Emprunt E
	WHERE E.numero_membre = M.numero_membre 
	GROUP BY (M.numero_membre)
	ORDER BY count(*) ASC;
END

/* 4 Ecrivez un bloc PL/SQL qui permet de connaître les cinq ouvrages les plus empruntés.*/
BEGIN 
	SELECT TOP 5 O.titre, count(*) FROM Ouvrage O, Details D
	WHERE D.isbn = O.isbn
	GROUP BY (O.titre)
	ORDER BY count(*) DESC;
END

/* 5 Etablissez la liste des membres dont l’adhésion a expiré, ou bien qui va expirer dans les 30
prochains jours. Affichez la liste à l’écran. */
-- à tester sur Oracle
BEGIN
	SELECT numero_membre FROM Membre
	WHERE SYSDATE >= date_adhere + duree;
	SELECT numero_membre FROM Membre
	WHERE SYSDATE >= date_adhere + duree + INTERVAL '30' day FROM DUAL;
END

/* 6 Les exemplaires sont tous achetés à l’état neuf. Pour calculer leur état actuel, il faut être
capable de connaître le nombre de fois où ils ont été empruntés. Mais les membres sont
nombreux et il est impossible de conserver de nombreuses années en ligne tout ce qui
concerne le détail des locations.
Un exemplaire est considéré comme emprunté à partir du moment où il est présent sur une
fiche d’emprunt. C’est donc la date de création de la fiche qui permet de savoir quand le livre
a été emprunté.
Au niveau des exemplaires, une colonne de type date va être ajoutée afin de connaître la date
du dernier calcul de mise à jour de l’état. Lors de l’exécution du bloc PL/SQL, seuls les
emprunts effectués, depuis cette date, seront pris en compte. Afin que la mise à jour de l’état
de l’exemplaire soit effectuée de la façon la plus juste, une seconde colonne va être ajoutée
afin de mémoriser le nombre d’emprunts pour cet exemplaire.

a) Ecrivez un script pour effectuer les modifications de structure demandées.
*/
-- ne marche que sur Oracle
ALTER TABLE Exemplaire ADD COLUMN nombre_emprunts NUMBER(3);
ALTER TABLE Exemplaire ADD COLUMN date_calcul_emprunts SYSDATE;

/*Pour chaque exemplaire, la valeur par défaut au moment de la création dans la colonne
DATECALCULDEMPRUNTS doit correspondre à la date de premier emprunt de cet
exemplaire par l’un des membres, ou bien la date du jour si cet exemplaire n’a pas encore été
emprunté.

b) Ecrivez le bloc PL/SQL qui permet de mettre à jour les informations sur la table des
exemplaires.*/
-- utiliser en curseur ?
BEGIN
	Exemplaire.nombre_emprunts := (SELECT count(*) FROM Exemplaire E, Details D
	WHERE D.isbn = E.isbn and D.exemplaire = E.numero_exemplaire
	GROUP BY (E.isbn, E.numero_exemplaire);
	Exemplaire.date_calcul_emprunts := (SELECT TOP 1 date_rendu FROM Details D, Exemplaire E
	WHERE D.isbn = E.isbn and D.exemplaire = E.numero_exemplaire
	ORDER date_rendu BY DESC);
END
	
/* 7 Si plus de la moitié des exemplaires sont dans l’état Moyen ou Mauvais alors modifiez la
contrainte d’intégrité afin que les différents états possibles d’un exemplaire soient : Neuf,
Bon, Moyen, Douteux ou Mauvais.
Un exemplaire est dans l’état Douteux lorsqu’il a été emprunté entre 40 et 60 fois. Il est dans
l’état Mauvais lorsqu’il a été emprunté plus de 60 fois. */
-- à vérifier
BEGIN
	IF (SELECT count(*) FROM Exemplaire 
		WHERE etat = 'Moyen' and etat = 'Mauvais') > ((SELECT count(*) FROM Exemplaire)/2)
		ALTER TABLE cc_exemplaire_etat CHECK( etat IN ('Neuf', 'Bon', 'Moyen', 'Mauvais','Douteux')));
		UPDATE Exemplaire SET etat = 'Douteux'
		WHERE (SELECT count(*) FROM Exemplaire E, Details D
				WHERE D.isbn = E.isbn and D.exemplaire = E.numero_exemplaire GROUP BY (D.isbn, D.exemplaire)) <= 40;
		UPDATE Exemplaire SET etat = 'Mauvais'
		WHERE (SELECT count(*) FROM Exemplaire E, Details D
				WHERE D.isbn = E.isbn and D.exemplaire = E.numero_exemplaire GROUP BY (D.isbn, D.exemplaire)) <= 60;
	ENDIF
END

/* 8 Supprimez tous les membres qui n’ont pas effectué d’emprunt d’ouvrage depuis trois ans. */
-- à vérifier, ne marche que sur Oracle
BEGIN
	DELETE FROM Membre
	WHERE (SELECT TOP 1 date_emprunt FROM Emprunt E, Membre M
			WHERE E.numero_membre = M.numero_membre
			ORDER date_emprunt DESC) <= SYSDATE - INTERVAL '3' year FROM DUAL;
END

/* 9 Comme cela a été constaté précédemment, les membres possèdent tous un numéro de
téléphone mobile mais ce numéro n’est pas bien formaté et la nouvelle contrainte d’intégrité
ne peut être posée.
Ecrivez un bloc PL/SQL qui permet de s’assurer que tous les numéros de téléphone mobile
des membres respectent le format 06 xx xx xx xx. Puis posez une contrainte d’intégrité pour
vous assurez que tous les numéros possèderont toujours ce format. */

BEGIN
	IF(SELECT count(*) FROM Membre
		WHERE telephone_portable  CHECK (REGEXP_LIKE (telephone_portable, '^[0]{1}[6]{1}[0-9]{8}$')
		GROUP BY (telephone_portable)

	ALTER TABLE Membre
		ADD CONSTRAINT cc_telephone_portable CHECK (REGEXP_LIKE (telephone_portable, '^[0]{1}[6]{1}[0-9]{8}$'));
	
END