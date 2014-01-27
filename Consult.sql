/*
On souhaite modifier l’état des exemplaires en fonction de leur nombre de locations afin de
faire passer les exemplaires actuellement à l’état Neuf vers l’état Bon et supprimer les
exemplaires qui ont été loués plus de 60 fois. En effet, les bibliothécaires considèrent qu’un
tel exemplaire doit être retiré de la location car il ne répond pas à la qualité souhaitée par les
membres. Les livres sont considérés neufs lorsqu’ils ont été empruntés moins de 11 fois. A
partir du 11ème emprunt et jusqu’au 25ème leur état est bon.
*/

-- INSERT colone NB EMPRUNT

-- UPDATE EXISTING VALUE

DECLARE
	CURSOR c_employe IS
		SELECT nb empruntetat
		FROM EMPLOYES
		FOR UPDATE OF SALAIRE, COMMISSION ;
	V_employe c_employe%ROWTYPE;
BEGIN
	OPEN c_employe;
	FETCH c_employe INTO V_employe;
		UPDATE EMPLOYES SET SALAIRE = V_employe.SALAIRE	+ V_employe.salaire * 0.1
		WHERE NOM = V_employe.NOM ;
	COMMIT;
	CLOSE c_employe ;
END;
/

-- TRIGGER FOR FUTURE UPDATE


