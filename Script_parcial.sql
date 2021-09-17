CREATE TABLE "Department" (
  "departmentid" SERIAL NOT NULL, 
  "name" VARCHAR(255), 
  PRIMARY KEY ("departmentid")
);

CREATE TABLE "Position" (
  "positionid" SERIAL NOT NULL, 
  "name" VARCHAR(255), 
  PRIMARY KEY ("positionid")
);

CREATE TABLE "Employee" (
  "employeeid" SERIAL NOT NULL, 
  "fullName" VARCHAR(255), 
	"branchId" VARCHAR(255),
	"departmentid" integer,
	"positionid" integer,
	"addressid" integer,
	"supervisorid" integer,
	"branchOffice" INTEGER
  PRIMARY KEY ("employeeid")
);

CREATE TABLE "BranchOffice"(
  "branchid" SERIAL NOT NULL, 
  "name" VARCHAR(255), 
  "addressid" integer,
  PRIMARY KEY ("branchid")
);

CREATE TABLE "Address" (
  "addressid" SERIAL NOT NULL, 
  "line1" VARCHAR(255),
	"line2" VARCHAR(255),
	"cityid" integer,
  PRIMARY KEY ("addressid")
);

CREATE TABLE "City" (
  "cityid" SERIAL NOT NULL, 
  "name" VARCHAR(255),
	"countryid" integer,
  PRIMARY KEY ("cityid")
);

CREATE TABLE "Country" (
  "countryid" SERIAL NOT NULL, 
  "name" VARCHAR(255), 
  PRIMARY KEY ("countryid")
);

CREATE TABLE "EmployeeAudit" (
  "employeeid" SERIAL NOT NULL, 
  "fullName" VARCHAR(255), 
	"branchOffice" VARCHAR(255),
	"department" VARCHAR(255),
	"position" VARCHAR(255),
	"adress" VARCHAR(255),
	"city" VARCHAR(255),
	"country" VARCHAR(255),
	"branchOffice" VARCHAR(255),
	"event" VARCHAR(255),
	"registredAt" Date
);

ALTER TABLE "City"
ADD CONSTRAINT fk_city_country 
FOREIGN KEY ("countryid") 
REFERENCES "Country" ("countryid");

ALTER TABLE "Address"
ADD CONSTRAINT fk_address_city
FOREIGN KEY ("cityid") 
REFERENCES "City" ("cityid");

ALTER TABLE "BranchOffice"
ADD CONSTRAINT fk_Office_Address
FOREIGN KEY ("addressid") 
REFERENCES "Address" ("addressid");

ALTER TABLE "Employee"
ADD CONSTRAINT fk_Employee_Department
FOREIGN KEY ("departmentid") 
REFERENCES "Department" ("departmentid");

ALTER TABLE "Employee"
ADD CONSTRAINT fk_Employee_Position
FOREIGN KEY ("positionid") 
REFERENCES "Position" ("positionid");

ALTER TABLE "Employee"
ADD CONSTRAINT fk_Employee_Address
FOREIGN KEY ("addressid") 
REFERENCES "Address" ("addressid");

ALTER TABLE "Employee"
ADD CONSTRAINT fk_Employee_Supervisor
FOREIGN KEY ("employeeid") 
REFERENCES "Employee" ("employeeid");



create trigger AUDITORIA_EMPLOYEE
after insert or update or delete on "EMPLOYEE"
for each row EXECUTE PROCEDURE employee_au_trig();


CREATE OR REPLACE FUNCTION employee_au_trig() RETURNS trigger AS $em_tr$
    BEGIN
IF (TG_OP = 'UPDATE') THEN 
insert into "EmployeeAudit" values(old."employeeid", old."fullName", old."branchId", old."departmentid", old."positionid", old."addressid", 0,0, 'Actualizar', current_date );

END IF;

if (TG_OP = 'DELETE') THEN 

insert into "EmployeeAudit" values(old."employeeid", old."fullName", old."branchId", old."departmentid", old."positionid", old."addressid", 0,0,  'Borrar', current_date );


END IF;

if (TG_OP = 'INSERT') THEN 

insert into "EmployeeAudit" values(new.employeeid, new."fullName", new."branchId", new."departmentid", new."positionid", new."addressid", 0,0,  'Insertar', current_date );

END IF;
RETURN NULL;
END;
$em_tr$ LANGUAGE plpgsql;


CREATE OR REPLACE VIEW historicoCargos AS
	SELECT 	fullName AS nombre_empleado, 
			position AS Cargo
	FROM "Employee", "EmployeeAudit"
	WHERE "Employee".employeeid = "EmployeeAudit".employeeid AND
		  "Employee".branchOffice = 1;