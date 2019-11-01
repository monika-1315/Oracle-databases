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
SELECT k1.imie, k1.funkcja, k2.imie "Szef1", DECODE(k3.imie, null, ' ',k3.imie) "Szef2", DECODE(k4.imie, null, ' ',k4.imie) "Szef3"
    FROM Kocury k1 JOIN Kocury k2 
    ON k1.szef = k2.pseudo
    LEFT JOIN Kocury k3 ON k2.szef=k3.pseudo
    LEFT JOIN Kocury k4 ON k3.szef=k4.pseudo
    WHERE k1.funkcja IN ('KOT', 'MILUSIA');
    
--b
SELECT *
FROM (SELECT imie szefu, CONNECT_BY_ROOT imie "Imie", CONNECT_BY_ROOT funkcja "Funkcja", level lvl
        FROM Kocury k
        CONNECT BY  pseudo=PRIOR szef
        START WITH funkcja IN ('KOT','MILUSIA'))
    PIVOT
    (MIN (szefu)
    FOR lvl
    IN (2 "Szef 1",
        3 "Szef 2",
        4 "Szef 3"));
        
SELECT Im "Imie", Fun "Funkcja", NVL(Szef1,' ') "Szef 1", NVL(Szef2, ' ') "Szef 2", NVL(Szef3, ' ') "Szef 3"
FROM (SELECT imie szefu, CONNECT_BY_ROOT imie Im, CONNECT_BY_ROOT funkcja Fun, level lvl
        FROM Kocury k
        CONNECT BY  pseudo=PRIOR szef
        START WITH funkcja IN ('KOT','MILUSIA'))
    PIVOT
    (MIN (szefu)
    FOR lvl
    IN (2 Szef1,
        3 Szef2,
        4 Szef3));

--c
SELECT CONNECT_BY_ROOT imie "Imie ", '|' " ", CONNECT_BY_ROOT funkcja "Funkcja ", 
        CASE LENGTH(SUBSTR(SYS_CONNECT_BY_PATH(RPAD(imie,8),'| '),11))
        WHEN 30 THEN SUBSTR(SYS_CONNECT_BY_PATH(RPAD(imie,8),'| '),11) 
        ELSE SUBSTR(SYS_CONNECT_BY_PATH(RPAD(imie,8),'| '),11) || '|'
        END "Imiona kolejnych szefow"
    FROM Kocury k
    WHERE imie='MRUCZEK'
    CONNECT BY  pseudo=PRIOR szef
    START WITH funkcja IN ('KOT','MILUSIA');
    
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
SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) zjada 
        FROM Kocury K
    WHERE &n> (SELECT COUNT (pseudo)
            FROM Kocury 
            WHERE NVL(przydzial_myszy,0)+NVL(myszy_extra,0)>NVL(K.przydzial_myszy,0)+NVL(K.myszy_extra,0))
    ORDER BY 2 DESC;      
--b
WITH Zj AS (SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) zjada 
        FROM Kocury
        ORDER BY 2 desc)
SELECT pseudo, zjada
FROM Zj
    WHERE zjada IN (SELECT DISTINCT zjada from Zj WHERE rownum<=&n);
    
--c
WITH Koc AS
    (SELECT k1.pseudo pseud, NVL(k2.przydzial_myszy,0)+NVL(k2.myszy_extra,0) powt, NVL(k1.przydzial_myszy,0)+NVL(k1.myszy_extra,0) zjada 
        FROM Kocury k1 JOIN Kocury k2
        ON NVL(k1.przydzial_myszy,0)+NVL(k1.myszy_extra,0) <=  NVL(k2.przydzial_myszy,0)+NVL(k2.myszy_extra,0) )
SELECT DISTINCT Koc2.pseud, zjada
FROM Koc JOIN (SELECT pseud, COUNT( DISTINCT powt) cp
                FROM Koc
                GROUP BY pseud)koc2
    ON Koc.pseud=koc2.pseud
WHERE &n>=cp
ORDER BY 2 DESC;
--d

SELECT pseudo, zjada
FROM (SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra,0) zjada, 
                DENSE_RANK()
                OVER (ORDER BY NVL(przydzial_myszy,0)+NVL(myszy_extra,0) DESC) pozycja
        FROM Kocury)
