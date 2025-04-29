--Problématique de la société:L’entreprise souhaite exploiter les données issues des retours et avis clients afin d’améliorer la qualité de son réseau de magasins.

--Requête 1 : Quel est le nombre de retours clients sur la livraison ?
SELECT COUNT (cle_retour_client) AS Nombre_de_retour_clients
FROM retour_client
WHERE libelle_categorie = 'livraison' ;


--Requête 2 : Quelle est la liste des notes des clients sur les réseaux sociaux sur les TV ?
SELECT DISTINCT (note) as Note_reseaux_TV
FROM public.retour_client
INNER JOIN public.produit 
ON retour_client.cle_produit = produit.cle_produit
Where titre_produit = 'TV' and libelle_source = 'réseaux sociaux';


--Requête 3 : Quelle est la note moyenne pour chaque catégorie de produit ? (Classé de la meilleure à la moins bonne)
SELECT ROUND(AVG (note),2)as note_moyenne ,typologie_produit
FROM public.retour_client
RIGHT OUTER JOIN public.produit 
ON retour_client.cle_produit = produit.cle_produit
GROUP BY typologie_produit
ORDER BY note_moyenne desc;


--Requête 4 : Quels sont les 5 magasins avec les meilleures notes moyennes ?
SELECT ref_magasin,ROUND(AVG (note),2) as note_moyenne
FROM public.retour_client
GROUP BY ref_magasin
ORDER BY note_moyenne desc LIMIT 5;


--Requête 5 : Quels sont les magasins qui ont plus de 12 feedbacks sur le drive ?
SELECT ref_magasin,count (*) AS NB_FEEDBACKS
FROM retour_client
WHERE libelle_categorie = 'drive'
GROUP BY ref_magasin
HAVING count(*)>12;


--Requête 6 : Quel est le classement des départements par note ?
SELECT ROUND(AVG (note),2) Note_moyenne , departement
FROM retour_client
JOIN ref_magasin on retour_client.ref_magasin= ref_magasin.ref_magasin
GROUP BY departement
ORDER BY Note_moyenne desc ;


--Requête 7 : Quelle est la typologie de produit qui apporte le meilleur service après-vente ?
SELECT ROUND(AVG (note),2)as note_moyenne,typologie_produit
FROM produit
JOIN retour_client on produit.cle_produit= retour_client.cle_produit
GROUP by typologie_produit
ORDER BY note_moyenne desc 
LIMIT 1;


--Requête 8 : Quelle est la note moyenne sur l’ensemble des boissons ?
SELECT ROUND(AVG (note),2)as Moyenne_note_boissons
FROM retour_client
INNER JOIN produit on retour_client.cle_produit = produit.cle_produit
WHERE LOWER (titre_produit) like 'boissons%'
;

--Requête 9 : Quel est le classement des jours de la semaine où l’expérience client est la meilleure expérience en magasin ?
SELECT to_char(date_achat,'day')as jour_de_la_semaine,ROUND(avg(note),2) as Note_par_jours
FROM public.retour_client
WHERE libelle_categorie = 'expérience en magasin'
GROUP BY 1
ORDER BY 2 desc;


--Requête 10 : Sur quel mois a-t-on le plus de retour sur le service après-vente?
SELECT to_char(date_achat,'month')as mois ,count(cle_retour_client)as retour_client
FROM public.retour_client
WHERE libelle_categorie = 'service après-vente'
GROUP BY 1
ORDER BY 2 desc limit 1;

-- Requête 11 : Quel est le pourcentage de recommandations client ?
--  (Comptabiliser le nombre de retours client qui ont répondu “Oui”divisé
--  Par le nombre de retours total)

SELECT 
   ROUND ((COUNT(CASE WHEN recommandation = '1' THEN 1 END) * 100.0) / COUNT(*),2) AS pourcentage_recommandations
FROM public.retour_client;

SELECT ROUND(COUNT (recommandation)*100.00/ (SELECT count(*) FROM retour_client),2)AS pourcentage_recommandations
FROM retour_client
WHERE recommandation = '1';

--Requête 12 : Quels sont les magasins qui ont une note inférieure à la moyenne ?
SELECT ref_magasin,
    ROUND(AVG(note),2) AS moyenne_note_magasin
