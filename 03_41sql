CREATE OR REPLACE TRIGGER nr_bandy
BEFORE INSERT ON Bandy
FOR EACH ROW
DECLARE
    nr_bandy Bandy.nr_bandy%TYPE;
BEGIN
    SELECT MAX(nr_bandy) INTO nr_bandy FROM Bandy ;
    :NEW.nr_bandy:=nr_bandy+1;
END;