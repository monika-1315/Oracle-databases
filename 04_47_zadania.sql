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