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
--SELECT imie, funkcja, 


--Zad20
SELECT k.imie "Imie kotki", b.nazwa "Nazwa bandy", w.imie_wroga "Imie wroga", w.stopien_wrogosci "Ocena wroga", wk.data_incydentu "Data inc."
    FROM Kocury k JOIN Bandy b ON k.nr_bandy=b.nr_bandy AND plec='D'
        JOIN Wrogowie_Kocurow wk ON k.pseudo=wk.pseudo AND data_incydentu>'2007-01-01'
        JOIN wrogowie w ON w.imie_wroga=wk.imie_wroga;
        
--Zad21
SELECT b.nazwa "Nazwa bandy", 
(SELECT COUNT(DISTINCT wk.pseudo) FROM Kocury k JOIN wrogowie_kocurow wk ON wk.pseudo=k.pseudo
    WHERE k.nr_bandy=b.nr_bandy GROUP BY k.nr_bandy) "Koty z wrogami"
    FROM Bandy b;


SELECT b.nazwa "Nazwa bandy", sel.kw "Koty z wrogami"
FROM bandy b JOIN
(SELECT COUNT(DISTINCT wk.pseudo) kw, b.nr_bandy
    FROM Kocury K JOIN Wrogowie_kocurow wk ON k.pseudo=wk.pseudo
        JOIN Bandy b ON b.nr_bandy=k.nr_bandy
    GROUP BY b.nr_bandy) sel
ON b.nr_bandy=sel.nr_bandy;
        
--Zad22
SELECT k.funkcja, k.pseudo, sel.lw "Liczba wrogow"
FROM Kocury k JOIN
(SELECT COUNT(pseudo) lw, pseudo
    FROM Wrogowie_kocurow
    GROUP BY pseudo) sel
ON k.pseudo = sel.pseudo
WHERE sel.lw>1;

--Zad23
SELECT * FROM (
SELECT imie, 12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) "DAWKA ROCZNA", 'powyzej 864' dawka
    FROM Kocury
    WHERE 12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))>864 AND myszy_extra IS NOT NULL
UNION
SELECT imie, 12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)), '864'
    FROM Kocury
    WHERE 12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))=864 AND myszy_extra IS NOT NULL
UNION
SELECT imie, 12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) dr, 'ponizej 864'
    FROM Kocury
    WHERE 12*(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))<864 AND myszy_extra IS NOT NULL)
ORDER BY 2 DESC;

--Zad24
SELECT b.nr_bandy "NR BANDY", b.nazwa, b.teren
    FROM Bandy b LEFT JOIN Kocury k
    ON b.nr_bandy=k.nr_bandy
    WHERE k.nr_bandy IS NULL;
    
SELECT nr_bandy "NR BANDY", nazwa, teren
    FROM Bandy  
MINUS (SELECT b1.nr_bandy, b1.nazwa, b1.teren
                FROM Bandy b1 JOIN Kocury k
                ON b1.nr_bandy=k.nr_bandy);
                
--Zad25
SELECT imie, funkcja, przydzial_myszy
    FROM Kocury
    WHERE przydzial_myszy >= ALL (SELECT 3*przydzial_myszy
                        FROM Kocury k JOIN BANDY b 
                        ON k.nr_bandy=b.nr_bandy AND funkcja='MILUSIA' AND teren IN ('SAD', 'CALOSC'));
            
--Zad26
WITH Sr AS 
    (SELECT ROUND(AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))) sre, funkcja
        FROM Kocury
        GROUP BY funkcja)
SELECT DISTINCT k.funkcja "Funkcja", sre "Srednio najw. i najm. myszy"
FROM Kocury k JOIN Sr ON k.funkcja=Sr.funkcja
WHERE k.funkcja!='SZEFUNIO' AND (sre<=ALL (SELECT ROUND(AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))) sre
        FROM Kocury WHERE funkcja!='SZEFUNIO' GROUP BY funkcja)
            OR sre>=ALL     (SELECT ROUND(AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0))) sre
        FROM Kocury WHERE funkcja!='SZEFUNIO' GROUP BY funkcja));
        
--Zad27
--a

--b
SELECT pseudo, zjada 
FROM (SELECT pseudo, zjada, ROWNUM
    FROM (SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) zjada
        FROM Kocury 
        ORDER BY 2 DESC))
    WHERE 
    
SELECT * FROM
(SELECT pseudo, zjada, ROWNUM
FROM (SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) zjada
    FROM Kocury 
    ORDER BY 2 DESC))s1
    JOIN
    (SELECT pseudo, zjada
    FROM (SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) zjada
    FROM Kocury 
    ORDER BY 2 DESC))s2
    ON s1.zjada=s2.zjada AND s1.pseudo<s2.pseudo
WHERE ROWNUM<=&n OR
--c
--d
SELECT pseudo, zjada
FROM (SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) zjada, 
                DENSE_RANK()
                OVER (ORDER BY NVL(przydzial_myszy,0)+NVL(myszy_extra,0) DESC) pozycja
        FROM Kocury)
WHERE pozycja<= &n;
        