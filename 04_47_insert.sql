ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

--dodawanie danych kocurow
DECLARE
CURSOR koty IS SELECT * FROM Kocury 
                CONNECT BY PRIOR pseudo=szef
                START WITH szef IS NULL;
dyn_sql VARCHAR2(10000);
BEGIN
    FOR kot IN koty
    LOOP
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
                        ''',''' || kot.nr_bandy || ''', ' || 'szef' || '));
            END;';
      -- DBMS_OUTPUT.PUT_LINE(dyn_sql);
       EXECUTE IMMEDIATE  dyn_sql;
    END LOOP;
    --COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
SELECT K.imie, K.plec, K.pseudo, K.funkcja, K.w_stadku_od, K.przydzial_myszy, K.myszy_extra, K.nr_bandy, K.szef.to_string() szef FROM Kocury2 K;

--dod. danych o incydentach
DECLARE
CURSOR zdarzenia IS SELECT * FROM Wrogowie_kocurow;
dyn_sql VARCHAR2(1000);
BEGIN
    FOR zd IN zdarzenia
    LOOP
      dyn_sql:='DECLARE
            kot REF Kocury_o;
        BEGIN
            SELECT REF(P) INTO kot FROM Kocury2 P WHERE P.pseudo='''|| zd.pseudo||''';
            INSERT INTO Incydenty VALUES
                    (Incydenty_O(''' || zd.pseudo || ''',  kot , ''' || zd.imie_wroga || ''', ''' || zd.data_incydentu
                    || ''',''' || zd.opis_incydentu|| '''));
            END;';
       DBMS_OUTPUT.PUT_LINE(dyn_sql);
       EXECUTE IMMEDIATE  dyn_sql;
    END LOOP;
    --COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
SELECT * FROM Incydenty;

--plebs
DECLARE
CURSOR koty IS SELECT  pseudo
                    FROM (SELECT K.pseudo pseudo, K.Dochod_myszowy() FROM Kocury2 K ORDER BY K.Dochod_myszowy() ASC)
                    WHERE ROWNUM<= (SELECT COUNT(*) FROM Kocury2)/2;
dyn_sql VARCHAR2(1000);
BEGIN
    FOR pl IN koty
    LOOP
      dyn_sql:='DECLARE
            kot REF Kocury_o;
        BEGIN
            SELECT REF(P) INTO kot FROM Kocury2 P WHERE P.pseudo='''|| pl.pseudo||''';
            INSERT INTO Plebs VALUES
                    (Plebs_O(kot, '''|| pl.pseudo || '''));
            END;';
       DBMS_OUTPUT.PUT_LINE(dyn_sql);
       EXECUTE IMMEDIATE  dyn_sql;
    END LOOP;
    --COMMIT;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
SELECT P.pseudo, P.kot.to_string() FROM Plebs P;
SELECT * FROM Elita;