WHERE pozycja<= &n;
        
--Zad28
WITH Wstap AS (SELECT to_char(EXTRACT (YEAR FROM w_stadku_od)) rok, COUNT(pseudo) wstapienia
    FROM Kocury
    GROUP BY EXTRACT (YEAR FROM w_stadku_od)),
    Srednia AS (SELECT 'srednia', ROUND(AVG(wstapienia),7) av
            FROM Wstap),
    Liczby AS (SELECT wstapienia,DENSE_RANK() OVER (ORDER BY wstapienia) pozycja
                FROM(SELECT wstapienia FROM Wstap
                            UNION (SELECT av FROM Srednia)))
SELECT rok, wstapienia "LICZBA WSTAPIEN"
    FROM Wstap
    WHERE wstapienia IN (SELECT wstapienia 
                            FROM Liczby
                        WHERE pozycja = (SELECT pozycja FROM Liczby WHERE wstapienia= (SELECT av FROM Srednia))-1
                            OR pozycja = (SELECT pozycja FROM Liczby WHERE wstapienia= (SELECT av FROM Srednia))+1)
    UNION SELECT * FROM Srednia
    ORDER BY 2;
            
--Zad29
--a
SELECT k.imie, NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0) zjada, k.nr_bandy, ROUND(AVG(NVL(k2.przydzial_myszy,0)+NVL(k2.myszy_extra,0)),2) "SREDNIA BANDY"
    FROM Kocury k JOIN Kocury k2
    ON k.plec='M' AND k.nr_bandy=k2.nr_bandy
    GROUP BY k.nr_bandy, k.imie, k.przydzial_myszy, k.myszy_extra
    HAVING NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0)< AVG(NVL(k2.przydzial_myszy,0)+NVL(k2.myszy_extra,0));
    
--b
SELECT k.imie, NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0) zjada, k.nr_bandy,  ka.srednia_bandy
    FROM Kocury k
    JOIN (SELECT nr_bandy, AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) srednia_bandy
        FROM Kocury
        GROUP BY nr_bandy) ka
    ON k.plec='M' AND k.nr_bandy=ka.nr_bandy
    WHERE NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0)<ka.srednia_bandy;
    
--c
SELECT k.imie, NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0) zjada, k.nr_bandy, 
        (SELECT ROUND(AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),2)
            FROM Kocury
            WHERE nr_bandy=k.nr_bandy
            GROUP BY k.nr_bandy) srednia_bandy
    FROM Kocury k
    WHERE k.plec='M' AND
        (SELECT ROUND(AVG(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),2)
            FROM Kocury
            WHERE nr_bandy=k.nr_bandy
            GROUP BY k.nr_bandy)>NVL(k.przydzial_myszy,0)+NVL(k.myszy_extra,0);
            
--Zad30
WITH Naj AS (SELECT imie, w_stadku_od||'<--' "WSTAPIL DO STADKA", 'NAJSTARSZY STAZEM W BANDZIE ' || nazwa " "
        FROM Kocury k JOIN Bandy b
        ON k.nr_bandy=b.nr_bandy
        WHERE w_stadku_od<= ALL (SELECT w_stadku_od FROM Kocury k2 WHERE k2.nr_bandy=k.nr_bandy)
UNION (SELECT imie, w_stadku_od||' <--', 'NAJMLODSZY STAZEM W BANDZIE ' || nazwa
        FROM Kocury k JOIN Bandy b
        ON k.nr_bandy=b.nr_bandy
        WHERE w_stadku_od>= ALL (SELECT w_stadku_od FROM Kocury k2 WHERE k2.nr_bandy=k.nr_bandy)))
SELECT * FROM Naj
UNION (SELECT imie, to_char(w_stadku_od), ' '
    FROM Kocury k
    WHERE NOT EXISTS (SELECT imie FROM Naj
                    WHERE imie=k.imie));
                    
