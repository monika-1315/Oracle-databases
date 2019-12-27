ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';


DECLARE
szef REF Kocury_o;
cnt NUMBER(2);
CURSOR koty IS SELECT * FROM Kocury 
                CONNECT BY PRIOR pseudo=szef
                START WITH szef IS NULL;
dyn_sql VARCHAR2(10000);
BEGIN
    FOR kot IN koty
    LOOP
    szef:=NULL;
    SELECT COUNT(*) INTO cnt FROM Kocury2 P WHERE P.pseudo=kot.szef;
    IF (cnt>0) THEN
        SELECT REF(P) INTO szef FROM Kocury2 P WHERE P.pseudo=kot.szef;
    END IF;
      --EXECUTE IMMEDIATE 
      dyn_sql:='DECLARE
szef REF Kocury_o;
cnt NUMBER(2);
BEGIN
szef:=NULL;
    SELECT COUNT(*) INTO cnt FROM Kocury2 P WHERE P.pseudo='''|| kot.szef||''';
    IF (cnt>0) THEN
        SELECT REF(P) INTO szef FROM Kocury2 P WHERE P.pseudo='''|| kot.szef||''';
    END IF;
INSERT INTO Kocury2 VALUES
                    (Kocury_O(''' || kot.imie || ''', ''' || kot.plec || ''', ''' || kot.pseudo || ''', ''' || kot.funkcja 
                    || ''',''' ||kot.w_stadku_od || ''',''' || kot.przydzial_myszy ||''',''' || kot.myszy_extra ||
                        ''',''' || kot.nr_bandy || ''', ' || 'szef' || '));END;';
       DBMS_OUTPUT.PUT_LINE(dyn_sql);
       EXECUTE IMMEDIATE  dyn_sql;
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
