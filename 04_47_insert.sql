ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

INSERT INTO Plebs VALUES
(PLEBS_O ('MICKA','D','LOLA','MILUSIA','2009-10-14',25,47,1,NULL));
--DELETE FROM KOcury2;
DECLARE
kot plebs_o;
BEGIN
SELECT VALUE(K) INTO kot FROM Plebs K;
INSERT INTO
Kocury2 VALUES kot;
END;
/
SELECT * FROM Kocury2;
SELECT * FROM Plebs;
SELECT * FROM Elita;

UPDATE Kocury2 K
SET K.plec='M' WHERE K.imie='MICKA';


BEGIN
INSERT INTO Elita
SELECT 'JACEK','M','PLACEK','LOWCZY','2008-12-01',67,NULL,2, NULL, REF(P) FROM Plebs P WHERE pseudo='LOLA';
END;
/

DECLARE
kot elita_o;
BEGIN
SELECT VALUE(K) INTO kot FROM Elita K;
INSERT INTO
Kocury2 VALUES kot;
END;
/

INSERT ALL 
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('BARI','M','RURA','LAPACZ','LYSY','2009-09-01',56,NULL,2)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES (
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('LUCEK','M','ZERO','KOT','KURKA','2010-03-01',43,NULL,3)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('SONIA','D','PUSZYSTA','MILUSIA','ZOMBI','2010-11-18',20,35,3)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('LATKA','D','UCHO','KOT','RAFA','2011-01-01',40,NULL,4)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('DUDEK','M','MALY','KOT','RAFA','2011-05-15',40,NULL,4)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('CHYTRY','M','BOLEK','DZIELCZY','TYGRYS','2002-05-05',50,NULL,1)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('KOREK','M','ZOMBI','BANDZIOR','TYGRYS','2004-03-16',75,13,3)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('BOLEK','M','LYSY','BANDZIOR','TYGRYS','2006-08-15',72,21,2)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('ZUZIA','D','SZYBKA','LOWCZY','LYSY','2006-07-21',65,NULL,2)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('RUDA','D','MALA','MILUSIA','TYGRYS','2006-09-17',22,42,1)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('PUCEK','M','RAFA','LOWCZY','TYGRYS','2006-10-15',65,NULL,4)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('PUNIA','D','KURKA','LOWCZY','ZOMBI','2008-01-01',61,NULL,3)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('BELA','D','LASKA','MILUSIA','LYSY','2008-02-01',24,28,2)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('KSAWERY','M','MAN','LAPACZ','RAFA','2008-07-12',51,NULL,4)
    INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy) 
        VALUES ('MELA','D','DAMA','LAPACZ','RAFA','2008-11-01',51,NULL,4)
    SELECT * from dual;
