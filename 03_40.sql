CREATE OR REPLACE PROCEDURE nowe_bandy (nr_band Bandy.nr_bandy%TYPE,nazwab Bandy.nazwa%TYPE, terenb Bandy.teren%TYPE)
AS
    nr NUMBER(1);
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
END;

BEGIN
nowe_bandy(&nr, '&nazwa', '&teren');
END;
/
SELECT * FROM Bandy;
ROLLBACK;