--Zad31 
CREATE OR REPLACE VIEW Bandy_info (nazwa_bandy, sre_spoz, max_spoz, min_spoz, koty, koty_z_dod)
AS SELECT b.nazwa, AVG(NVL(k.przydzial_myszy,0)), MAX(NVL(k.przydzial_myszy,0)),
        MIN(NVL(k.przydzial_myszy,0)), COUNT(k.pseudo), COUNT(k.myszy_extra)
    FROM Bandy b JOIN Kocury k
        ON b.nr_bandy=k.nr_bandy
    GROUP BY k.nr_bandy, b.nazwa;
    
SELECT * FROM Bandy_info;

SELECT pseudo pseudonim, imie, funkcja, przydzial_myszy zjada,
    'od '||min_spoz || ' do '||max_spoz "GRANICE SPOZYCIA", w_stadku_od "LOWI OD"
FROM Kocury K
    LEFT JOIN Bandy b ON   K.nr_bandy=B.nr_bandy
    LEFT JOIN Bandy_info bi ON b.nazwa=bi.nazwa_bandy
WHERE pseudo='&pseudo_kota';

--Zad32
CREATE OR REPLACE VIEW Podw AS (SELECT pseudo
                FROM (SELECT pseudo,  DENSE_RANK() OVER (ORDER BY w_stadku_od) pozycja                     
                        FROM Kocury k JOIN Bandy b
                        ON k.nr_bandy=b.nr_bandy
                        WHERE nazwa ='CZARNI RYCERZE'
                        UNION (SELECT pseudo,  DENSE_RANK() OVER (ORDER BY w_stadku_od) pozycja
                            FROM Kocury k JOIN Bandy b
                            ON k.nr_bandy=b.nr_bandy
                            WHERE nazwa ='LACIACI MYSLIWI'))
                    WHERE pozycja<=3);
                    
SELECT pseudo "Pseudonim", w_stadku_od, plec "Plec", przydzial_myszy "Myszy przed podw.", NVL(myszy_extra,0) "Extra przed podw."
FROM Kocury
WHERE pseudo IN (SELECT * FROM Podw);
  
UPDATE Kocury k
SET k.przydzial_myszy= k.przydzial_myszy+ 0.1*(SELECT MIN(przydzial_myszy) FROM Kocury)
WHERE k.plec='D' AND k.pseudo IN (SELECT * FROM Podw);

UPDATE Kocury 
SET przydzial_myszy= przydzial_myszy+10
WHERE plec='M' AND pseudo IN (SELECT * FROM Podw);

UPDATE Kocury k
SET k.myszy_extra=NVL(k.myszy_extra,0)+(15/100*(SELECT (AVG(NVL(myszy_extra,0)))
                                            FROM Kocury
                                            WHERE Kocury.nr_bandy=k.nr_bandy))
WHERE k.pseudo IN (SELECT * FROM Podw);
                    
SELECT pseudo "Pseudonim", w_stadku_od, plec "Plec", przydzial_myszy "Myszy po podw.", NVL(myszy_extra,0) "Extra po podw."
FROM Kocury
WHERE pseudo IN (SELECT * FROM Podw);
            
--SELECT * FROM Kocury WHERE pseudo='DAMA'; SELECT * FROM Bandy; SELECT * FROM Bandy_Info;
ROLLBACK;

