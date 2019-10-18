ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

--Zad1
SELECT imie_wroga, opis_incydentu FROM Wrogowie_kocurow
    WHERE EXTRACT (YEAR FROM data_incydentu)=2009;
    
--Zad2
SELECT imie, funkcja, w_stadku_od "Z NAMI OD" FROM Kocury
    WHERE plec='D' AND w_stadku_od BETWEEN '2005-09-01' AND '2007-07-31' ;

--Zad3
SELECT imie_wroga "WROG", gatunek, stopien_wrogosci "STOPIEN WROGOSCI" FROM Wrogowie
    WHERE lapowka IS NULL
    ORDER BY 3;
    
--Zad4
SELECT imie || ' zwany ' || pseudo || ' (fun. '|| funkcja || ') lowi myszki w bandzie ' || nr_bandy || ' od ' || w_stadku_od
       AS "WSZYSTKO O KOCURACH" FROM Kocury
    WHERE plec='M'
    ORDER BY w_stadku_od DESC, pseudo;
    
--Zad5
SELECT pseudo, 
    REPLACE( SUBSTR(REPLACE(SUBSTR(pseudo, 1 , INSTR(pseudo, 'A')), 'A','#') || SUBSTR(pseudo, INSTR(pseudo, 'A')+1), 1, INSTR(pseudo, 'L')),
    'L','%') || SUBSTR(REPLACE(SUBSTR(pseudo, 1 , INSTR(pseudo, 'A')), 'A','#') || SUBSTR(pseudo, INSTR(pseudo, 'A')+1), INSTR(pseudo, 'L')+1)
        AS "Po wymianie A na # oraz L na %" from kocury
    WHERE pseudo LIKE '%A%' and pseudo LIKE '%L%';
    
--Zad6
SELECT imie, w_stadku_od AS "W stadku",  CEIL(przydzial_myszy*0.9) AS "Zjadal", Add_Months(w_stadku_od, 6) AS "Podwyzka", przydzial_myszy AS "Zjada"  
    FROM kocury
    WHERE Months_Between(SYSDATE, w_stadku_od)>=120 AND EXTRACT (MONTH FROM w_stadku_od) BETWEEN 3 AND 9;

--Zad7
SELECT imie, 3*przydzial_myszy AS "MYSZY KWARTALNIE", 3*NVL(myszy_extra, 0) AS "KWARTALNE DODATKI" FROM kocury
    WHERE przydzial_myszy>2*NVL(myszy_extra,0) AND przydzial_myszy>=55;
    
--Zad8
SELECT imie, CASE  
                WHEN 12*(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) = 660 THEN 'Limit'
                WHEN 12*(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)) < 660 THEN 'Ponizej 660'
                ELSE TO_CHAR(12*(NVL(przydzial_myszy,0) + NVL(myszy_extra,0)))
                END
                AS "Zjada rocznie" FROM kocury;

--Zad9
--24 wrzeœnia
SELECT pseudo, w_stadku_od "W STADKU", 
    CASE 
        WHEN EXTRACT(DAY FROM w_stadku_od)<=15 THEN NEXT_DAY(LAST_DAY('2019-09-24') - 7, 'Œroda')
        ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2019-09-24',1))-7, 'Œroda')
        END
        AS "WYPLATA"
    FROM kocury;
--26 wrzeœnia
SELECT pseudo, w_stadku_od "W STADKU", 
    CASE 
        WHEN EXTRACT(DAY FROM w_stadku_od)<=15 
            THEN  CASE
            WHEN NEXT_DAY(LAST_DAY('2019-09-26') - 7, 'Œroda') < '2019-09-26' THEN NEXT_DAY(LAST_DAY(ADD_MONTHS('2019-09-26',1))-7, 'Œroda')
            ELSE NEXT_DAY(LAST_DAY('2019-09-26') - 7, 'Œroda')
            END
        ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS('2019-09-26',1))-7, 'Œroda')
        END
        AS "WYPLATA"
    FROM kocury;
--data bie¿aca
SELECT pseudo, w_stadku_od "W STADKU", 
    CASE 
        WHEN EXTRACT(DAY FROM w_stadku_od)<=15 
            THEN  CASE
            WHEN NEXT_DAY(LAST_DAY(SYSDATE) - 7, 'Œroda') < SYSDATE THEN NEXT_DAY(LAST_DAY(ADD_MONTHS(SYSDATE,1))-7, 'Œroda')
            ELSE NEXT_DAY(LAST_DAY(SYSDATE) - 7, 'Œroda')
            END
        ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS(SYSDATE,1))-7, 'Œroda')
        END
        AS "WYPLATA"
    FROM kocury;
    
    
--Zad10
--atr.pseudo
SELECT pseudo ||' - ' || 
DECODE(COUNT (*), 1, 'Unikalny', 'Nieunikalny') 
AS "Unikalnosc atr. PSEUDO" 
    FROM Kocury
    GROUP BY pseudo;
--atr.szef
SELECT szef ||' - ' || 
DECODE(COUNT (*), 1, 'Unikalny', 'Nieunikalny') 
AS "Unikalnosc atr. SZEF" 
    FROM Kocury
    WHERE szef IS NOT NULL
    GROUP BY szef;
    
--Zad11
SELECT pseudo "Pseudonim", COUNT(*) "Liczba wrogow"
    FROM wrogowie_kocurow
    GROUP BY pseudo
    HAVING COUNT(*)>=2;
    
--Zad12
SELECT 'Liczba kotow=' " ", COUNT(*) "  ", 'lowi jako' "   ", funkcja "    ", 'i zjada max.' "     ",
    MAX(NVL(myszy_extra,0)+NVL(przydzial_myszy,0))"      ", 'myszy miesiecznie' "       "
    FROM Kocury
    WHERE funkcja!= 'SZEFUNIO' AND plec IN ('D', null)
    GROUP BY funkcja
    HAVING MAX(NVL(myszy_extra,0)+NVL(przydzial_myszy,0))>50;
    
--Zad13
SELECT nr_bandy "Nr bandy", plec "Plec", MIN(przydzial_myszy) "Minimalny przydzial" FROM Kocury
    GROUP BY nr_bandy, plec;
    
--Zad14
SELECT level "Poziom", pseudo "Pseudonim", funkcja "Funkcja", nr_bandy "Nr bandy"
    FROM Kocury
    WHERE plec='M' 
    CONNECT BY  PRIOR pseudo=szef 
    START WITH funkcja = 'BANDZIOR';

