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
 
CREATE TABLE Elita OF ELITA_O
 (imie NOT NULL,
 szef SCOPE IS Kocury2,
 sluga SCOPE IS Plebs,
 CONSTRAINT elita_pk PRIMARY KEY (pseudo),
 CONSTRAINT elita_plec_ch CHECK (plec IN ('M', 'D')));

CREATE TABLE Konto OF KONTO_MYSZY_O
(data_wprowadzenia NOT NULL,
 wlasciciel NOT NULL,
 CONSTRAINT konto_pk PRIMARY KEY(nr_myszy));
 
CREATE TABLE Incydenty OF INCYDENTY_O
(data_incydentu NOT NULL,
 pseudo REFERENCES Kocury2(pseudo),
 CONSTRAINT incyd_pk PRIMARY KEY (pseudo, imie_wroga));