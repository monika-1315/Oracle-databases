CREATE TABLE Dodatki_extra(
    pseudo VARCHAR2(15) CONSTRAINT de_ps_fk REFERENCES Kocury(pseudo),
    dod_extra NUMBER(3));
    
CREATE OR REPLACE PACKAGE kary AS
    TYPE pseudo_row IS RECORD (pseudo VARCHAR2(15));    
    TYPE pseudo IS TABLE OF pseudo_row INDEX BY PLS_INTEGER;
    milusie pseudo; 
    PROCEDURE wez_milusie;
 END kary;
 /
CREATE OR REPLACE PACKAGE BODY kary AS
PROCEDURE wez_milusie IS
 BEGIN
    kary.milusie.delete;
    FOR kot IN (SELECT pseudo FROM Kocury WHERE funkcja='MILUSIA')
    LOOP
        kary.milusie(kary.milusie.COUNT +1).pseudo:= 
            kot.pseudo;
    END LOOP;
    END wez_milusie;
END kary;
/
CREATE OR REPLACE TRIGGER milusie
AFTER INSERT ON Kocury
FOR EACH ROW
WHEN (NEW.funkcja='MILUSIA')
BEGIN
   Kary.wez_milusie();
END;
/
--DROP trigger kara_milus;
CREATE OR REPLACE TRIGGER kara_milus
AFTER UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW
--FOLLOWS wirus
WHEN (OLD.funkcja='MILUSIA' AND OLD.przydzial_myszy<NEW.przydzial_myszy)
DECLARE
    dyn_sql VARCHAR2(500);
    --CURSOR milusie IS SELECT pseudo FROM Kocury WHERE funkcja='MILUSIA';
BEGIN
    IF (LOGIN_USER != 'TYGRYS') THEN
        dyn_sql:= 'INSERT ALL';
        FOR i IN 1..kary.milusie.COUNT
        LOOP
        dyn_sql:=dyn_sql || ' INTO Dodatki_extra(pseudo, dod_extra) VALUES ('''
            || kary.milusie(i).pseudo || ''', -10)';
        END LOOP;
        dyn_sql:= dyn_sql || ' SELECT * from dual';
        DBMS_OUTPUT.PUT_LINE(dyn_sql);
        EXECUTE IMMEDIATE dyn_sql;
    END IF;
END;
/
SELECT * FROM Kocury;
--update KOCURY set PRZYDZIAL_MYSZY = (PRZYDZIAL_MYSZY +19) where FUNKCJA='MILUSIA';
UPDATE kocury SET przydzial_myszy=1.9*przydzial_myszy;
SELECT * FROM Dodatki_extra;
SELECT * FROM Kocury;
ROLLBACK;
