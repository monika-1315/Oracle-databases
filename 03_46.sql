CREATE TABLE Wykroczenia(
    uzytkownik VARCHAR2(15), data DATE,  kot VARCHAR2(14),
    operacja VARCHAR2(10));


CREATE OR REPLACE TRIGGER przedzial_myszy
BEFORE INSERT OR UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW
DECLARE
minp Funkcje.min_myszy%TYPE;
maxp Funkcje.max_myszy%TYPE;
uzy Wykroczenia.uzytkownik%TYPE;
dat Wykroczenia.data%TYPE;
op Wykroczenia.operacja%TYPE default 'UPDATE';
pseudo Wykroczenia.kot%TYPE;
BEGIN
    SELECT min_myszy, max_myszy INTO minp, maxp
        FROM Funkcje
        WHERE funkcja=:NEW.funkcja;
    IF :NEW.przydzial_myszy>minp AND :NEW.przydzial_myszy<maxp THEN null;
    ELSE
        uzy:= LOGIN_USER;
        dat:= SYSDATE;
        IF INSERTING THEN op:='INSERT'; END IF;
        pseudo:= :NEW.pseudo;
         INSERT INTO Wykroczenia(uzytkownik, data, kot, operacja)
        VALUES (uzy, dat, pseudo, op);
       
    IF :NEW.przydzial_myszy<minp THEN
        :NEW.przydzial_myszy:=minp;
        DBMS_OUTPUT.PUT_LINE('Przydzial myszy nie mo¿e byæ mniejszy ni¿ minimum!');
    ELSIF :NEW.przydzial_myszy>maxp THEN
        :NEW.przydzial_myszy:=maxp;
        DBMS_OUTPUT.PUT_LINE('Przydzial myszy nie mo¿e byæ wiêkszy od maximum!');
    END IF;
    END IF;
END;
/
UPDATE Kocury
SET przydzial_myszy=0
WHERE pseudo='TYGRYS';
SELECT * FROM Kocury;
SELECT * FROM Wykroczenia;
ROLLBACK;