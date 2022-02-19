CREATE TRIGGER update_table
     AFTER INSERT ON divari3.D3Nide
     FOR EACH ROW
     EXECUTE PROCEDURE insert_to_nide();


CREATE OR REPLACE FUNCTION insert_to_nide()
    RETURNS trigger AS
$BODY$
    DECLARE
    	nide_id keskustietokanta.Nide.Id%type;
    BEGIN
    SELECT max(Id) FROM keskustietokanta.Nide INTO nide_id;
    if not found then
    	nide_id := 1;
    END if;
    -- Oletetaan, että kirjan perustietojen id on sama keskustietokannassa ja d3:n tietokannassa.
INSERT INTO keskustietokanta.Nide (Id, Teos_id, Paino, Hinta, Sisaanostohinta, Myyntipaivamaara, Tila, Divari_ID) values (nide_id + 1, NEW.Teos_id, NEW.Paino, NEW.Hinta, NEW.Sisaanostohinta, NEW.Myyntipaivamaara, NEW.Tila, 3);
    RETURN NEW;
    END;
$BODY$     
   language PLPGSQL;


