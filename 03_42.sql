CREATE OR REPLACE TRIGGER wirus
FOR UPDATE OF przydzial_myszy ON Kocury 
WHEN (OLD.funkcja='MILUSIA')
COMPOUND TRIGGER 
TYPE updates_row IS RECORD (nice_increase BOOLEAN);    
TYPE updates IS TABLE OF updates_row INDEX BY PLS_INTEGER;
increases updates;

BEFORE EACH ROW IS
BEGIN
    IF :NEW.przydzial_myszy<:OLD.przydzial_myszy THEN 
        :NEW.przydzial_myszy:= :OLD.przydzial_myszy;
   ELSE
    IF :NEW.przydzial_myszy< 1.1*:OLD.przydzial_myszy THEN 
        :NEW.myszy_extra:= :NEW.myszy_extra + 5;
    END IF;
    IF :NEW.przydzial_myszy< 1.1*:OLD.przydzial_myszy THEN 
       increases(increases.COUNT +1).nice_increase:= false;
    ELSE increases(increases.COUNT +1).nice_increase:= true;
    END IF;
    END IF;
END BEFORE EACH ROW;
AFTER STATEMENT IS
BEGIN
    FOR i in 1..increases.COUNT
    LOOP
        IF NOT increases(i).nice_increase THEN 
            UPDATE Kocury
                SET przydzial_myszy=0.9*przydzial_myszy
                WHERE pseudo='TYGRYS';
        ELSE UPDATE Kocury
            SET myszy_extra=myszy_extra +5
            WHERE pseudo='TYGRYS';
        END IF;
    END LOOP;
END AFTER STATEMENT;
END wirus;
/


SELECT * FROM Kocury;
UPDATE kocury
SET przydzial_myszy=1.05*przydzial_myszy;
SELECT * FROM Kocury;
ROLLBACK;

DROP TRIGGER wirus;