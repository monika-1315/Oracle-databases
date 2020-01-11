BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE Myszy(
        nr_myszy NUMBER(7) CONSTRAINT myszy_pk PRIMARY KEY,
        lowca VARCHAR2(15) CONSTRAINT m_lowca_fk REFERENCES Kocury(pseudo),
        zjadacz VARCHAR2(15) CONSTRAINT m_zjadacz_fk REFERENCES Kocury(pseudo),
        waga_myszy NUMBER(3) CONSTRAINT waga_myszy_ogr CHECK (waga_myszy BETWEEN 10 AND 120),
        data_zlowienia DATE DEFAULT SYSDATE,
        data_wydania DATE,
         CONSTRAINT daty_popr CHECK (data_zlowienia <= data_wydania))';
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
--DROP TABLE myszy;
CREATE SEQUENCE nr_myszy_myszy;

ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

DECLARE
    pierwszy_dzien DATE := '2004-01-01';
    ost_sroda DATE:= NEXT_DAY(LAST_DAY(pierwszy_dzien) - 7, 'Œroda');
    ost_dzien DATE := '2020-01-19';
    myszy_mies NUMBER(4);
    TYPE tp IS TABLE OF Kocury.pseudo%TYPE;
    tab_pseudo tp:=tp();
    TYPE tm IS TABLE OF NUMBER(3);
    tab_myszy tm:=tm();
    TYPE myszy_rek IS TABLE OF Myszy%ROWTYPE INDEX BY PLS_INTEGER;
    myszki myszy_rek;
    nr_myszy NUMBER(7):=0;
    ind_zjadacza NUMBER(2);
    lw NUMBER;
BEGIN
    <<zew>>LOOP
    EXIT WHEN pierwszy_dzien>=ost_dzien;
        SELECT SUM(NVL(przydzial_myszy,0))+SUM(NVL(myszy_extra,0)) 
            INTO myszy_mies FROM Kocury WHERE w_stadku_od<ost_sroda;
        SELECT pseudo, NVL(przydzial_myszy,0)+NVL(myszy_extra, 0)
            BULK COLLECT INTO tab_pseudo, tab_myszy
            FROM Kocury WHERE w_stadku_od<ost_sroda;
        DBMS_OUTPUT.PUT_LINE(myszy_mies);
        ind_zjadacza:=1;
        myszy_mies:=CEIL(myszy_mies/tab_pseudo.COUNT);
        FOR i IN 1..(myszy_mies*tab_pseudo.COUNT)
        LOOP
        --DBMS_OUTPUT.PUT_LINE(nr_myszy);
            nr_myszy:=nr_myszy+1;
            myszki(nr_myszy).nr_myszy := nr_myszy;
            myszki(nr_myszy).lowca := tab_pseudo(MOD(i,tab_pseudo.COUNT)+1);
            
            IF(tab_myszy(ind_zjadacza)=0) THEN
                ind_zjadacza:=ind_zjadacza+1;
            ELSE tab_myszy(ind_zjadacza):=tab_myszy(ind_zjadacza)-1;
            END IF;
            IF (ind_zjadacza>tab_myszy.COUNT) THEN
                ind_zjadacza:= DBMS_RANDOM.VALUE(1, tab_myszy.COUNT);
            END IF;
            myszki(nr_myszy).zjadacz := tab_pseudo(ind_zjadacza);
            myszki(nr_myszy).waga_myszy := DBMS_RANDOM.VALUE(10,120);
            myszki(nr_myszy).data_zlowienia := pierwszy_dzien+DBMS_RANDOM.VALUE(0,TRUNC(ost_sroda)-TRUNC(pierwszy_dzien)) ;
            IF (ost_sroda != ost_dzien) THEN
                myszki(nr_myszy).data_wydania := ost_sroda;
            END IF;
        END LOOP;
        
        pierwszy_dzien:=ost_sroda+1;
        ost_sroda:= NEXT_DAY(LAST_DAY(pierwszy_dzien) - 7, 'Œroda');
        IF ost_sroda>ost_dzien THEN
            ost_sroda:=ost_dzien;
        END IF;
    END LOOP zew;
        DBMS_OUTPUT.PUT_LINE(myszki.COUNT);
        FORALL i IN 1..myszki.COUNT SAVE EXCEPTIONS 
            INSERT INTO Myszy(nr_myszy, lowca, zjadacz, waga_myszy,data_zlowienia, data_wydania) 
            VALUES(myszki(i).nr_myszy, myszki(i).lowca, myszki(i).zjadacz, myszki(i).waga_myszy, myszki(i).data_zlowienia, myszki(i).data_wydania);
--        lw:=SQL%BULK_EXCEPTIONS.COUNT;
--       FOR i IN 1..lw
--       LOOP
--         DBMS_OUTPUT.PUT_LINE('Blad '||i||': myszka '||
--           SQL%BULK_EXCEPTIONS(i).error_index||' - '||
--           SQLERRM(-SQL%BULK_EXCEPTIONS(i).error_code));
--       END LOOP;

            
--EXCEPTION
--    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/
show errors;
--
--DECLARE
--TYPE tp IS TABLE OF Kocury.pseudo%TYPE;
--    tab_pseudo tp:=tp();
--    BEGIN
--    SELECT pseudo
--            BULK COLLECT INTO tab_pseudo
--            FROM Kocury;-- WHERE w_stadku_od<the_date.LAST_DAY;
--    SELECT pseudo
--            BULK COLLECT INTO tab_pseudo
--            FROM Kocury;-- WHERE w_stadku_od<the_date.LAST_DAY;
--    For i in 1..tab_pseudo.COUNT
--    LOOP
--    DBMS_OUTPUT.PUT_LINE(tab_pseudo(i));
--    END LOOP;
--    END;
--    /

SELECT * FROM Myszy;
DELETE FROM Myszy;