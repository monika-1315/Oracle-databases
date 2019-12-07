CREATE OR REPLACE PACKAGE koty_funkcje AS
PROCEDURE nowe_bandy;
FUNCTION podatek(pseudonim VARCHAR2) RETURN NUMBER;
END koty_funkcje;
/
CREATE OR REPLACE PACKAGE BODY koty_funkcje AS
PROCEDURE nowe_bandy IS
nr_band Bandy.nr_bandy%TYPE := &numer_bandy;
    nr NUMBER(1);
    nazwab Bandy.nazwa%TYPE := '&nazwa_bandy';
    terenb Bandy.teren%TYPE := '&teren_polowan';
    nr_popr BOOLEAN:=false;
    nazw_popr BOOLEAN:=false;
    ter_popr BOOLEAN:=false;
    nr_lt_0 EXCEPTION;
    istnieje EXCEPTION;
    komunikat VARCHAR2(100):='';
BEGIN
    IF nr_band<=0 THEN RAISE nr_lt_0;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE nr_band=b.nr_bandy;
    IF nr=0 THEN nr_popr:=true;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE nazwab=b.nazwa;
    IF nr=0 THEN nazw_popr:=true;
    END IF;
    SELECT COUNT(*) INTO nr FROM Bandy b WHERE terenb=b.teren;
    IF nr=0 THEN ter_popr:=true;
    END IF;
    IF NOT(nr_popr AND nazw_popr AND ter_popr) THEN
         RAISE istnieje;
    END IF;
        INSERT INTO Bandy(nr_bandy, nazwa, teren) VALUES (nr_band, nazwab, terenb);
EXCEPTION
    WHEN nr_lt_0 THEN
        DBMS_OUTPUT.PUT_LINE('Numer bandy musi byæ wiêkszy od 0!');
    WHEN istnieje THEN 
        IF NOT nr_popr THEN komunikat:= komunikat || TO_CHAR(nr_band) || ' '; END IF;
        IF NOT nazw_popr THEN komunikat:= komunikat || nazwab || ' '; END IF;
        IF NOT nazw_popr THEN komunikat:= komunikat || terenb || ' '; END IF;
        komunikat:= komunikat || ': juz istnieje';
        DBMS_OUTPUT.PUT_LINE(komunikat);
    WHEN OTHERS
        THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END nowe_bandy;
FUNCTION podatek(pseudonim VARCHAR2) RETURN NUMBER IS
podatek NUMBER(3) DEFAULT 0;
przychody NUMBER(3);
check_cnt NUMBER(2);
funkcja Kocury.funkcja%TYPE;
BEGIN 
    SELECT NVL(przydzial_myszy,0)+NVL(myszy_extra,0), funkcja INTO przychody, funkcja
        FROM Kocury WHERE Kocury.pseudo=pseudonim;
    podatek:= CEIL(przychody*0.05);
    SELECT COUNT(szef) INTO check_cnt 
        FROM Kocury WHERE szef=pseudonim;
    IF (check_cnt=0) THEN
        podatek:= podatek + 2;
    END IF;
    SELECT COUNT(pseudo) INTO check_cnt FROM Wrogowie_kocurow WHERE pseudo=pseudonim;
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
END koty_funkcje;
/
DECLARE 
    CURSOR koty IS SELECT pseudo FROM Kocury;
BEGIN
 DBMS_OUTPUT.PUT_LINE('Podatki:');
    FOR kot in koty
    LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(kot.pseudo,10) || ' ' || koty_funkcje.podatek(kot.pseudo));
    END LOOP;
END;
/