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

---------------------------------------------------------------------------------------------------------------
----typy
CREATE OR REPLACE TYPE KOCURY_T AS OBJECT
  (imie VARCHAR2(15),
   plec VARCHAR2(1),
   pseudo VARCHAR2(15), 
   funkcja VARCHAR2(10),
   szef VARCHAR2(1),
   w_stadku_od DATE,
   przydzial_myszy NUMBER(3),
   myszy_extra NUMBER(3),
   nr_bandy NUMBER(2),
  MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2,
  MEMBER FUNCTION O_plci RETURN VARCHAR2,
  MEMBER FUNCTION Dochod_myszowy RETURN NUMBER)
/
CREATE OR REPLACE TYPE BODY KOCURY_T AS
    MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2 IS
     BEGIN
        RETURN imie || ', ' || O_plci() || ', pseudo:' || pseudo || ' funkcja:'||funkcja ||', zjada:'||SELF.Dochod_myszowy();
    END;
   MEMBER FUNCTION O_plci RETURN VARCHAR2 IS
          BEGIN
           RETURN CASE NVL(plec,'N')
                   WHEN 'M' THEN 'Kocur'
                   WHEN 'D' THEN'Kotka'
                   WHEN 'N' THEN 'Nieznana'
                   ELSE 'Bledna'
                  END;
          END;
   MEMBER FUNCTION Dochod_myszowy RETURN NUMBER IS
          BEGIN
           RETURN NVL(przydzial_myszy,0)+
                  NVL(myszy_extra,0);
          END;
  END;
  /

CREATE OR REPLACE TYPE PLEBS_T AS OBJECT
(pseudo VARCHAR2(15),
 MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2)
FINAL;
/
CREATE OR REPLACE TYPE BODY PLEBS_T AS
MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2 IS
    kott Kocury%ROWTYPE;
    BEGIN
    SELECT * INTO kott FROM Kocury WHERE pseudo=SELF.pseudo;
    RETURN kott.imie || ' ' || kott.pseudo || ' '|| kott.funkcja;
    END;
END;
/
CREATE OR REPLACE TYPE ELITA_T AS OBJECT
( pseudo VARCHAR2(15),
 sluga VARCHAR2(15),
 MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2)
FINAL;
/
CREATE OR REPLACE TYPE BODY ELITA_T AS
MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2 IS
    kott Kocury%ROWTYPE;
    BEGIN
    SELECT * INTO kott FROM Kocury WHERE pseudo=SELF.pseudo;
    RETURN kott.imie || ' ' || kott.pseudo || ' '|| kott.funkcja || ' sluga: ' || SELF.sluga;
    END;
END;
/
CREATE OR REPLACE TYPE KONTO_MYSZY_T AS OBJECT
(nr_myszy NUMBER(5),
 data_wprowadzenia DATE,
 data_usuniecia DATE,
 wlasciciel VARCHAR(15),
 MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2);
 /
CREATE OR REPLACE TYPE BODY KONTO_MYSZY_T AS
 MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2 IS
    BEGIN
     RETURN TO_CHAR(data_wprowadzenia) || ' ' || wlasciciel || ' '|| TO_CHAR(data_usuniecia);
    END;
END;
/
CREATE OR REPLACE TYPE INCYDENTY_T AS OBJECT
( pseudo VARCHAR2(15),
   imie_wroga VARCHAR2(15),
   data_incydentu  DATE,
   opis_incydentu VARCHAR2(50),
   MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2);
/

CREATE OR REPLACE TYPE BODY INCYDENTY_T AS
MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2 IS
    BEGIN
        RETURN pseudo ||' vs. ' || imie_wroga || ' ' || TO_CHAR(data_incydentu) || ' ' ||opis_incydentu;
    END; 
END;
/

---------------------------------------------------------------
--tworzenie widoków obiektowych
CREATE OR REPLACE FORCE VIEW Kocury_p OF Kocury_o
WITH OBJECT IDENTIFIER (pseudo) AS
    SELECT pseudo, plec, pseudo, funkcja, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy, 
    MAKE_REF(Kocury_p, pseudo) szef
    FROM Kocury;
    
SELECT * FROM Kocury_p;