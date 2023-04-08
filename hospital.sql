-- SQL skript pro vytvoření základních objektů schématu databáze.
-- Nemocnice.
-- Autor: Maryia Mazurava (xmazur08).

DROP TABLE "lek" CASCADE CONSTRAINTS;
DROP TABLE "oddeleni" CASCADE CONSTRAINTS;
DROP TABLE "lekar" CASCADE CONSTRAINTS;
DROP TABLE "sestra" CASCADE CONSTRAINTS;
DROP TABLE "pacient" CASCADE CONSTRAINTS;
DROP TABLE "podavani" CASCADE CONSTRAINTS;
DROP TABLE "vysetreni" CASCADE CONSTRAINTS;
DROP SEQUENCE "pacient_id_trigger";
DROP MATERIALIZED VIEW "lekar_oddeleni_count";


CREATE TABLE "lek" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"nazev" VARCHAR(30) NOT NULL,
	"navod_k_pouziti" VARCHAR(255) NOT NULL
);

CREATE TABLE "oddeleni" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"nazev" VARCHAR(100) NOT NULL
);

CREATE TABLE "lekar" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
	"jmeno" VARCHAR(20) NOT NULL,
	"prijmeni" VARCHAR(30) NOT NULL,
	"specializace" VARCHAR(50) NOT NULL,
	"telefon" INT NOT NULL,
  "oddeleni_lekar_id" INT NOT NULL,
  CONSTRAINT "oddeleni_lekar_id_fk"
  FOREIGN KEY ("oddeleni_lekar_id")  REFERENCES "oddeleni" ("id")
);

-- Reprezentace generalizace/specializace: 1. možnost (tabulka pro nadtyp + pro podtypy s primárním klíčem nadtypu).
CREATE TABLE "sestra" (
    "id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "jmeno" VARCHAR(20) NOT NULL,
	  "prijmeni" VARCHAR(30) NOT NULL,
    "povinnosti" VARCHAR(255) NOT NULL,
	"smena" VARCHAR(100) NOT NULL,
	"specializace" VARCHAR(50) NOT NULL,
	"telefon" INT NOT NULL,
    "oddeleni_lekar_id" INT NOT NULL,
    CONSTRAINT "pracovnik_id"
		FOREIGN KEY ("id")  REFERENCES "lekar" ("id")
        ON DELETE CASCADE,
    CONSTRAINT "oddeleni_sestra_id_fk"
        FOREIGN KEY ("oddeleni_lekar_id")  REFERENCES "oddeleni" ("id")
);

CREATE TABLE "podavani" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "lek_id" INT NOT NULL,
	"davkovani" VARCHAR(255) NOT NULL,
    CONSTRAINT "lek_id_fk"
		FOREIGN KEY ("lek_id")  REFERENCES "lek" ("id")
        ON DELETE CASCADE
);

CREATE TABLE "pacient" (
    -- AUTO_INCREMENT přes trigger
    "id" INT DEFAULT NULL PRIMARY KEY,
    "jmeno" VARCHAR(20) NOT NULL,
	"prijmeni" VARCHAR(30) NOT NULL,
	"pohlavi" VARCHAR(4) NOT NULL,
	"datum_narozeni" DATE NOT NULL,
    "lekar_id" INT NOT NULL,
    "oddeleni_id" INT NOT NULL,
    "leceni" INT NOT NULL,
	"nemoc" VARCHAR(255) NOT NULL,
	"datum_hospitalizace" DATE NOT NULL,
	"stav" VARCHAR(11) NOT NULL,
    CHECK("stav" IN ('Propusten', 'Nepropusten')),
    CONSTRAINT "lekar_id_fk"
		FOREIGN KEY ("lekar_id") REFERENCES "lekar" ("id")
        ON DELETE CASCADE,
    CONSTRAINT "oddeleni_id_fk"
    	FOREIGN KEY ("oddeleni_id") REFERENCES "oddeleni" ("id")
        ON DELETE CASCADE,
    CONSTRAINT "leceni_fk"
    	FOREIGN KEY ("leceni") REFERENCES "podavani" ("id")
        ON DELETE CASCADE
);


