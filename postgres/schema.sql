CREATE TABLE "authentications" (
  "pilot_id" uuid PRIMARY KEY,
  "username" varchar(64) NOT NULL,
  "password" varchar(128) NOT NULL,
  "version" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "authorizations" (
  "pilot_id" uuid,
  "role_id" uuid,
  PRIMARY KEY ("pilot_id", "role_id")
);

CREATE TABLE "roles" (
  "id" uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" varchar(32) NOT NULL,
  "permissions" varchar(32)[] NOT NULL,
  "version" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "pilots" (
  "id" uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "name" varchar(64) NOT NULL,
  "email" varchar(64) NOT NULL,
  "profile" jsonb,
  "licenses" varchar(32)[] NOT NULL,
  "certificate" text,
  "payment" double,
  "version" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "flights" (
  "id" uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "previous_id" uuid,
  "pilot_id" uuid,
  "aircraft_id" uuid NOT NULL,
  "origin" varchar(4) NOT NULL,
  "destination" varchar(4) NOT NULL,
  "departure" timestamptz,
  "duration" float,
  "version" timestamptz NOT NULL DEFAULT (now())
);

CREATE TABLE "aircrafts" (
  "id" uuid PRIMARY KEY DEFAULT (uuid_generate_v4()),
  "type" varchar(4),
  "company" varchar(64),
  "capacity" interger,
  "logbooks" jsonb[] NOT NULL,
  "maintenance" boolean NOT NULL DEFAULT (false),
  "location" geometry(point,4326),
  "version" timestamptz NOT NULL DEFAULT (now())
);

CREATE INDEX ON "authentications" ("username");

CREATE INDEX ON "authentications" ("password");

CREATE INDEX ON "authentications" ("version");

CREATE INDEX ON "roles" ("name");

CREATE INDEX ON "roles" ("version");

CREATE INDEX ON "pilots" ("name");

CREATE INDEX ON "pilots" ("profile");

CREATE INDEX ON "pilots" ("licenses");

CREATE INDEX ON "pilots" ("payment");

CREATE INDEX ON "pilots" ("version");

CREATE INDEX ON "flights" ("pilot_id");

CREATE INDEX ON "flights" ("aircraft_id");

CREATE INDEX ON "flights" ("duration");

CREATE INDEX ON "flights" ("version");

CREATE INDEX ON "aircrafts" ("type");

CREATE INDEX ON "aircrafts" ("company");

CREATE INDEX ON "aircrafts" ("capacity");

CREATE INDEX ON "aircrafts" ("location");

CREATE INDEX ON "aircrafts" ("logbooks");

CREATE INDEX ON "aircrafts" ("version");

COMMENT ON COLUMN "pilots"."profile" IS 'generic information';

COMMENT ON COLUMN "pilots"."licenses" IS 'match requirements';

COMMENT ON COLUMN "pilots"."certificate" IS 'medical certificate ';

COMMENT ON COLUMN "pilots"."payment" IS 'amount per hour ';

COMMENT ON COLUMN "flights"."previous_id" IS 'connection flight';

COMMENT ON COLUMN "flights"."pilot_id" IS 'allows null for project plan';

COMMENT ON COLUMN "flights"."duration" IS 'in hours';

COMMENT ON COLUMN "aircrafts"."capacity" IS 'EUR or Bitcoin';

COMMENT ON COLUMN "aircrafts"."logbooks" IS 'type, date, pilot, content';

ALTER TABLE "authentications" ADD FOREIGN KEY ("pilot_id") REFERENCES "pilots" ("id");

ALTER TABLE "authorizations" ADD FOREIGN KEY ("pilot_id") REFERENCES "pilots" ("id");

ALTER TABLE "authorizations" ADD FOREIGN KEY ("role_id") REFERENCES "roles" ("id");

ALTER TABLE "flights" ADD FOREIGN KEY ("previous_id") REFERENCES "flights" ("id");

ALTER TABLE "flights" ADD FOREIGN KEY ("pilot_id") REFERENCES "pilots" ("id");

ALTER TABLE "flights" ADD FOREIGN KEY ("aircraft_id") REFERENCES "aircrafts" ("id");
