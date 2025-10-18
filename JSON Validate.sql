DROP TABLE IF EXISTS vehicles cascade constraints;

CREATE TABLE vehicles (
    vehicle_id   NUMBER,
    vehicle_info JSON VALIDATE '{
    "type"       : "object",
    "properties" : {"make"    : {"type" : "string"},
                    "model"   : {"type" : "string"},
                    "year"    : {"type" : "integer",
                                "minimum" : 1886,
                                "maximum" : 2024}},
    "required"   : ["make", "model", "year"]
    }',
    CONSTRAINT vehicles_pk PRIMARY KEY (vehicle_id)
);

INSERT INTO vehicles (vehicle_id, vehicle_info) 
VALUES 
    (1, JSON('{"make":"Toyota","model":"Camry","year":2020}')),
    (2, JSON('{"make":"Ford","model":"Mustang","year":1967}'));

-- Invalid: Missing 'year'
INSERT INTO vehicles (vehicle_id, vehicle_info) VALUES (3, JSON('{"make":"Honda","model":"Civic"}'));

-- Invalid: 'year' is out of range
INSERT INTO vehicles (vehicle_id, vehicle_info) VALUES (4, JSON('{"make":"Tesla","model":"Model S","year":1885}'));

-- First, let's recreate our basic table with some data
-- Notice we're giving the JSON constraint a specific name: vehicles_json_check
DROP TABLE IF EXISTS vehicles cascade constraints;

CREATE TABLE vehicles (
    vehicle_id   NUMBER,
    vehicle_info JSON CONSTRAINT vehicles_json_check VALIDATE 
    '{
    "type"       : "object",
    "properties" : {"make"    : {"type" : "string"},
                    "model"   : {"type" : "string"},
                    "year"    : {"type" : "integer",
                                "minimum" : 1886,
                                "maximum" : 2024}},
    "required"   : ["make", "model", "year"]
    }',
    CONSTRAINT vehicles_pk PRIMARY KEY (vehicle_id)
);

-- Insert some valid data
INSERT INTO vehicles (vehicle_id, vehicle_info) 
VALUES 
    (1, JSON('{\"make\":\"Toyota\",\"model\":\"Camry\",\"year\":2020}')),
    (2, JSON('{\"make\":\"Ford\",\"model\":\"Mustang\",\"year\":1967}'));

-- Drop the existing named JSON schema constraint
ALTER TABLE vehicles DROP CONSTRAINT vehicles_json_check;

-- Add the enhanced constraint with additionalProperties: false
ALTER TABLE vehicles ADD CONSTRAINT vehicles_json_enhanced_check 
CHECK (vehicle_info IS JSON VALIDATE '{
"type"       : "object",
"properties" : {"make"    : {"type" : "string"},
                "model"   : {"type" : "string"},
                "year"    : {"type" : "integer",
                            "minimum" : 1886,
                            "maximum" : 2024}},
"required"   : ["make", "model", "year"],
"additionalProperties" : false
}');

INSERT INTO vehicles (vehicle_id, vehicle_info) VALUES (6, JSON('{"make":"BMW","model":"X5","year":2019,"color":"black"}'));

DROP TABLE IF EXISTS vehicles cascade constraints;

CREATE TABLE vehicles (
    vehicle_id   NUMBER,
    vehicle_info JSON,
    CONSTRAINT vehicles_pk PRIMARY KEY (vehicle_id)
);

-- Insert a mix of valid and invalid JSON data
INSERT INTO vehicles (vehicle_id, vehicle_info) 
VALUES 
    (1, JSON('{"make":"Nissan","model":"Altima","year":2021}')),
    (2, JSON('{"make":"Chevrolet","model":"Malibu"}')),
    (3, JSON('{"make":"Dodge","model":"Charger","year":2023}')),
    (4, JSON('{"make":"Audi","model":"A4","year":1885}'));


SELECT *
FROM   vehicles
WHERE  vehicle_info IS JSON VALIDATE '{
"type"       : "object",
"properties" : {"make"    : {"type" : "string"},
                "model"   : {"type" : "string"},
                "year"    : {"type" : "integer",
                            "minimum" : 1886,
                            "maximum" : 2024}},
"required"   : ["make", "model", "year"]
}';

DROP TABLE IF EXISTS vehicles cascade constraints;