BEGIN
    FOR kot IN (SELECT pseudo FROM Kocury)
    LOOP
        EXECUTE IMMEDIATE 'CREATE TABLE Myszy_' || kot.pseudo || '(
            nr_myszy NUMBER(7) CONSTRAINT myszy_pk_'|| kot.pseudo || ' PRIMARY KEY,
            waga_myszy NUMBER(3) CONSTRAINT waga_myszy_' || kot.pseudo ||' CHECK (waga_myszy BETWEEN 10 AND 120),
            data_zlowienia DATE CONSTRAINT data_zlowienia_nn_' || kot.pseudo ||' NOT NULL)';
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

BEGIN
    FOR kot IN (SELECT pseudo FROM Kocury)
    LOOP
        EXECUTE IMMEDIATE 'DROP TABLE Myszy_' || kot.pseudo;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

CREATE OR REPLACE PROCEDURE przyjmij_myszy(pseud Kocury.pseudo%TYPE, data DATE)
AS
 TYPE tw IS TABLE OF NUMBER(3);
    tab_wagi tw:=tw();
 TYPE tn IS TABLE OF NUMBER(7);
    tab_nry tn:=tn();
 cnt NUMBER(2);
 brak_kota EXCEPTION;
-- zla_data EXCEPTION;
BEGIN
--    IF data>SYSDATE THEN
--        RAISE zla_data;
--    END IF;
    SELECT COUNT(pseudo) INTO cnt FROM Kocury WHERE pseudo=pseud;
    IF cnt=0 THEN
        RAISE brak_kota;
    END IF;
    EXECUTE IMMEDIATE 'SELECT nr_myszy, waga_myszy FROM Myszy_'||pseud || ' WHERE data_zlowienia= ''' || data || ''''
    BULK COLLECT INTO tab_nry, tab_wagi;
    DBMS_OUTPUT.PUT_LINE(tab_wagi.COUNT);
    FORALL i in 1..tab_wagi.COUNT SAVE EXCEPTIONS
        INSERT INTO Myszy VALUES (tab_nry(i), pseud, NULL, tab_wagi(i), data, NULL);
    
    EXECUTE IMMEDIATE 'DELETE FROM Myszy_'|| pseud || ' WHERE data_zlowienia= ''' || data || '''';
EXCEPTION
    WHEN brak_kota THEN DBMS_OUTPUT.PUT_LINE('Brak kota o podanym pseudonimie');
    --WHEN zla_data THEN DBMS_OUTPUT.PUT_LINE('Bledna data');
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

INSERT INTO Myszy_Lola VALUES(numery_myszy.NEXTVAL,110, '2020-01-21');
BEGIN
    Przyjmij_Myszy('LOLA', '2020-01-21');
END;
/
SELECT * FROM Myszy_Lola;
--DELETE FROM Myszy_Lola WHERE data_zlowienia= '2020-01-21';
SELECT * FROM Myszy WHERE data_zlowienia= '2020-01-21';
