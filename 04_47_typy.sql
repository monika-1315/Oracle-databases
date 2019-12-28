CREATE OR REPLACE TYPE KOCURY_O AS OBJECT
  (imie VARCHAR2(15),
   plec VARCHAR2(1),
   pseudo VARCHAR2(15), 
   funkcja VARCHAR2(10),
   w_stadku_od DATE,
   przydzial_myszy NUMBER(3),
   myszy_extra NUMBER(3),
   nr_bandy NUMBER(2),
   szef REF KOCURY_O,
  MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2,
  MEMBER FUNCTION O_plci RETURN VARCHAR2,
  MEMBER FUNCTION Dochod_myszowy RETURN NUMBER)
	NOT FINAL;
 /
--ALTER TYPE KOCURY_O
--DROP ATTRIBUTE szef
--INVALIDATE;
--/
--ALTER TYPE KOCURY_O
--ADD ATTRIBUTE szef REF KOCURY_O
--CASCADE;
--/
CREATE OR REPLACE TYPE BODY KOCURY_O AS
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
--DROP TYPE PLEBS_O FORCE;
CREATE OR REPLACE TYPE PLEBS_O AS OBJECT
(kot REF KOCURY_O,
 pseudo VARCHAR2(15),
 MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2)
FINAL;
/
--ALTER TYPE PLEBS_O
--ADD ATTRIBUTE pseudo VARCHAR(15)
--INVALIDATE;

CREATE OR REPLACE TYPE BODY PLEBS_O AS
MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2 IS
    kott Kocury_o;
    BEGIN
    SELECT DEREF(SELF.kot) INTO kott from dual;
    RETURN kott.TO_STRING();
    END;
END;
/

--DROP TYPE ELITA_O FORCE;
CREATE OR REPLACE TYPE ELITA_O AS OBJECT
( kot REF KOCURY_O,
 sluga REF Plebs_o,
 pseudo VARCHAR2(15),
 MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2)
FINAL;
/
--ALTER TYPE ELITA_O
--ADD ATTRIBUTE pseudo VARCHAR(15)
--INVALIDATE;
CREATE OR REPLACE TYPE BODY ELITA_O AS
MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2 IS
    kott Kocury_o;
    slug Plebs_o;
    kots Kocury_o;
    BEGIN
    SELECT DEREF(SELF.kot) INTO kott from dual;
    SELECT DEREF(SELF.sluga) INTO slug from dual;
    SELECT DEREF(slug.kot) INTO kots from dual;
    RETURN kott.TO_STRING() || ' sluga: ' || kots.pseudo;
    END;
END;
/    
CREATE OR REPLACE TYPE KONTO_MYSZY_O AS OBJECT
(nr_myszy NUMBER(5),
 data_wprowadzenia DATE,
 data_usuniecia DATE,
 wlasciciel REF Elita_o,
 MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2);
 --MEMBER FUNCTION STAN_KONTA(pseudo VARCHAR2) RETURN NUMBER);
 /
 DROP TYPE KONTO_MYSZY_O;
 
 CREATE OR REPLACE TYPE BODY KONTO_MYSZY_O AS
 MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2 IS
    wl Elita_o;
    kot Kocury_o;
    BEGIN
        SELECT DEREF(wlasciciel) INTO wl FROM dual;
        SELECT DEREF(wl.kot) INTO kot FROM dual;
     RETURN TO_CHAR(data_wprowadzenia) || ' ' || kot.pseudo || ' '|| TO_CHAR(data_usuniecia);
    END;
END;
/
--DROP TYPE INCYDENTY_O;
CREATE OR REPLACE TYPE INCYDENTY_O AS OBJECT
( pseudo VARCHAR2(15),
   kot REF Kocury_o,
   imie_wroga VARCHAR2(15),
   data_incydentu  DATE,
   opis_incydentu VARCHAR2(50),
   MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2);
/


CREATE OR REPLACE TYPE BODY INCYDENTY_O AS
MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2 IS
    kocur Kocury_o;
    BEGIN
        SELECT DEREF(kot) INTO kocur FROM dual;
        RETURN kocur.pseudo ||' vs. ' || imie_wroga || ' ' || TO_CHAR(data_incydentu) || ' ' ||opis_incydentu;
    END; 
END;
/
