-- 1 Ecrire la fonction FinValidite qui calcule la date de fin de validité de l’adhésion d’un membre dont le numéro est passé en paramètre.

CREATE OR REPLACE FUNCTION FinValidite(numero_membre IN INTEGER) RETURN SYSDATE IS  
	duree INTEGER := (SELECT duree FROM Membre M WHERE M.numero_membre = numero_membre);
	date_debut_validite SYSDATE := (SELECT date_adhere FROM Membre M WHERE M.numero_membre = numero_membre);
	date_fin_validite SYSDATE;
BEGIN  
	date_fin_validite := date_debut validite + INTERVAL duree month from DUAL; 
	Return date_fin_validite;  
END; 

-- 2 Ecrire la fonction AdhesionAjour qui retourne une valeur booléenne afin de savoir si un membre peut ou non effectuer des locations.

CREATE OR REPLACE FUNCTION AdhesionAjour(numero_membre IN INTEGER) RETURN BOOLEAN IS  
	location BOOLEAN;
	date_fin_validite SYSDATE := FinValidite(numero_membre); 
BEGIN  
	location := (date_fin_validite > SYSDATE FROM DUAL);
	Return location;  
END; 

-- 3 Ecrire la procédure RetourExemplaire qui accepte en paramètres un numéro d’ISBN et un numéro d’exemplaire afin d’enregistrer la restitution de l’exemplaire de l’ouvrage emprunté.

CREATE OR REPLACE FUNCTION RetourExemplaire(isbn IN NUMERIC(10,0), exemplaire IN INTEGER) IS	
	numero_emprunt INTEGER :=(SELECT numero_emprunt FROM Emprunt E, Details D WHERE D.isbn = isbn and D.numero_exemplaire = exemplaire and E.numero_emprunt = D.numero_emprunt);
BEGIN
	UPDATE Emprunt E SET etat = 'RE'
	WHERE E.numero_emprunt = numero_emprunt;
	UPDATE Details D SET date_de_rendu = SYDATE FROM DUAL
	WHERE D.isbn = isbn and D.numero_exemplaire = exemplaire;
END;

-- 4 Ecrire la procédure PurgeMembres qui permet de supprimer tous les membres dont l’adhésion n’a pas été renouvelée depuis trois ans.

CREATE OR REPLACE FUNCTION PurgeMembres IS
BEGIN
	DELETE FROM Membre 
	WHERE (date_adhere + duree) >= SYSDATE - '3' year FROM DUAL;
END;

-- 5 Ecrire la fonction MesureActivite qui permet de connaître le numéro du membre qui a emprunté le plus d’ouvrage pendant une période de temps passée en paramètre de la fonction. Cette période est exprimée en mois.

CREATE OR REPLACE FUNCTION MesureActivite(duree IN SYSDATE) RETURN INTEGER IS
	numero_membre INTEGER := (SELECT Top 1 count(*) FROM Emprunt WHERE date_emprunt >= (SYSDATE - INTERVAL duree month FROM DUAL) GROUP BY (numero_membre) ORDER BY count(*) DESC;
BEGIN
	Return numero_membre;
END;

-- 6 Ecrie la fonction EmpruntMoyen qui accepte en paramètre d’entrée le numéro d’un membre et qui retourne la durée moyenne (en nombre de jours) d’emprunt d’un ouvrage.
-- à revoir, ne marchera pas même sous Oracle, utiliser TRUNC quand même

CREATE OR REPLACE FUNCTION EmpruntMoyen(numero_membre IN INTEGER) RETURN INTEGER IS
	nombre_d_emprunt INTEGER := (SELECT count(*) FROM Emprunt E WHERE E.numero_membre = numero_membre GROUP BY (E.numero_emprunt));
	duree_en_jour INTEGER := (SELECT TRUNC((SELECT TOP 1 date_de_rendu FROM Details D, Emprunt E WHERE D.numero_emprunt = E.numero_emprunt ORDER BY date_rendu DESC) - date_emprunt) FROM Emprunt E WHERE E.numero_membre = numero_membre;
	duree_moyenne INTEGER := (duree_en_jour / nombre_emprunt);
BEGIN
	Return duree_moyenne;
END;

/* 7 Ecrire la fonction DureeMoyenne qui accepte en paramètre un numéro d’ISBN et
éventuellement un numéro d’exemplaire et qui retourne, soit la durée moyenne d’emprunt de
l’ouvrage (seul le numéro ISBN est connu), soit la durée moyenne d’emprunt de l’exemplaire
dans le cas où l’on connaît le numéro d’ISBN et le numéro de l’exemplaire. */

CREATE OR REPLACE FUNCTION DureeMoyenne(isbn IS NUMERIC(10,0), exmplaire IS INTEGER) RETURN INTEGER IS
	
BEGIN
	
END;
