CREATE SCHEMA keskustietokanta;
SET SEARCH_PATH TO keskustietokanta;
CREATE TABLE keskustietokanta.Teos (
	Id INT,
	Tekija VARCHAR (200),
	Nimi VARCHAR (200) NOT NULL,
	Tyyppi VARCHAR (20),
	Luokka VARCHAR (20),
	ISBN VARCHAR (20),
	PRIMARY KEY (Id)
);
CREATE TABLE keskustietokanta.Divari (
	Divari_ID INT,
	Nimi VARCHAR (200),
	Osoite VARCHAR (200),
	Websivu VARCHAR (200),
	PRIMARY KEY (Divari_ID)
);
CREATE TABLE keskustietokanta.Asiakas (
	Id INT,
	Nimi VARCHAR (200) NOT NULL,
	Osoite VARCHAR (200),
	Sahkopostiosoite VARCHAR (200),
	Puhelinnro INT,
	PRIMARY KEY (Id)
);
CREATE TABLE keskustietokanta.Yllapitaja (
	Id INT,
	Nimi VARCHAR (200) NOT NULL,
	Divari VARCHAR (20) NOT NULL,
	PRIMARY KEY (Id)
);
CREATE TABLE keskustietokanta.Nide (
	Id INT,
	Teos_id INT NOT NULL,
	Paino decimal(13, 4) NOT NULL,
	Hinta decimal(13, 2) NOT NULL,
	Sisaanostohinta decimal(13, 2),
	Myyntipaivamaara date,
	Tila VARCHAR (15) NOT NULL,
	Divari_ID INT NOT NULL,
	CHECK (Hinta > 0),
	PRIMARY KEY (Id, Divari_ID),
	FOREIGN KEY (Teos_id) REFERENCES Teos(Id),
	FOREIGN KEY (Divari_ID) REFERENCES Divari(Divari_ID),
);
CREATE TABLE keskustietokanta.Ostanut (
	Id INT,
	Valikoima_Id INT,
	Divari_id INT,
	Tilaus_id INT,
	PRIMARY KEY (Id, Valikoima_Id, Divari_id),
	FOREIGN KEY (Id) REFERENCES Asiakas(Id),
	FOREIGN KEY (Valikoima_Id, Divari_id) REFERENCES Nide(Id, Divari_ID),
	FOREIGN KEY (Tilaus_id) REFERENCES Tilaus(Tilaus_id)
);
CREATE TABLE keskustietokanta.Postikulut (
	Paino decimal(13, 2) NOT NULL,
	Postikulu decimal(13, 2),
	CHECK (Postikulu > 0),
	PRIMARY KEY (Paino)
);
CREATE TABLE keskustietokanta.Tilaus (
	Tilaus_id INT,
	Tila VARCHAR (40),
	Myyntipaivamaara date,
	Toimituspaivamaara date,
	Toimitusosoite VARCHAR (200),
	Toimitustapa VARCHAR (200),
	PRIMARY KEY (Tilaus_id)
);
CREATE SCHEMA divari1;
SET SEARCH_PATH TO divari1;
--Divari 1:n oma tietokanta.
CREATE TABLE divari1.D1Teos (
	Id INT,
	Tekija VARCHAR (200),
	Nimi VARCHAR (200) NOT NULL,
	Tyyppi VARCHAR (20),
	Luokka VARCHAR (20),
	ISBN VARCHAR (20),
	PRIMARY KEY (Id)
);
CREATE TABLE divari1.D1Nide (
	Id INT,
	Teos_id INT NOT NULL,
	Paino decimal(13, 4) NOT NULL,
	Hinta decimal(13, 2) NOT NULL,
	Sisaanostohinta decimal(13, 2),
	Myyntipaivamaara date,
	Tila VARCHAR (15) NOT NULL,
	CHECK (Hinta > 0),
	PRIMARY KEY (Id),
	FOREIGN KEY (Teos_id) REFERENCES D1Teos(Id),
);
--Divari 3:n oma tietokanta.
CREATE SCHEMA divari3;
SET SEARCH_PATH TO divari3;
CREATE TABLE divari3.D3Teos (
	Id INT,
	Tekija VARCHAR (200),
	Nimi VARCHAR (200) NOT NULL,
	Tyyppi VARCHAR (20),
	Luokka VARCHAR (20),
	ISBN VARCHAR (20),
	PRIMARY KEY (Id)
);
CREATE TABLE divari3.D3Nide (
	Id INT,
	Teos_id INT NOT NULL,
	Paino decimal(13, 4) NOT NULL,
	Hinta decimal(13, 2) NOT NULL,
	Sisaanostohinta decimal(13, 2),
	Myyntipaivamaara date,
	Tila VARCHAR (15) NOT NULL,
	CHECK (Hinta > 0),
	PRIMARY KEY (Id),
	FOREIGN KEY (Teos_id) REFERENCES D3Teos(Id),
);