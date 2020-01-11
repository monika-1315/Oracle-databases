CREATE TABLE PLEBS_R(
    pseudo VARCHAR2(15) CONSTRAINT plebs_pseodo_pk PRIMARY KEY,
        CONSTRAINT plebs_rel_fk FOREIGN KEY(pseudo) REFERENCES Kocury(pseudo));

CREATE TABLE ELITA_R(
    pseudo VARCHAR2(15) CONSTRAINT elita_pseodo_pk PRIMARY KEY,
    sluga VARCHAR(15) CONSTRAINT sluga_fk REFERENCES Plebs_r(pseudo),
        CONSTRAINT elita_rel_fk FOREIGN KEY(pseudo) REFERENCES Kocury(pseudo));

DECLARE 
    TYPE t_ps IS TABLE OF VARCHAR2(15);
    plebs t_ps:=t_ps();
    elita t_ps:=t_ps();
BEGIN
    SELECT pseudo 
    BULK COLLECT INTO elita
    FROM (SELECT pseudo FROM Kocury ORDER BY NVL(myszy_extra,0)+NVL(przydzial_myszy, 0) DESC)
                    WHERE ROWNUM<= (SELECT COUNT(*) FROM Kocury)/2;
    SELECT pseudo 
    BULK COLLECT INTO plebs
    FROM (SELECT pseudo FROM Kocury ORDER BY NVL(myszy_extra,0)+NVL(przydzial_myszy, 0) ASC)
                    WHERE ROWNUM<= (SELECT COUNT(*) FROM Kocury)/2;
                    
    FORALL i IN 1..plebs.COUNT SAVE EXCEPTIONS
    INSERT INTO Plebs_r VALUES (plebs(i));
    
    FORALL i IN 1..plebs.COUNT SAVE EXCEPTIONS
    INSERT INTO Elita_r VALUES (elita(i), plebs(i));
END;