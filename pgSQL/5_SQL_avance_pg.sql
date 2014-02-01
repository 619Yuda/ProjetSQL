-- 1 -- Etablissez le nombre d’emprunts par ouvrage et par exemplaire. Utilisez l’opérateur ROLLUP pour effectuer le calcul d’agrégat sur les critères de regroupement plus généraux. Utilisez la fonction DECODE pour présenter le résultat de façon plus lisible.

-- 2 -- Etablissez la liste des exemplaires qui n’ont jamais été empruntés au cours des trois derniers mois. Pour effectuer les calculs sur les trois derniers mois, c’est la date de retour de l’exemplaire qui est prise en compte.

SELECT titre, numero_exemplaire FROM Ouvrage O, Details D, Emprunt E
WHERE D.isbn = O.isbn and E.numero_emprunt = D.numero_emprunt and E.date_emprunt < SYSDATE - 3 MM;