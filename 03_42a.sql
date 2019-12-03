CREATE OR REPLACE PACKAGE wirusy AS
    TYPE updates_row IS RECORD (nice_increase BOOLEAN);    
    TYPE updates IS TABLE OF updates_row INDEX BY PLS_INTEGER;
    increases updates;
    trigg BOOLEAN;
END wirusy;
/

CREATE OR REPLACE TRIGGER before_ins_er 
BEFORE UPDATE OF przydzial_myszy ON Kocury 
FOR EACH ROW
WHEN (OLD.funkcja='MILUSIA')
BEGIN
    wirusy.trigg:=true;
    IF :NEW.przydzial_myszy<:OLD.przydzial_myszy THEN 
        :NEW.przydzial_myszy:= :OLD.przydzial_myszy;
   ELSE
    IF :NEW.przydzial_myszy< 1.1*:OLD.przydzial_myszy THEN 
        :NEW.myszy_extra:= :NEW.myszy_extra + 5;
    END IF;
    IF :NEW.przydzial_myszy< 1.1*:OLD.przydzial_myszy THEN 
       wirusy.increases(wirusy.increases.COUNT +1).nice_increase:= false;
    ELSE wirusy.increases(wirusy.increases.COUNT +1).nice_increase:= true;
    END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER after_ins 
AFTER UPDATE OF przydzial_myszy ON Kocury
--WHEN (funkcja='MILUSIA')
BEGIN
IF wirusy.trigg THEN
    wirusy.trigg:=false;
    FOR i in 1..wirusy.increases.COUNT
    LOOP
        IF NOT wirusy.increases(i).nice_increase THEN 
            UPDATE Kocury
                SET przydzial_myszy=0.9*przydzial_myszy
                WHERE pseudo='TYGRYS';
        ELSE UPDATE Kocury
            SET myszy_extra=myszy_extra +5
            WHERE pseudo='TYGRYS';
        END IF;
    END LOOP;
    wirusy.increases.delete;
    END IF;
END;
/

SELECT * FROM Kocury;
--update KOCURY set PRZYDZIAL_MYSZY = (PRZYDZIAL_MYSZY +19) where FUNKCJA='MILUSIA';
UPDATE kocury
SET przydzial_myszy=1.9*przydzial_myszy;
SELECT * FROM Kocury;
ROLLBACK;