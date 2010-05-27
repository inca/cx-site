Circumflex ORM   {#orm}
==============

Circumflex ORM is an [Object/Relational Mapping (ORM)][orm-wiki] framework for creating fast,
concise and efficient data-centric applications with elegant DSL.

The term [Object/Relational Mapping][orm-wiki] refers to the technique of mapping
a data representation from an object model to a relational data model. ORM tools may
significantly speed up development by eliminating boilerplates for common
[CRUD][crud-wiki] operations, making applications more portable by
incapsulating vendor-specific SQL dialects, providing object-oriented API for querying,
allowing transparent navigation between object associations and much more.

  [orm-wiki]: http://en.wikipedia.org/wiki/Object-relational_mapping
              "ORM definition on Wikipedia"
  [crud-wiki]: http://en.wikipedia.org/wiki/Create,_read,_update_and_delete
               "CRUD definition on Wikipedia"

## Installation & Configuration   {#install}

There's a couple of things you need to do in order to get started with Circumflex ORM.

First, make sure that `circumflex-orm-<version>.jar` is in the classpath. The easiest way
to do so is to add corresponding `dependency` to your `pom.xml`:

    lang:xml
    <properties>
      <cx.version><!-- desired version --></cx.version>
    </properties>
    <dependencies>
      <!-- Circumflex ORM -->
      <dependency>
        <groupId>ru.circumflex</groupId>
        <artifactId>circumflex-orm</artifactId>
        <version>{cx.version}</version>
      </dependency>
    </dependencies>

Second, configure database access by specifying following [configuration parameters](#cfg):

  * `orm.connection.driver` -- fully-qualified class name of JDBC Driver of your database vendor;
  * `orm.connection.url` -- URL for database communication (read the documentation of
  your database vendor for more information);
  * `orm.connection.username` and `orm.connection.password` -- database account data which will
  be used to obtain JDBC connections.

There are a couple of ways you can provide configuration parameters:

  * You can specify them in `cx.properties`:

        lang:no-highlight
        orm.connection.driver=org.postgresql.Driver
        orm.connection.url=jdbc:postgresql://localhost:5432/mydb
        orm.connection.username=myuser
        orm.connection.password=mypassword

    This file should be in the classpath, (typically in `/WEB-INF/classes` of your web application);
    if you use Maven, just place it into `src/main/resources` directory.

  * You can also specify them in your `pom.xml` and configure `maven-cx-plugin`:

        lang:xml
        <project xmlns="http://maven.apache.org/POM/4.0.0">
          <properties>
            <orm.connection.driver>org.postgresql.Driver</orm.connection.driver>
            <orm.connection.url>jdbc:postgresql://localhost:5432/mydb</orm.connection.url>
            <orm.connection.username>myuser</orm.connection.username>
            <orm.connection.password>mypassword</orm.connection.password>
          </properties>
        </project>

    Note that you should also add an execution for `cfg` goal of `maven-cx-plugin` to your
    `pom.xml`, see the [Circumflex Maven Plugin documentation](/plugin.html#cfg) for more details.

If you are writing a web application, configure `TransactionManagementListener` in your `web.xml`:

    lang:xml
    <web-app version="2.5">
      <listener>
        <listener-class>ru.circumflex.orm.TransactionManagementListener</listener-class>
      </listener>
    </web-app>

Note that there are different approaches to transaction demarcation in web applications, read more
in the [transaction demarcation](#demarcation) section.

### Imports   {#import}

All code examples assume that you have following `import` statement in code where necessary:

    lang:scala
    import ru.circumflex.orm._

## Central abstractions   {#abstractions}

Applications built with Circumflex ORM usually operate with following abstractions:

  * [`Record`](#record) -- wraps a row in a database `Table` or `View`, encapsulates the database
  access and adds domain logic on that data;
  * [`Relation`](#relation) -- encapsulates database object (`Table` or `View`) for
  corresponding `Record` and adds methods for [querying](#sql), [manipulating](#dml)
  and [validating](#validation) it's data;
  * `Field` -- corresponds to database column iside `Record`;
  * [`Association`](#association) -- links one type of `Record` with another, this relationship
  is expressed by foreign keys in the database;
  * `Query` -- communicates with database either for [data retrieval](#sql) or
  [data manipulation](#dml);
  * `SchemaObject` -- represents an abstract [database object](#aux) (such as trigger or
  stored procedure).

## Data definition   {#ddl}

The process of creating the domain model of application is refered to as *data definition*.
It usually involves following steps:

  * defining a [record](#record), a subclass of `Record`;
  * defining *fields* and [associations](#association) of the record;
  * cdefining relation, a companion object for the record subclassed from `Relation` (typically,
  more specific `Table` and `View` classes are subclassed);
  * adding constraints, indexes and other [auxiliary database objects](#aux);
  * adding methods for [querying](#sql) and [manipulating](#dml) records;
  * specifying, how the record should be [validated](#validation).

### Records   {#record}

A record is definied by subclassing `Record` and supplying self-type as it's type parameter:

    lang:scala
    class Account extends Record[Account]

The body of record class should contain definitions of it's *fields*. A field should be an
immutable (`val`) member of record class, each field will correspond to a column in database table:

    lang:scala
    class Country extends Record[Country] {
      val code = "code" VARCHAR(2) DEFAULT("'ch'") NOT_NULL
      val name = "name" TEXT
    }

As the example shows, the syntax of field definition closely resembles classic DDL for generating
database schema for tables: you specify the column name with `String`, then you call one of the
methods to create a field of certain type, then you optionally call one of methods that change the
definition of target column.

Generally, spaces may be used to delimit method calls and improve readability of column definitions.
However, sometimes Scala compiler forces you to use dot-notation:

    lang:scala
    val name = "name".TEXT.NOT_NULL

Following methods are used to create field definitions:

<table width="100%">
  <thead>
  <tr>
    <th>Method</th>
    <th>Default SQL type</th>
    <th>Scala type</th>
    <th>Implementing class</th>
  </tr>
  </thead>
  <tbody>
  <tr>
    <td><code>INTEGER</code></td>
    <td><code>INTEGER</code></td>
    <td><code>Int</code></td>
    <td><code>IntField</code></td>
  </tr>
  <tr>
    <td><code>BIGINT</code></td>
    <td><code>BIGINT</code></td>
    <td><code>Long</code></td>
    <td><code>LongField</code></td>
  </tr>
  <tr>
    <td><code>NUMERIC(precision: Int, scale: Int)</code></td>
    <td><code>NUMERIC(p, s)</code></td>
    <td><code>Double</code></td>
    <td><code>DoubleField</code></td>
  </tr>
  <tr>
    <td><code>TEXT</code></td>
    <td><code>TEXT</code></td>
    <td><code>String</code></td>
    <td><code>StringField</code></td>
  </tr>
  <tr>
    <td><code>VARCHAR(length: Int)</code></td>
    <td><code>VARCHAR(l)</code></td>
    <td><code>String</code></td>
    <td><code>StringField</code></td>
  </tr>
  <tr>
    <td><code>BOOLEAN</code></td>
    <td><code>BOOLEAN</code></td>
    <td><code>Boolean</code></td>
    <td><code>BooleanField</code></td>
  </tr>
  <tr>
    <td><code>DATE</code></td>
    <td><code>DATE</code></td>
    <td><code>java.lang.Date</code></td>
    <td><code>DateField</code></td>
  </tr>
  <tr>
    <td><code>TIME</code></td>
    <td><code>TIME</code></td>
    <td><code>java.lang.Date</code></td>
    <td><code>DateField</code></td>
  </tr>
  <tr>
    <td><code>TIMESTAMP</code></td>
    <td><code>TIMESTAMP</code></td>
    <td><code>java.lang.Date</code></td>
    <td><code>DateField</code></td>
  </tr>
  </tbody>
</table>

In the table above the default SQL types show the types defined in default [dialect](#dialect),
which can be overriden in vendor-specific dialect. Besides it is possible to define a field with
custom SQL type using the `field(name: String, sqlType: String)` method:

    lang:scala
    val myCustomField = field("custom", "NVARCHAR(32)").NOT_NULL

The columns are generated with `NOT NULL` constraint by default, so `NOT_NULL` call can be omitted:

    lang:scala
    // following definitions are equivalent:
    val name = "name".TEXT.NOT_NULL
    val name = "name".TEXT

If you need a column without `NOT NULL` constraint, you should express this using `NULLABLE` method:

    lang:scala
    val optionalField = "optional".TEXT.NULLABLE

Each record also has an implicit auto-incremented primary key field -- `id`.

Fields operate with values. You may set the value of a field:

    lang:scala
    val age = "age" INTEGER
    // following statements are equivalent:
    age := 25
    age.setValue(25)
    age() = 25

You may also retrieve the value of a field:

    lang:scala
    // following statements are equivalent:
    age()           // 25
    age.apply       // 25
    age.getValue    // 25

You may also use the `get` method for pattern matching:

    lang:scala
    age.get match {
      case Some(a) => ...
      case None => ...
    }

Or use the `getOrElse` method, which returns specified `default` instead of `null`:

    lang:scala
    age.getOrElse(18)

There are also shortcut methods for setting or checking the `null` value:

    lang:scala
    // set null:
    age.NULL_!
    age.setNull
    // check, if value is null:
    if (age.NULL_?) ...
    if (age.empty_?) ...

You may specify the default expression for a field:

    lang:scala
    class Circle extends Record[Circle] {
      val radius = "radius".NUMERIC
      val square = "square".NUMERIC.DEFAULT("PI() * (radius ^ 2)")
    }

If a record is inserted and the field with default expression is empty, then it's value will be
generated by the database.

You can also create a single-column unique constraint using the `UNIQUE` method:

    lang:scala
    val login = "login".VARCHAR(64).NOT_NULL.UNIQUE

You should place domain-specific logic inside record classes. The following example shows the most
trivial case: overriding `toString` and providing alternative constructor:

    lang:scala
    class Country extends Record[Country] {
      // Constructor shortcuts
      def this(code: String, name: String) = {
        this()
        this.code := code
        this.name := name
      }
      // Fields
      val code = "code" VARCHAR(2) DEFAULT("'ch'")
      val name = "name" TEXT
      // Miscellaneous
      override def toString = name.getOrElse("Unknown")
    }

### Relations   {#relation}

The relation is defined as a companion object of corresponding [record](#record) subclassed from
either `Table` or `View`:

    lang:scala
    object Country extends Table[Country]

You can place the definitions of constraints and indexes inside the body of relation:

    lang:scala
    object Country extends Table[Country] {
      // create a named UNIQUE constraint:
      CONSTRAINT "code_uniq" UNIQUE(this.code)   // relations are converted to records implicitly
      // create a UNIQUE constraint with default name:
      UNIQUE(this.code)
      // create a named CHECK constraint:
      CONSTRAINT "code_chk" CHECK("code IN ('ch', 'us', 'uk', 'fr', 'es', 'it', 'pt')")
      // create a named FOREIGN KEY constraint:
      CONSTRAINT "eurozone_code_fkey" FOREIGN_KEY(EuroZone, this.code -> EuroZone.code)
      // create a FOREIGN KEY constraint with default name:
      FOREIGN_KEY(EuroZone, this.code -> EuroZone.code).ON_DELETE(CASCADE)
      // create an index:
      INDEX("country_code_idx", "LOWER(code)") USING "btree" UNIQUE
    }

The relation object is also the right place for various querying methods:

    lang:scala
    object User extends Table[User] {
      def byLogin(l: String): Option[User] = criteria.add(this.login LIKE l).unique
    }

See [querying](#sql), [data manipulation](#dml) and [Criteria API](#criteria) sections for
more information.

### Associations   {#association}

An *association* provides a way to link one [relation](#relation) with another.

    lang:scala
    class City extends Record[City] {
      val country = "country_id" REFERENCES(Country) ON_DELETE CASCADE ON_UPDATE NO_ACTION
    }

As the example above shows, the syntax for association definition is similar to fields definition,
except that the `REFERENCES(relation: Relation[R])` method is used. Associations also implicitly
add foreign key constraint to table's definition, so the cascading actions can be specified by
invoking `ON_DELETE` and `ON_UPDATE` with one of the following arguments:

  * `NO_ACTION` (default),
  * `CASCADE`,
  * `RESTRICT`,
  * `SET_NULL`,
  * `SET_DEFAULT`.

Associations are directed: the relation that owns an association is often refered to as a
*child relation*, while the relation to which an associations references is often refered to
as a *parent relation*.

Like with regular field, you can set an retrieve the association's value:

    lang:scala
    // set the value
    country := russia
    country() = russia
    country.setValue(russia)
    // retrieve the value
    country()
    country.apply
    country.getValue
    // pattern match the value
    country.get match {
      case Some(c: Country) =>
      case None =>
    }
    // get or default
    country.getOrElse(new Country)
    // set null
    country.NULL_!
    // check for null
    country.NULL_?

An association's value is initilialized the first time you access it inside a persistent
[record](#record). This technique is usually refered to as *lazy initialization* or *lazy fetching*:

    lang:scala
    val c = new City
    c.id := 16
    c.country()   // a SELECT query is executed to retrieve a Country
                  // for the City with id = 16
    // ...
    c.country()   // further selects are not issued

You can also perform the *eager initialization*, or *prefetching*, using [Criteria API](#criteria).

### Validation   {#validation}

A record can be optionally validated before it is saved into database.

The validation is performed using one or more *validators*, functions which take a `Record`
and return `Option[ValidationError]`: `None` if validation succeeds or `Some[ValidationError]`
otherwise. They are added to the `validation` object inside record class:

    lang:scala
    class Country extends Record[Country] {
      validation.add(r => ...)
          .add(r => ...)
    }

There are several predefined validators available for your convenience:

    lang:scala
    class Country extends Record[Country] {
      val code = "code" VARCHAR(2) DEFAULT("'ch'")
      validation.notNull(code)
          .notEmpty(code)
          .pattern(code, "(?i:[a-z]{2})")
    }

A record is validated when either `validate` or `validate_!` is invoked.
The first one returns `Option[Seq[ValidationError]]`:

    lang:scala
    rec.validate match {
      case None => ...            // validation succeeded
      case Some(errors) => ...    // validation failed
    }

The second one does not return anything, but throws `ValidationException` if validation fails.

The `validate_!` method is also called when a record is being saved into database, read
more in [Insert, Update, Delete & Save](#iuds) section.

Each `ValidationError` could be resolved into a message from [Circumflex `Messages` helper](/web.html#msg).
Following members of `ValidationError` are involved in message resolution:

  * `source` describes a place where error occured, most obvious field-based validators return
  `ValidationError` instances with field's `uuid` as their source;
  * `errorKey` describes the nature of the error, for example, `"null"` for `notNull` validator,
  or `"empty"` for `notEmpty` validator;
  * `params` provide additional information about validation, this params are
  [interpolated](/web.html#msg) inside resolved message.

The `toMsg` method resolves the message:

  * first, it tries to resolve a message with following key: `source + "." + errorKey`;
  * if no such message exist in the `Messages` bundle, it tries to resolve a message with
  the `errorKey` key;
  * if no message found, it simply returns `errorKey`;
  * finally, the `params` are interpolated into the resolved message.

`ValidationException` also takes some effort to group validation errors by sources and error keys:

    lang:scala
    try {
      rec.validate_!
    } catch {
      case ve: ValidationException =>
        ve.byKey      // Map[String, Seq[ValidationError]]
        ve.bySource   // Map[String, Seq[ValidationError]]
    }

Let's take a look at example. First, let's define a simple model with validation:

    lang:scala
    package com.myapp.model

    class Country extends Record[Country] {
      def this(code: String) = {
        this()
        this.code := code
      }
      val code = "code" VARCHAR(2) DEFAULT("'ch'")
      validation.notNull(code)
          .notEmpty(code)
          .pattern(code, "(?i:[a-z]{2})")
    }

    object Country extends Table[Country]

Now let's provide some messages for validators:

    lang:no-highlight
    # Messages.properties
    com.myapp.model.Country.code.null=Null value in country code is not allowed.
    com.myapp.model.Country.code.empty=Empty value is country code is not allowed.
    com.myapp.model.Country.code.pattern=The value {value} doesn't look like a valid country code.

Finally, let's play with them a bit:

    lang:scala
    val c = new Country
    c.validate
    // Some(List(
    //  ValidationError(
    //    com.myapp.model.Country.code,
    //    null,
    //    Map(src -> com.myapp.model.Country.code))
    // ))
    c.code := "11"
    c.validate
    // Some(List(
    //  ValidationError(
    //    com.myapp.model.Country.code,
    //    pattern,
    //    Map(src -> com.myapp.model.Country.code, regex -> (?:[a-z]{2}), value -> 11))
    // ))
    c.validate.get.apply(0).toMsg
    // "The value 11 doesn't look like a valid country code."
    c.code := "ch"
    c.validate
    // None

It is also fairly easy to implement custom validators:

    lang:scala
    class Person extends Record[Person] {
      val age = "age" INTEGER
      validation.add(r =>
          if (age() < 21)
            Some(ValidationError(age.uuid, "mature", "age" -> age()))
          else None)
    }

### Exporting Database Schema   {#export-schema}

You can use `DDLUnit` to create or drop database objects programmaticaly:

    lang:scala
    val ddl = new DDLUnit(Country, City)
    // drop objects
    ddl.drop
    // create objects
    ddl.create
    // drop and then create objects
    ddl.dropCreate

`DDLUnit` creates objects in the following order:

  * preliminary [auxiliary objects](#aux);
  * tables;
  * constraints;
  * views;
  * posterior [auxiliary objects](#aux).

Respectively, drop script works with objects in a reverse order.

After the execution, `DDLUnit` produces `messages`: `InfoMsg` for succeeded statements,
`ErrorMsg` for failed ones. Here's the example:

    lang:scala
    ddl.messages(0).sql
    // CREATE TABLE public.country (
    //   id BIGINT NOT NULL DEFAULT NEXTVAL('public.country_id_seq'),
    //   code VARCHAR(2) NOT NULL DEFAULT 'ch',
    //   name TEXT NOT NULL,
    //   PRIMARY KEY (id))
    ddl.messages(0).body
    // CREATE TABLE public.country: OK

You can also setup `maven-cx-plugin` to export the schema for your Maven project within a
build profile. Read more on [Circumflex Maven Plugin page](/plugin.html#schema).

## Querying   {#sql}

A precise request for information retrieval from database is often refered to as *query*.
There are various ways you can query your data with Circumflex ORM:

  * using [select queries](#select), a neat object-oriented DSL for retrieving [records](#record)
  as well as arbitrary [projections](#projection) with SQL-like syntax;
  * using the [Criteria API](#criteria), an alternative DSL for retrieving [records](#record)
  with associations prefetching capabilities;
  * using [native SQL queries](#native-sql) for executing vendor-specific queries for
  [records](#record) or arbitrary [projections](#projection).

All data retrieval queries derive from `SQLQuery`.

### Select Queries   {#select}

Select queries are used to retrieve [records](#record) or arbitrary [projections](#projection)
with neat object-oriented DSL which closely resembles SQL syntax:

    lang:scala
    // prepare relations which will participate in query:
    val co = Country as "co"
    val ci = City as "ci"
    // prepare a query:
    val q = SELECT (co.*) FROM (co JOIN ci) WHERE (ci.name LIKE "Moscow) ORDER_BY (co.name ASC)
    // execute a query:
    q.list    // returns Seq[Country]

The `Select` class provides functionality for select queries. It has following structure:

  * [`SELECT` clause](#projection) specifies a [projection](#projection) which determines
  the actual result of query execution;
  * `FROM` clause specifies relations which will participate in query;
  * [`WHERE` clause](#predicate) specifies a [predicate](#predicate) which will be used by
  database to filter the records in result set;
  * [`ORDER_BY` clause](#order-by) tells database how the result set should be [sorted](#order-by);
  * [`GROUP_BY` clause](#group_by) specifies a subset of [projections](#projection) which will
  be used by database for [grouping](#group-by);
  * [`HAVING` clause](#group-by) specifies additional [predicate](#predicate) which will be
  applied by database after [grouping](#group-by);
  * [`LIMIT` clause and `OFFSET` clause](#limit-offset) tell database to return a subset of result
   set and specify it's boundaries;
  * [set operations](#set-ops) allow to combine the results of two or more [SQL queries](#sql).

### Projections   {#projection}

### Predicates   {#predicate}

### Ordering   {#order-by}

### Grouping & Having   {#group-by}

### Limit & Offset   {#limit-offset}

### Union, Intersect & Except   {#set-ops}

### Native SQL Queries {#native}

## Data manipulation   {#dml}

### Insert, Update, Delete & Save   {#iuds}

### Insert-Select   {#insert-select}

### Bulk Update   {#update}

### Bulk Delete   {#delete}

### Native DML Queries   {#native-dml}

## Criteria API   {#criteria}

## Advanced concepts   {#advanced}

### Transaction Demarcation   {#demarcation}

### Transaction-Scoped Cache   {#cache}

### Auxiliary Database Objects   {#aux}

### Dialects   {#dialect}

### Configuration Parameters   {#cfg}
