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
    
--Zad19
--a
SELECT k1.imie, k1.funkcja, DEREF(k1.szef).imie "Szef1", DECODE(DEREF(DEREF(k1.szef).szef).imie, null, ' ',DEREF(DEREF(k1.szef).szef).imie) "Szef2", 
DECODE(DEREF(DEREF(DEREF(k1.szef).szef).szef).imie, null, ' ',DEREF(DEREF(DEREF(k1.szef).szef).szef).imie) "Szef3"
    FROM Kocury2 k1
    WHERE k1.funkcja IN ('KOT', 'MILUSIA');
    
--Zad22
SELECT k.funkcja, k.pseudo, sel.lw "Liczba wrogow"
FROM Kocury2 k JOIN
(SELECT COUNT(pseudo) lw, pseudo
    FROM Incydenty
    GROUP BY pseudo) sel
ON k.pseudo = sel.pseudo
WHERE sel.lw>1;

--lista3
--Zad35
DECLARE 
    przydzial Kocury2.przydzial_myszy%TYPE;
    imie Kocury2.imie%TYPE;
    miesiac NUMBER(3);
    spelnia BOOLEAN:=FALSE;
BEGIN
    SELECT K.Dochod_myszowy(), imie, EXTRACT (MONTH FROM w_stadku_od)
    INTO przydzial, imie, miesiac
    FROM Kocury2 K
    WHERE pseudo='&pseudo';
    
    IF (12*przydzial>700) THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' - calkowity roczny przydzial myszy >700'); 
        spelnia:=TRUE;
    END IF;
    IF (imie LIKE '%A%') THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' - imiê zawiera litere A');
        spelnia:=TRUE;
    END IF;
    IF (miesiac=1) THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' - styczeñ jest miesiacem przystapienia do stada');
        spelnia:=TRUE;
    END IF;
    IF(NOT spelnia) THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' - nie odpowiada kryteriom');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota');
    WHEN OTHERS
    THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
--Zad44
CREATE OR REPLACE FUNCTION podatek(pseudonim VARCHAR2) RETURN NUMBER AS
podatek NUMBER(3) DEFAULT 0;
przychody NUMBER(3);
check_cnt NUMBER(2);
funkcja Kocury2.funkcja%TYPE;
BEGIN 
    SELECT K.dochod_myszowy(), K.funkcja INTO przychody, funkcja
        FROM Kocury2 K WHERE K.pseudo=pseudonim;
    podatek:= CEIL(przychody*0.05);
    SELECT COUNT(K.szef.pseudo) INTO check_cnt 
        FROM Kocury2 K WHERE K.szef.pseudo=pseudonim;
    IF (check_cnt=0) THEN
        podatek:= podatek + 2;
    END IF;
    SELECT COUNT(pseudo) INTO check_cnt FROM Incydenty  WHERE pseudo=pseudonim;
    IF (check_cnt=0) THEN
        podatek:= podatek + 1;
    END IF;
    IF (funkcja='MILUSIA') THEN
        podatek:= 1.1*podatek;
    END IF;
    IF (przychody<podatek) THEN
        podatek:=przychody;
    END IF;
    RETURN podatek;
END podatek;
/
DECLARE 
    CURSOR koty IS SELECT pseudo FROM Kocury2;
BEGIN
 DBMS_OUTPUT.PUT_LINE('Podatki:');
    FOR kot in koty
    LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(kot.pseudo,10) || ' ' || podatek(kot.pseudo));
    END LOOP;
END;
/