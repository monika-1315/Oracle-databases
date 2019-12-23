CREATE OR REPLACE TYPE KOCURY_O AS OBJECT
  (imie VARCHAR2(15),
   plec VARCHAR2(1),
   pseudo VARCHAR2(15), 
   funkcja VARCHAR2(10),
   szef VARCHAR2(15),
   w_stadku_od DATE,
   przydzial_myszy NUMBER(3),
   myszy_extra NUMBER(3),
   nr_bandy NUMBER(2),
  MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2,
  MEMBER FUNCTION O_plci RETURN VARCHAR2,
  MEMBER FUNCTION Dochod_myszowy RETURN NUMBER)
	NOT FINAL;
 /
CREATE OR REPLACE TYPE BODY KOCURY_O AS
    MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2 IS
     BEGIN
        RETURN imie || ', ' || O_plci() || ', ' || pseudo || funkcja;
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

CREATE OR REPLACE TYPE PLEBS_O UNDER KOCURY_O()
FINAL;
/
CREATE OR REPLACE TYPE ELITA_O UNDER KOCURY_O
(sluga REF Plebs_o)
FINAL;
/
CREATE OR REPLACE TYPE KONTO_MYSZY_O AS OBJECT
(data_wprowadzenia DATE,
 data_usuniecia DATE,
 wlasciciel REF Elita_o,
 MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2);
 --MEMBER FUNCTION STAN_KONTA(pseudo VARCHAR2) RETURN NUMBER);
 /
 CREATE OR REPLACE TYPE BODY KONTO_MYSZY_O AS
 MAP MEMBER FUNCTION TO_STRING RETURN VARCHAR2 IS
    wl Elita_o;
    BEGIN
        SELECT DEREF(wlasciciel) INTO wl FROM dual;
     RETURN TO_CHAR(data_wprowadzenia) || ' ' || wl.pseudo || ' '|| TO_CHAR(data_usuniecia);
    END;
END;
/

CREATE OR REPLACE TYPE INCYDENTY_O AS OBJECT
(kot REF Kocury_o,
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
