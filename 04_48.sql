--nowe tabele
CREATE TABLE PLEBS_R(
    pseudo VARCHAR2(15) CONSTRAINT plebs_pseodo_pk PRIMARY KEY,
        CONSTRAINT plebs_rel_fk FOREIGN KEY(pseudo) REFERENCES Kocury(pseudo));

CREATE TABLE ELITA_R(
    pseudo VARCHAR2(15) CONSTRAINT elita_pseodo_pk PRIMARY KEY,
    sluga VARCHAR(15) CONSTRAINT sluga_fk REFERENCES Plebs_r(pseudo),
        CONSTRAINT elita_rel_fk FOREIGN KEY(pseudo) REFERENCES Kocury(pseudo));

DECLARE 
    TYPE t_ps IS TABLE OF VARCHAR2(15);
    plebs t_ps:=t_ps();
    elita t_ps:=t_ps();
BEGIN
    SELECT pseudo 
    BULK COLLECT INTO elita
    FROM (SELECT pseudo FROM Kocury ORDER BY NVL(myszy_extra,0)+NVL(przydzial_myszy, 0) DESC)
                    WHERE ROWNUM<= (SELECT COUNT(*) FROM Kocury)/2;
    SELECT pseudo 
    BULK COLLECT INTO plebs
    FROM (SELECT pseudo FROM Kocury ORDER BY NVL(myszy_extra,0)+NVL(przydzial_myszy, 0) ASC)
                    WHERE ROWNUM<= (SELECT COUNT(*) FROM Kocury)/2;
                    
    FORALL i IN 1..plebs.COUNT SAVE EXCEPTIONS
    INSERT INTO Plebs_r VALUES (plebs(i));
    
    FORALL i IN 1..plebs.COUNT SAVE EXCEPTIONS
    INSERT INTO Elita_r VALUES (elita(i), plebs(i));
END;
/

SELECT * FROM ELITA_R;
SELECT * FROM PLEBS_R;

CREATE TABLE KONTO_MYSZY
(nr_myszy NUMBER(5) CONSTRAINT konto_nr_pk PRIMARY KEY,
 data_wprowadzenia DATE,
 data_usuniecia DATE,
 wlasciciel VARCHAR(15) CONSTRAINT konto_wl_fk REFERENCES Elita_r(pseudo),
    CONSTRAINT konto_myszy_daty CHECK(data_wprowadzenia<=data_usuniecia));
    
CREATE SEQUENCE nry_myszy_konto;

DECLARE
    TYPE t_ps IS TABLE OF VARCHAR2(15);
    koty1 t_ps:=t_ps();
    koty2 t_ps:=t_ps();
BEGIN
    SELECT pseudo
    BULK COLLECT INTO koty1 FROM Elita_r;
    SELECT e.pseudo 
    BULK COLLECT INTO koty2 FROM Elita_r e JOIN Kocury k ON e.pseudo=k.pseudo WHERE k.przydzial_myszy>50;
    
    FORALL i in 1..koty1.COUNT SAVE EXCEPTIONS
    INSERT INTO Konto_myszy VALUES (nry_myszy_konto.NEXTVAL, SYSDATE, null, koty1(i));   
    FORALL i in 1..koty2.COUNT SAVE EXCEPTIONS
    INSERT INTO Konto_myszy VALUES (nry_myszy_konto.NEXTVAL, SYSDATE, null, koty2(i));
END;
/
SELECT * FROM Konto_myszy;

---------------------------------------------------------------
--tworzenie widoków obiektowych
CREATE OR REPLACE FORCE VIEW Kocury_p OF Kocury_o
WITH OBJECT IDENTIFIER (pseudo) AS
    SELECT pseudo, plec, pseudo, funkcja, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy, 
    MAKE_REF(Kocury_p, szef) szef
    FROM Kocury;
    
SELECT * FROM Kocury_p;

CREATE OR REPLACE VIEW Plebs_p OF Plebs_o
WITH OBJECT IDENTIFIER (pseudo) AS
    SELECT MAKE_REF(Kocury_p, pseudo) kot, pseudo
    FROM Plebs_r;
SELECT * FROM Plebs_p;

