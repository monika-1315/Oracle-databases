DECLARE
    dyn_sql VARCHAR2(10000);
    dyn_plsql VARCHAR2(10000);
    CURSOR funkcje IS SELECT funkcja FROM Funkcje;
BEGIN
    dyn_sql:= 'SELECT * FROM
(SELECT RPAD(DECODE(k.plec, ''D'', b.nazwa, '' ''),17,'' '') "NAZWA BANDY", 
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
(SELECT ''ZJADA RAZEM'', '' '', ''  ''';    
    FOR f IN funkcje
    LOOP
        dyn_sql:= dyn_sql || ',to_char(SUM(DECODE(funkcja, ''' || f.funkcja || ''',(NVL(przydzial_myszy,0)+NVL(myszy_extra,0)),0))) '|| f.funkcja;
    END LOOP;
     dyn_sql:= dyn_sql || ', to_char(SUM((NVL(przydzial_myszy,0)+NVL(myszy_extra,0)))) "SUMA"
FROM Kocury)';
    DBMS_OUTPUT.PUT_LINE(dyn_sql);
    EXECUTE IMMEDIATE dyn_sql;
END;
/
