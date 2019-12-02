--Zad36
DECLARE 
    suma_przydzialow NUMBER(4):=0;
    podwyzki NUMBER(3):=0;
    przydzial Kocury.przydzial_myszy%TYPE DEFAULT 0;
    CURSOR Kocurki IS 
            SELECT imie, przydzial_myszy, max_myszy, pseudo
            FROM Kocury k LEFT JOIN FUNKCJE 
            ON K.funkcja=Funkcje.funkcja ORDER BY przydzial_myszy
            FOR UPDATE OF przydzial_myszy;
BEGIN
    FOR kotek in Kocurki
    LOOP
        suma_przydzialow:= suma_przydzialow+kotek.przydzial_myszy;
    END LOOP;
    <<zew>>LOOP
    
    EXIT WHEN (suma_przydzialow>1050);
        FOR kotek in Kocurki
        LOOP
        IF (kotek.przydzial_myszy!=kotek.max_myszy) THEN
            IF(kotek.przydzial_myszy*1.1>kotek.max_myszy) THEN
                przydzial:=kotek.max_myszy;
            ELSE przydzial:=(kotek.przydzial_myszy*1.1);
            END IF;
            UPDATE Kocury
                SET przydzial_myszy= przydzial
                WHERE pseudo=kotek.pseudo;
            suma_przydzialow:= suma_przydzialow+(przydzial-kotek.przydzial_myszy);
            podwyzki:= podwyzki +1;
            EXIT zew WHEN (suma_przydzialow>1050);
        END IF;
        END LOOP;     
    END LOOP zew;
    DBMS_OUTPUT.PUT_LINE('Calk. przydzial w stadku ' || suma_przydzialow || ' Zmian - ' || podwyzki); 
EXCEPTION
    WHEN OTHERS
    THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

SELECT imie, przydzial_myszy "Myszki po podwyzce" FROM Kocury ORDER BY przydzial_myszy desc;
ROLLBACK;