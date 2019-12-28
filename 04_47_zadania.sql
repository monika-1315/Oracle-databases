ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

SELECT  pseudo
 FROM (SELECT K.pseudo pseudo FROM Kocury2 K ORDER BY K.Dochod_myszowy() ASC)
         WHERE ROWNUM<= (SELECT COUNT(*) FROM Kocury2)/2;
         
SELECT E.kot.pseudo, E.sluga.pseudo, E.pseudo, E.kot.dochod_myszowy() FROM Elita E;

SELECT K.nr_bandy, COUNT(K.pseudo) ilosc_kotow 
    FROM Kocury2 K
    GROUP BY K.nr_bandy
    ORDER BY K.nr_bandy;
    
SELECT K.kot.nr_bandy nr_bandy, COUNT(K.pseudo) ilosc_kotow_w_elicie 
    FROM Elita K
    GROUP BY K.kot.nr_bandy
    ORDER BY K.kot.nr_bandy;
    
--lista 2
--Zad18
SELECT k1.imie, k1.w_stadku_od "POLUJE OD"
    FROM Kocury2 k1, Kocury2 k2
   -- ON k1.pseudo = k2.pseudo 
    WHERE k2.imie='JACEK' AND k1.w_stadku_od < k2.w_stadku_od
    ORDER BY 2 DESC;
--Zad22
SELECT k.funkcja, k.pseudo, sel.lw "Liczba wrogow"
FROM Kocury2 k JOIN
(SELECT COUNT(pseudo) lw, pseudo
    FROM Incydenty
    GROUP BY pseudo) sel
ON k.pseudo = sel.pseudo
WHERE sel.lw>1;