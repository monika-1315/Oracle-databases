ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';
--Zad34
DECLARE
    fun Funkcje.funkcja%TYPE:='&funkcja';
BEGIN
    SELECT funkcja INTO fun
        FROM Kocury
        WHERE funkcja=fun AND ROWNUM<2;
    IF (SQL%FOUND) THEN
        DBMS_OUTPUT.PUT_LINE('Znaleziono koty o funkcji ' || fun);
    ELSE DBMS_OUTPUT.PUT_LINE('Nie znaleziono kotów o takiej funkcji');
    END IF;
EXCEPTION
    WHEN OTHERS
    THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

DECLARE
    fun Funkcje.funkcja%TYPE:='&funkcja';
    cnt NUMBER(2);
BEGIN
    SELECT COUNT(*) INTO cnt
        FROM Kocury
        WHERE funkcja=fun AND ROWNUM<2;
    IF (cnt>0) THEN
        DBMS_OUTPUT.PUT_LINE('Znaleziono koty o funkcji ' || fun);
    ELSE DBMS_OUTPUT.PUT_LINE('Nie znaleziono kotów o takiej funkcji');
    END IF;
EXCEPTION
    WHEN OTHERS
    THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;