FROM public.retour_client
GROUP BY ref_magasin
HAVING AVG (note) < (SELECT AVG (note) 
FROM public.retour_client);

--Requête 13 : Quelles sont les typologies produites qui ont amélioré leur moyenne entre le 1er et le 2ème trimestre 2021 ?
SELECT t1.typologie_produit,
	   t1.moyenne_note AS moy_t1,
	   t2.moyenne_note AS moy_t2
FROM (SELECT 
	    typologie_produit, ROUND(
		AVG (note),2)AS moyenne_note
	  FROM
	    public.retour_client
	  LEFT JOIN
	    produit ON 
		public.retour_client.cle_produit = produit.cle_produit
	  WHERE 
	    date_achat >='2021-01-01'AND date_achat <='2021-03-31'
	  GROUP BY
	    typologie_produit) t1
INNER JOIN 
	(SELECT 
	    typologie_produit, ROUND(
		AVG (note),2)AS moyenne_note
	  FROM
	    public.retour_client
	  LEFT JOIN
	    produit ON 
		public.retour_client.cle_produit = produit.cle_produit
	  WHERE 
	    date_achat >='2021-04-01'AND date_achat <='2021-06-30'
	  GROUP BY
	    typologie_produit) t2
ON
	t1.typologie_produit = t2.typologie_produit
WHERE 
	t2.moyenne_note > t1.moyenne_note;

--ou
--Requête 13 : Quelles sont les typologies produites qui ont amélioré leur moyenne entre le 1er et le 2ème trimestre 2021 ?
WITH trimestre_1 as (SELECT 
	    typologie_produit, ROUND(
		AVG (note),2)AS note_1
	  FROM
	    public.retour_client as rc
	  INNER JOIN
	    produit as p ON rc.cle_produit = p.cle_produit
	  WHERE 
	    date_achat >='2021-01-01'AND date_achat <='2021-03-31'
	  GROUP BY
	    typologie_produit),
trimestre_2 as (SELECT 
	    typologie_produit, ROUND(
		AVG (note),2)AS note_2
	  FROM
	    public.retour_client as rc
	  INNER JOIN
	    produit as p ON rc.cle_produit = p.cle_produit
	  WHERE 
	    date_achat >='2021-04-01'AND date_achat <='2021-06-30'
	  GROUP BY
	    typologie_produit)
SELECT typologie_produit,note_1,note_2,ROUND((note_2-note_1)/note_2*100,2) as evolution FROM trimestre_1
join trimestre_2 using(typologie_produit)
where (note_2-note_1)/note_2 > 0 

--Requête 14 :  NPS
SELECT ROUND((
	(COUNT (CASE WHEN note >=9  THEN 1 END ) - COUNT (CASE WHEN note <=6 THEN 1 END)) *100.0) /COUNT(*),2) AS NPS
FROM retour_client;


--ou
--Requête 14 :  NPS
WITH promoteur_detracteur as (SELECT COUNT(CASE WHEN note >=9  THEN 1 END ) as promoteur, COUNT(CASE WHEN note <=6 THEN 1 END) as detracteur,COUNT(note) as total
FROM retour_client)
SELECT round((promoteur - detracteur )*100.0 / total,2) as NPS
FROM promoteur_detracteur


Requête de proposition 1 : quel sont les classements des département par recommandation client? 
SELECT departement,COUNT (recommandation)as nombre_recommandation
FROM public.ref_magasin
JOIN retour_client on ref_magasin.ref_magasin = retour_client.ref_magasin
where recommandation = '1'
GROUP BY 1
ORDER BY 2 DESC;


--Requête 14 : NPS par source
WITH promoteur_detracteur as (SELECT libelle_source, COUNT(CASE WHEN note >=9  THEN 1 END ) as promoteur, COUNT(CASE WHEN note <=6 THEN 1 END) as detracteur, COUNT(note) as total
FROM retour_client
GROUP BY libelle_source)
SELECT libelle_source,round((promoteur - detracteur )*100.0 / total,2) as NPS
FROM promoteur_detracteur


--Requête 16 :  Exemple: Quel est le nombre de retour clients par source? 
SELECT COUNT (cle_retour_client) AS 
Nombre_de_retour_clients,libelle_source 
FROM retour_client 
GROUP BY libelle_source; 






