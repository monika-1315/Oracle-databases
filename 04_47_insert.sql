ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';


DECLARE
CURSOR koty IS SELECT * FROM Kocury 
                CONNECT BY PRIOR pseudo=szef
                START WITH szef IS NULL;
--dyn_sql VARCHAR2(10000);
BEGIN
    FOR kot IN koty
    LOOP
      EXECUTE IMMEDIATE 'INSERT INTO Kocury2
                    SELECT ''' || kot.imie || ''', ''' || kot.plec || ''', ''' || kot.pseudo || ''', ''' || kot.funkcja 
                    || ''',''' ||kot.w_stadku_od || ''',''' || kot.przydzial_myszy ||''',''' || kot.myszy_extra ||
                        ''',''' || kot.nr_bandy || ''', REF(K) FROM Kocury2 K WHERE pseudo=''' || kot.szef || '''';
       -- DBMS_OUTPUT.PUT_LINE(dyn_sql);
    END LOOP;
    --COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
SELECT * FROM Kocury2;
SELECT * FROM Plebs;
SELECT * FROM Elita;