CREATE TABLE "vysetreni" (
	"id" INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    "pacient_id" INT NOT NULL,
    "lekar_id" INT NOT NULL,
	"nazev" VARCHAR(50) NOT NULL,
	"datum" DATE NOT NULL,
	"vysledek" VARCHAR(255) NOT NULL,
    CONSTRAINT "pacient_vysetreni_id_fk"
        FOREIGN KEY ("pacient_id")  REFERENCES "pacient" ("id")
        ON DELETE CASCADE,
    CONSTRAINT "lekar_vysetreni_id_fk"
  	    FOREIGN KEY ("lekar_id")  REFERENCES "lekar" ("id")
        ON DELETE CASCADE
);

-- Trigger 1 pro automatické generování hodnot primárního klíče tabulky pacient.
CREATE SEQUENCE "pacient_id_trigger";
CREATE OR REPLACE TRIGGER "pacient_id_trigger"
	BEFORE INSERT ON "pacient"
	FOR EACH ROW
BEGIN
	IF :NEW."id" IS NULL THEN
		:NEW."id" := "pacient_id_trigger".NEXTVAL;
	END IF;
END;
/


INSERT INTO "lek" ("nazev", "navod_k_pouziti")
VALUES ('Ibalgin', 'Užívá např. při bolesti hlavy, zubů, zad, svalů a kloubů, při poranění měkkých tkání atd');
INSERT INTO "lek" ("nazev", "navod_k_pouziti")
VALUES ('Paralen', 'Určen ke snížení horečky při chřipce, nachlazení a jiných infekčních onemocněních, při bolestech různého původu atd.');

INSERT INTO "oddeleni" ("nazev")
VALUES ('Chirurgie');
INSERT INTO "oddeleni" ("nazev")
VALUES ('Kardiologie');

INSERT INTO "lekar" ("jmeno", "prijmeni", "specializace", "telefon", "oddeleni_lekar_id")
VALUES ('Tom', 'Novak', 'Chirurg', 420456678901, 1);
INSERT INTO "lekar" ("jmeno", "prijmeni", "specializace", "telefon", "oddeleni_lekar_id")
VALUES ('Marketa', 'Dvorakova', 'Kardiolog', 420678178965, 2);
INSERT INTO "lekar" ("jmeno", "prijmeni", "specializace", "telefon", "oddeleni_lekar_id")
VALUES ('Jan', 'Vesely', 'Kardiolog', 420990897456, 2);
INSERT INTO "lekar" ("jmeno", "prijmeni", "specializace", "telefon", "oddeleni_lekar_id")
VALUES ('Natalie', 'Astapova', 'Chirurg', 420654897456, 1);

INSERT INTO "sestra" ("jmeno", "prijmeni", "povinnosti", "smena", "specializace", "telefon", "oddeleni_lekar_id")
VALUES ('Lucie', 'Svobodova', 'Uklid laboratorie', 'Denni: 8:00-14:00', 'Sestra', 420678945674, 1);
INSERT INTO "sestra" ("jmeno", "prijmeni", "povinnosti", "smena", "specializace", "telefon", "oddeleni_lekar_id")
VALUES ('Katerina', 'Novotna', 'Prace v laboratorii', 'Denni: 8:00-14:00', 'Laborantka', 420345678902, 1);

INSERT INTO "podavani" ("lek_id", "davkovani")
VALUES (1, 'Trikrat denne');
INSERT INTO "podavani" ("lek_id", "davkovani")
VALUES (1, 'Trikrat denne');
INSERT INTO "podavani" ("lek_id", "davkovani")
VALUES (2, 'Dvakrat denne');

INSERT INTO "pacient" ("jmeno", "prijmeni", "pohlavi", "datum_narozeni", "lekar_id", "oddeleni_id", "leceni", "nemoc", "datum_hospitalizace", "stav")
VALUES ('Michal', 'Benes', 'Muz', TO_DATE('1992-11-16', 'yyyy/mm/dd'), 1, 1, 1, 'Zaludecni vred', TO_DATE('2020-12-13', 'yyyy/mm/dd'), 'Propusten');
INSERT INTO "pacient" ("jmeno", "prijmeni", "pohlavi", "datum_narozeni", "lekar_id", "oddeleni_id", "leceni", "nemoc", "datum_hospitalizace", "stav")
VALUES ('Alena', 'Fialova', 'Zena', TO_DATE('2001-05-13', 'yyyy/mm/dd'), 1, 1, 2, 'Apendicita', TO_DATE('2022-03-28', 'yyyy/mm/dd'), 'Nepropusten');
INSERT INTO "pacient" ("jmeno", "prijmeni", "pohlavi", "datum_narozeni", "lekar_id", "oddeleni_id", "leceni", "nemoc", "datum_hospitalizace", "stav")
VALUES ('Elena', 'Misurdova', 'Zena', TO_DATE('2000-06-15', 'yyyy/mm/dd'), 2, 1, 3, 'Rakovina', TO_DATE('2022-03-20', 'yyyy/mm/dd'), 'Nepropusten');

