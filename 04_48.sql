--nowe tabele
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
/

SELECT * FROM ELITA_R;
SELECT * FROM PLEBS_R;

CREATE TABLE KONTO_MYSZY
(nr_myszy NUMBER(5) CONSTRAINT konto_nr_pk PRIMARY KEY,
 data_wprowadzenia DATE,
 data_usuniecia DATE,
 wlasciciel VARCHAR(15) CONSTRAINT konto_wl_fk REFERENCES Elita_r(pseudo),
    CONSTRAINT konto_myszy_daty CHECK(data_wprowadzenia<=data_usuniecia));
    
CREATE SEQUENCE nry_myszy_konto;

DECLARE
    TYPE t_ps IS TABLE OF VARCHAR2(15);
    koty1 t_ps:=t_ps();
    koty2 t_ps:=t_ps();
BEGIN
    SELECT pseudo
    BULK COLLECT INTO koty1 FROM Elita_r;
    SELECT e.pseudo 
    BULK COLLECT INTO koty2 FROM Elita_r e JOIN Kocury k ON e.pseudo=k.pseudo WHERE k.przydzial_myszy>50;
    
    FORALL i in 1..koty1.COUNT SAVE EXCEPTIONS
    INSERT INTO Konto_myszy VALUES (nry_myszy_konto.NEXTVAL, SYSDATE, null, koty1(i));   
    FORALL i in 1..koty2.COUNT SAVE EXCEPTIONS
    INSERT INTO Konto_myszy VALUES (nry_myszy_konto.NEXTVAL, SYSDATE, null, koty2(i));
END;
/
SELECT * FROM Konto_myszy;

---------------------------------------------------------------
--tworzenie widoków obiektowych
CREATE OR REPLACE FORCE VIEW Kocury_p OF Kocury_o
WITH OBJECT IDENTIFIER (pseudo) AS
    SELECT pseudo, plec, pseudo, funkcja, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy, 
    MAKE_REF(Kocury_p, pseudo) szef
    FROM Kocury;
    
SELECT * FROM Kocury_p;

CREATE OR REPLACE VIEW Plebs_p OF Plebs_o
WITH OBJECT IDENTIFIER (pseudo) AS
    SELECT MAKE_REF(Kocury_p, pseudo) kot, pseudo
    FROM Plebs_r;
SELECT * FROM Plebs_p;

CREATE OR REPLACE VIEW ELita_p OF Elita_O
WITH OBJECT IDENTIFIER (pseudo) AS
    SELECT MAKE_REF(Kocury_p, pseudo) kott, MAKE_REF(Plebs_p, sluga) sluga, pseudo
    FROM Elita_r;
SELECT * FROM Elita_p;

CREATE OR REPLACE VIEW Konto_myszy_p OF Konto_myszy_o
WITH OBJECT IDENTIFIER (nr_myszy) AS
    SELECT nr_myszy, data_wprowadzenia, data_usuniecia, MAKE_REF(Elita_p, wlasciciel) wlasciciel
    FROM Konto_myszy;
SELECT nr_myszy, DEREF(wlasciciel).to_string() FROM Konto_myszy_p;

CREATE OR REPLACE VIEW Incydenty_p OF Incydenty_o 
WITH OBJECT IDENTIFIER(pseudo, imie_wroga) AS 
    SELECT pseudo, MAKE_REF(Kocury_p, pseudo) kot, imie_wroga, data_incydentu, opis_incydentu 
    FROM Wrogowie_kocurow;
SELECT * FROM Incydenty_p;