CREATE OR REPLACE VIEW ELita_p OF Elita_O
WITH OBJECT IDENTIFIER (pseudo) AS
    SELECT MAKE_REF(Kocury_p, pseudo) kott, MAKE_REF(Plebs_p, sluga) sluga, pseudo
    FROM Elita_r;
SELECT * FROM Elita_p;

CREATE OR REPLACE VIEW Konto_myszy_p OF Konto_myszy_o
WITH OBJECT IDENTIFIER (nr_myszy) AS
    SELECT nr_myszy, data_wprowadzenia, data_usuniecia, MAKE_REF(Elita_p, wlasciciel) wlasciciel
    FROM Konto_myszy;
SELECT nr_myszy, DEREF(wlasciciel).to_string() FROM Konto_myszy_p;

CREATE OR REPLACE VIEW Incydenty_p OF Incydenty_o 
WITH OBJECT IDENTIFIER(pseudo, imie_wroga) AS 
    SELECT pseudo, MAKE_REF(Kocury_p, pseudo) kot, imie_wroga, data_incydentu, opis_incydentu 
    FROM Wrogowie_kocurow;
SELECT * FROM Incydenty_p;

--zadania
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

SELECT  pseudo
 FROM (SELECT K.pseudo pseudo FROM Kocury_p K ORDER BY K.Dochod_myszowy() ASC)
         WHERE ROWNUM<= (SELECT COUNT(*) FROM Kocury_p)/2;
         
SELECT E.kot.pseudo, E.sluga.pseudo, E.pseudo, E.kot.dochod_myszowy() FROM Elita_p E;

SELECT K.nr_bandy, COUNT(K.pseudo) ilosc_kotow 
    FROM Kocury_p K
    GROUP BY K.nr_bandy
    ORDER BY K.nr_bandy;
    
SELECT K.kot.nr_bandy nr_bandy, COUNT(K.pseudo) ilosc_kotow_w_elicie 
    FROM Elita_p K
    GROUP BY K.kot.nr_bandy
    ORDER BY K.kot.nr_bandy;
    
--lista 2    
--Zad19
--a
SELECT k1.imie, k1.funkcja, DEREF(k1.szef).imie "Szef1", DECODE(DEREF(DEREF(k1.szef).szef).imie, null, ' ',DEREF(DEREF(k1.szef).szef).imie) "Szef2", 
DECODE(DEREF(DEREF(DEREF(k1.szef).szef).szef).imie, null, ' ',DEREF(DEREF(DEREF(k1.szef).szef).szef).imie) "Szef3"
    FROM Kocury_p k1
    WHERE k1.funkcja IN ('KOT', 'MILUSIA');
    
--Zad22
SELECT k.funkcja, k.pseudo, sel.lw "Liczba wrogow"
FROM Kocury_p k JOIN
(SELECT COUNT(pseudo) lw, pseudo
    FROM Incydenty_p
    GROUP BY pseudo) sel
ON k.pseudo = sel.pseudo
WHERE sel.lw>1;

--lista3
--Zad35
DECLARE 
    przydzial Kocury_p.przydzial_myszy%TYPE;
    imie Kocury_p.imie%TYPE;
    miesiac NUMBER(3);
    spelnia BOOLEAN:=FALSE;
BEGIN
    SELECT K.Dochod_myszowy(), imie, EXTRACT (MONTH FROM w_stadku_od)
    INTO przydzial, imie, miesiac
    FROM Kocury_p K
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
funkcja Kocury_p.funkcja%TYPE;
BEGIN 
    SELECT K.dochod_myszowy(), K.funkcja INTO przychody, funkcja
        FROM Kocury_p K WHERE K.pseudo=pseudonim;
    podatek:= CEIL(przychody*0.05);
    SELECT COUNT(K.szef.pseudo) INTO check_cnt 
        FROM Kocury_p K WHERE K.szef.pseudo=pseudonim;
    IF (check_cnt=0) THEN
        podatek:= podatek + 2;
    END IF;
    SELECT COUNT(pseudo) INTO check_cnt FROM Incydenty_p  WHERE pseudo=pseudonim;
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
    CURSOR koty IS SELECT pseudo FROM Kocury_p;
BEGIN
 DBMS_OUTPUT.PUT_LINE('Podatki:');
    FOR kot in koty
    LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(kot.pseudo,10) || ' ' || podatek(kot.pseudo));
    END LOOP;
END;
/