DECLARE
    dyn_sql VARCHAR2(10000);
    dyn_plsql VARCHAR2(10000);
    naglowek VARCHAR2(500);
    CURSOR funkcje IS SELECT funkcja FROM Funkcje;
BEGIN
    dyn_sql:= 'SELECT * FROM
(SELECT RPAD(DECODE(k.plec, ''D'', b.nazwa, '' ''),17,'' '') NAZWA_BANDY, 
        DECODE(k.plec, ''D'', ''Kotka'', ''Kocor'') plec, to_char(COUNT(k.pseudo)) ile';
    FOR f IN funkcje
    LOOP
        dyn_sql:= dyn_sql || ',to_char(LPAD(SUM(DECODE(funkcja, ''' || f.funkcja || ''',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0)), 9,'' '')) '|| f.funkcja;
    END LOOP;
    
    dyn_sql:= dyn_sql || ',to_char(SUM((NVL(przydzial_myszy,0)+NVL(myszy_extra,0)))) "SUMA"
FROM Kocury k JOIN Bandy b
ON k.nr_bandy = b.nr_bandy
GROUP BY b.nazwa, k.plec
ORDER BY b.nazwa
)
UNION ALL
(SELECT ''ZJADA RAZEM'', ''           '', ''  ''';    
    FOR f IN funkcje
    LOOP
        dyn_sql:= dyn_sql || ',to_char(LPAD(SUM(DECODE(funkcja, ''' || f.funkcja || ''',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0)), 9,'' '')) '|| f.funkcja;
    END LOOP;
     dyn_sql:= dyn_sql || ', to_char(SUM((NVL(przydzial_myszy,0)+NVL(myszy_extra,0)))) "SUMA"
FROM Kocury)';
    naglowek:= 'NAZWA BANDY      PLEC  ILE ';
    FOR f IN funkcje
    LOOP
        naglowek:=naglowek || LPAD(f.funkcja, 9, ' ');
    END LOOP;
    naglowek:=naglowek || '  SUMA';
    DBMS_OUTPUT.PUT_LINE(naglowek);
    --EXECUTE IMMEDIATE dyn_sql;
    dyn_plsql:= 'DECLARE
    CURSOR raporty IS ' ||  dyn_sql ||  ';
        BEGIN
        FOR row in raporty
        LOOP
            DBMS_OUTPUT.PUT_LINE(row.nazwa_bandy || row.plec || LPAD(row.ile, 4, '' '') ';
        FOR f IN funkcje
    LOOP
        dyn_plsql:= dyn_plsql || ' || LPAD(row.' || f.funkcja || ', 9, '' '')';
    END LOOP;
        dyn_plsql:=dyn_plsql || ' || LPAD(row.suma,7, '' ''));
        END LOOP;
    END;';
    --DBMS_OUTPUT.PUT_LINE(dyn_plsql);
    EXECUTE IMMEDIATE dyn_plsql;
END;
/