INSERT INTO "vysetreni" ("pacient_id", "lekar_id", "nazev", "datum", "vysledek")
VALUES (1, 1, 'Ultrazvukove vysetreni', TO_DATE('2020-12-13', 'yyyy/mm/dd'), 'Zjistil zaludecni vred');
INSERT INTO "vysetreni" ("pacient_id", "lekar_id", "nazev", "datum", "vysledek")
VALUES (2, 1, 'Ultrazvukove vysetreni', TO_DATE('2022-03-28', 'yyyy/mm/dd'), 'Zjistil apendicitu');


-- Předvedení triggeru 1
SELECT "id", "jmeno", "prijmeni"
FROM "pacient";

-- Procedura pocita, kolik je celkove lekaru na danem oddeleni
CREATE OR REPLACE PROCEDURE "pocet_lekaru" ("nazev_oddeleni" IN VARCHAR) AS
BEGIN
  DECLARE CURSOR "cursor_oddeleni" IS SELECT "id" FROM "oddeleni";
	"dany_lekar" NUMBER;
	"oddeleni_id" "oddeleni"."id"%TYPE;
	"dane_oddeleni_id" "oddeleni"."id"%TYPE;
BEGIN
    "dany_lekar" := 0;

	SELECT "id" INTO "dane_oddeleni_id"
	FROM "oddeleni"
	WHERE "nazev" = "nazev_oddeleni";

	OPEN "cursor_oddeleni";
	LOOP
		FETCH "cursor_oddeleni" INTO "oddeleni_id";
		EXIT WHEN "cursor_oddeleni"%NOTFOUND;
		IF "oddeleni_id" = "dane_oddeleni_id" THEN
			"dany_lekar" := "dany_lekar" + 1;
		END IF;
	END LOOP;
	CLOSE "cursor_oddeleni";

    DBMS_OUTPUT.put_line( 'Oddeleni obsahuje'  || "dany_lekar" || ' lekaru.');

	EXCEPTION WHEN NO_DATA_FOUND THEN
	BEGIN
		DBMS_OUTPUT.put_line(
			'Oddeleni ' || "nazev_oddeleni" || ' nenalezeno.'
		);
	END;
    END;
END;
/

BEGIN "pocet_lekaru"('Chirurgie');
END;
/

--Definice přístupových práv k databázovým objektům pro druhého člena týmu
GRANT ALL ON "lek" TO xvatal00;
GRANT ALL ON "lekar" TO xvatal00;
GRANT ALL ON "oddeleni" TO xvatal00;
GRANT ALL ON "pacient" TO xvatal00;
GRANT ALL ON "podavani" TO xvatal00;
GRANT ALL ON "sestra" TO xvatal00;
GRANT ALL ON "podavani" TO xvatal00;
GRANT ALL ON "vysetreni" TO xvatal00;

GRANT EXECUTE ON "pocet_lekaru" TO xvatal00;

-- Materializovaný pohled na všechny oddeleni a počet lekaru na oddelenich.
CREATE MATERIALIZED VIEW "lekar_oddeleni_count" AS
SELECT
	O."id",
	O."nazev",
	COUNT(L."oddeleni_lekar_id") AS "lekar_pocet"
FROM "lekar" L JOIN "oddeleni" O ON O."id" = L."oddeleni_lekar_id"
GROUP BY O."id", O."nazev";

-- Výpis materializovaného pohledu.
SELECT * FROM "lekar_oddeleni_count";

-- Aktualizace dat, které jsou v materializovaném pohledu.
UPDATE "lekar" SET "oddeleni_lekar_id" = 2 WHERE "id" = 1;

-- Data se v materializovaném pohledu neaktualizují.
SELECT * FROM "lekar_oddeleni_count";
