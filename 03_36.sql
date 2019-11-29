--Zad36
DECLARE 
    suma_przydzialow NUMBER(4):=0;
    podwyzki NUMBER(1):=0;
    CURSOR Kocurki IS 
            SELECT imie, przydzial_myszy, max_myszy
            FROM Kocury k LEFT JOIN FUNKCJE 
            ON K.funkcja=Funkcje.funkcja ORDER BY przydzial_myszy ASC;
BEGIN
    OPEN Kocurki;
    <<zew>>LOOP
        FOR kotek in Kocurki
        LOOP
            IF(kotek.przydzial_myszy*1.1>kotek.max_myszy) THEN
                kotek.przydzial_myszy:=kotek.max_myszy;
            ELSE kotek.przydzial_myszy:= (kotek.przydzial_myszy*1.1);
            END IF;
            suma_przydzialow:= suma_przydzialow+kotek.przydzial_myszy;
            podwyzki:= podwyzki +1;
            EXIT zew WHEN (suma_przydzialow>1050);
        END LOOP;
    END LOOP zew;
    DBMS_OUTPUT.PUT_LINE('Calk. przydzial w stadku ' || suma_przydzialow || ' Zmian - ' || podwyzki); 
END;