--Zad33
--a
SELECT * FROM
(SELECT DECODE(k.plec, 'D', b.nazwa, ' ') "NAZWA BANDY", 
        DECODE(k.plec, 'D', 'Kotka', 'Kocor') plec, to_char(COUNT(k.pseudo)) ile,
        to_char(SUM(DECODE(funkcja, 'SZEFUNIO',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "SZEFUNIO",
        to_char(SUM(DECODE(funkcja, 'BANDZIOR',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "BANDZIOR",
        to_char(SUM(DECODE(funkcja, 'LOWCZY',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "LOWCZY",
        to_char(SUM(DECODE(funkcja, 'LAPACZ',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "LAPACZ",
        to_char(SUM(DECODE(funkcja, 'KOT',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "KOT",
        to_char(SUM(DECODE(funkcja, 'MILUSIA',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "MILUSIA",
        to_char(SUM(DECODE(funkcja, 'DZIELCZY',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "DZIELCZY",
        to_char(SUM((NVL(przydzial_myszy,0)+NVL(myszy_extra,0)))) "SUMA"
FROM Kocury k JOIN Bandy b
ON k.nr_bandy = b.nr_bandy
GROUP BY b.nazwa, k.plec
ORDER BY b.nazwa
)
UNION ALL
((SELECT '-----------------', '------', '----', '---------', '---------', '---------', '---------', '---------', '---------', '---------', '-------' FROM dual)
UNION ALL
(SELECT 'ZJADA RAZEM', ' ', '  ',
        to_char(SUM(DECODE(funkcja, 'SZEFUNIO',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "SZEFUNIO",
        to_char(SUM(DECODE(funkcja, 'BANDZIOR',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "BANDZIOR",
        to_char(SUM(DECODE(funkcja, 'LOWCZY',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "LOWCZY",
        to_char(SUM(DECODE(funkcja, 'LAPACZ',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "LAPACZ",
        to_char(SUM(DECODE(funkcja, 'KOT',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "KOT",
        to_char(SUM(DECODE(funkcja, 'MILUSIA',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "MILUSIA",
        to_char(SUM(DECODE(funkcja, 'DZIELCZY',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "DZIELCZY",
        to_char(SUM((NVL(przydzial_myszy,0)+NVL(myszy_extra,0)))) "SUMA"
FROM Kocury));


--b

SELECT nazwa_bandy "NAZWA BANDY", plec_ plec, ile, 
        to_char(NVL(szefunio,0)) "SZEFUNIO", to_char(NVL(bandzior,0)) "BANDZIOR", to_char(NVL(lowczy,0)) "LOWCZY", to_char(NVL(lapacz, 0))"LAPACZ" , 
        to_char(NVL(kot,0))"KOT", to_char(NVL(milusia,0)) "MILUSIA", to_char(NVL(dzielczy,0))"DZIELCZY", to_char(suma) "SUMA"
FROM (SELECT *
    FROM(SELECT b.nr_bandy, funkcja, plec,-- b.nazwa nazwa_bandy, 
            DECODE(k.plec, 'D', b.nazwa, ' ') NAZWA_BANDY, 
            DECODE(k.plec, 'D', 'Kotka', 'Kocor') plec_, 
            NVL(przydzial_myszy,0)+NVL(myszy_extra,0) przydzial
            --to_char(COUNT(k.pseudo)) ile,SUM(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) suma 
        FROM Kocury k JOIN Bandy b
        ON k.nr_bandy = b.nr_bandy
        )
    PIVOT
        (SUM (przydzial)
        FOR funkcja
        IN ('SZEFUNIO' szefunio,
            'BANDZIOR' bandzior,
            'LOWCZY' lowczy,
            'LAPACZ' lapacz,
            'KOT' KOT,
            'MILUSIA' milusia,
            'DZIELCZY' dzielczy)
        )
        ORDER BY nr_bandy) sel1
 JOIN (SELECT nr_bandy, to_char(COUNT(pseudo)) ile,SUM(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)) suma,  plec
        FROM Kocury
        GROUP BY nr_bandy, plec) sel2
ON sel1.nr_bandy=sel2.nr_bandy AND sel1.plec=sel2.plec

UNION ALL
(SELECT '-----------------', '------', '----', '---------', '---------', '---------', '---------', '---------', '---------', '---------', '-------' FROM dual)
UNION ALL
(SELECT 'ZJADA RAZEM', ' ', '  ',
        to_char(SUM(DECODE(funkcja, 'SZEFUNIO',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "SZEFUNIO",
        to_char(SUM(DECODE(funkcja, 'BANDZIOR',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "BANDZIOR",
        to_char(SUM(DECODE(funkcja, 'LOWCZY',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "LOWCZY",
        to_char(SUM(DECODE(funkcja, 'LAPACZ',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "LAPACZ",
        to_char(SUM(DECODE(funkcja, 'KOT',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "KOT",
        to_char(SUM(DECODE(funkcja, 'MILUSIA',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "MILUSIA",
        to_char(SUM(DECODE(funkcja, 'DZIELCZY',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) "DZIELCZY",
        to_char(SUM((NVL(przydzial_myszy,0)+NVL(myszy_extra,0)))) "SUMA"
FROM Kocury)
;

 
 