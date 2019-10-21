ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

--Zad17
SELECT k.pseudo "POLUJE W POLU", k.przydzial_myszy "PRZYDZIAL MYSZY", b.nazwa "BANDA"
    FROM Kocury K JOIN Bandy B
    ON k.nr_bandy = b.nr_bandy
    WHERE teren IN ('POLE', 'CALOSC') AND przydzial_myszy>50;
    
--Zad18
SELECT k1.imie, k1.w_stadku_od "POLUJE OD"
    FROM Kocury k1, Kocury k2
   -- ON k1.pseudo = k2.pseudo 
    WHERE k2.imie='JACEK' AND k1.w_stadku_od < k2.w_stadku_od
    ORDER BY 2 DESC;
    
--Zad19
--a
SELECT k1.imie, k1.funkcja, k2.imie "Szef1", k3.imie "Szef2", k4.imie "Szef3"
    FROM Kocury k1 JOIN Kocury k2 
    ON k1.szef = k2.pseudo
    LEFT JOIN Kocury k3 ON k2.szef=k3.pseudo
    LEFT JOIN Kocury k4 ON k3.szef=k4.pseudo
    WHERE k1.funkcja IN ('KOT', 'MILUSIA');
    
--b
