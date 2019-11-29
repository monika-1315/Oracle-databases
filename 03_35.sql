
--Zad35
DECLARE 
    przydzial Kocury.przydzial_myszy%TYPE;
    imie Kocury.imie%TYPE;
    miesiac NUMBER(3);
    spelnia BOOLEAN:=FALSE;
BEGIN
    SELECT (NVL(przydzial_myszy,0)+NVL(myszy_extra,0)), imie, EXTRACT (MONTH FROM w_stadku_od)
    INTO przydzial, imie, miesiac
    FROM Kocury
    WHERE pseudo='&pseudo';
    
    IF (12*przydzial>700) THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' - calkowity roczny przydzial myszy >700'); 
        spelnia:=TRUE;
    END IF;
    IF (imie LIKE '%A%') THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' - imiê zawiera litere A');
        spelnia:=TRUE;
    END IF;
    IF (miesiac=1) THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' - styczeñ jest miesiacem przystapienia do stada');
        spelnia:=TRUE;
    END IF;
    IF(NOT spelnia) THEN
        DBMS_OUTPUT.PUT_LINE(imie || ' - nie odpowiada kryteriom');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota');
    WHEN OTHERS
    THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;