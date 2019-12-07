CREATE OR REPLACE TRIGGER przedzial_myszy
BEFORE UPDATE OF przydzial_myszy ON Kocury
FOR EACH ROW
DECLARE
minp Funkcje.min_myszy%TYPE;
maxp Funkcje.max_myszy%TYPE;
BEGIN
    SELECT min_myszy, max_myszy INTO minp, maxp
        FROM Funkcje
        WHERE funkcja=:NEW.funkcja;
    IF :NEW.przydzial_myszy<minp THEN
        :NEW.przydzial_myszy:=minp;
        DBMS_OUTPUT.PUT_LINE('Przydzial myszy nie mo¿e byæ mniejszy ni¿ minimum!');
    ELSIF :NEW.przydzial_myszy>maxp THEN
        :NEW.przydzial_myszy:=maxp;
        DBMS_OUTPUT.PUT_LINE('Przydzial myszy nie mo¿e byæ wiêkszy od maximum!');
    END IF;
END;
/
UPDATE Kocury
SET przydzial_myszy=0
WHERE pseudo='TYGRYS';
SELECT * FROM Kocury;
ROLLBACK;