--tabele
CREATE TABLE Kocury2 OF KOCURY_O
(imie NOT NULL, 
 CONSTRAINT koc2_pk PRIMARY KEY (pseudo),
 CONSTRAINT koc2_plec_ch CHECK (plec IN ('M', 'D')));
 
CREATE TABLE Plebs OF PLEBS_o
 (imie NOT NULL,
 szef SCOPE IS Kocury2,
 CONSTRAINT plebs_pk PRIMARY KEY (pseudo),
 CONSTRAINT plebs_plec_ch CHECK (plec IN ('M', 'D')));
-- DROP TABLE plebs;
 
CREATE TABLE Elita OF ELITA_O
 (imie NOT NULL,
 szef SCOPE IS Kocury2,
 sluga SCOPE IS Plebs,
 CONSTRAINT elita_pk PRIMARY KEY (pseudo),
 CONSTRAINT elita_plec_ch CHECK (plec IN ('M', 'D')));
-- DROP TABLE elita;

CREATE TABLE Konto OF KONTO_MYSZY_O
(data_wprowadzenia NOT NULL,
 wlasciciel NOT NULL,
 CONSTRAINT konto_pk PRIMARY KEY(nr_myszy));
-- DROP TABLE Konto;
 
CREATE TABLE Incydenty OF INCYDENTY_O
(data_incydentu NOT NULL,
 pseudo REFERENCES Kocury2(pseudo),
 CONSTRAINT incyd_pk PRIMARY KEY (pseudo, imie_wroga));
-- DROP TABLE incydenty;
-- DROP VIEW Kocury_ob;
-- 
-- CREATE VIEW Kocury_ob AS 
-- SELECT P.imie, P.plec, P.pseudo, P.funkcja, P.w_stadku_od, P.przydzial_myszy, P.myszy_extra, P.szef FROM Plebs P 
-- UNION 
-- SELECT E.imie, E.plec, E.pseudo, E.funkcja, E.w_stadku_od, E.przydzial_myszy, E.myszy_extra, E.szef FROM Elita E;