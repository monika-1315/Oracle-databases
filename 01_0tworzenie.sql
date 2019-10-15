CREATE TABLE Bandy(
    nr_bandy NUMBER(2)CONSTRAINT bandy_pk PRIMARY KEY,
    nazwa VARCHAR2(20) CONSTRAINT bandy_nazw_nn NOT NULL,
    teren VARCHAR2(15) CONSTRAINT bandy_ter_un UNIQUE,
    szef_bandy VARCHAR2(15) CONSTRAINT bandy_szef_un UNIQUE);
    
CREATE TABLE Funkcje(
   funkcja VARCHAR2(10) CONSTRAINT funkcje_fun_pk PRIMARY KEY,
   min_myszy NUMBER(3) CONSTRAINT funkcje_min_ch CHECK (min_myszy > 5),
   max_myszy NUMBER(3) CONSTRAINT funckje_max_ch CHECK (200 > max_myszy),
    CONSTRAINT funkcje_max_ge_min_ch CHECK (max_myszy>= min_myszy));

CREATE TABLE Kocury(
   imie VARCHAR2(15) CONSTRAINT kocury_imie_nn NOT NULL,
   plec VARCHAR2(1) CONSTRAINT kocury_plec_ch CHECK (plec IN ('M', 'D')),
   pseudo VARCHAR2(15) CONSTRAINT kocury_pseodo_pk PRIMARY KEY, 
   funkcja VARCHAR2(10) CONSTRAINT kocury_funkcja_fk REFERENCES Funkcje(funkcja),
   szef VARCHAR2(15) CONSTRAINT kocury_szef_fk REFERENCES Kocury(pseudo),
   w_stadku_od DATE DEFAULT SYSDATE,
   przydzial_myszy NUMBER(3),
   myszy_extra NUMBER(3),
   nr_bandy NUMBER(2) CONSTRAINT kocury_nrbandy_fk REFERENCES Bandy(nr_bandy));
   
ALTER TABLE Bandy
    MODIFY szef_bandy CONSTRAINT bandy_szef_fk REFERENCES Kocury(pseudo);
    
CREATE TABLE Wrogowie(
   imie_wroga VARCHAR2(15) CONSTRAINT wrogowie_imie_pk PRIMARY KEY,   
   stopien_wrogosci NUMBER(2) CONSTRAINT wrogowie_stop_ch CHECK (stopien_wrogosci BETWEEN 1 AND 10),
   gatunek VARCHAR2(15),    
   lapowka VARCHAR2(20));
   
CREATE TABLE Wrogowie_Kocurow(
   pseudo VARCHAR2(15) CONSTRAINT wrogkoc_pseudo_fk REFERENCES Kocury(pseudo),
   imie_wroga VARCHAR2(15) CONSTRAINT wrogkoc_imie_fk REFERENCES Wrogowie(imie_wroga),
   data_incydentu  DATE CONSTRAINT wrogkoc_data_nn NOT NULL,
   opis_incydentu VARCHAR2(50),
      CONSTRAINT wrogkoc_pk PRIMARY KEY(pseudo, imie_wroga) );

COMMIT;
